// lib/services/auto_marking_service.dart
// Servicio de marcación automática en segundo plano (US-NUEVA-08).
//
// Usa android_alarm_manager_plus para programar una alarma exacta 5 minutos
// antes del turno. Al dispararse, el callback:
//   1. Lee datos de SharedPreferences (JWT, parada, geocerca)
//   2. Obtiene posición GPS actual
//   3. Valida si está dentro de la geocerca (Haversine)
//   4. Si sí → POST /api/v1/asistencia/marcar-entrada
//   5. Muestra notificación local de confirmación
//
// IMPORTANTE: El callback corre en un Isolate separado — no tiene acceso
// al árbol de widgets, Provider, ni al singleton ApiService.instance.

import 'dart:convert';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'auto_marking_prefs.dart';
import 'notification_service.dart';

class AutoMarkingService {
  AutoMarkingService._();

  /// ID fijo para la alarma de marcación automática.
  static const int _alarmId = 42;

  /// Minutos de anticipación al turno.
  static const int _minutosAntes = 5;

  // ── Inicialización ─────────────────────────────────────────

  /// Inicializa el AlarmManager de Android. Llamar en main().
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  // ── Programar alarma ───────────────────────────────────────

  /// Programa la alarma para 5 min antes del turno del día siguiente
  /// (o del día actual si aún no pasó la hora).
  ///
  /// Requiere que los datos de parada y turno estén guardados en
  /// SharedPreferences previamente.
  static Future<bool> scheduleAlarm() async {
    final turnoInicio = await AutoMarkingPrefs.getTurnoHoraInicioAsDateTime();
    if (turnoInicio == null) {
      debugPrint('AutoMarkingService: no hay hora de turno configurada');
      return false;
    }

    // Calcular el momento de disparo: 5 min antes del turno
    var alarmTime = turnoInicio.subtract(
      const Duration(minutes: _minutosAntes),
    );

    // Si la hora ya pasó hoy, programar para mañana
    final now = DateTime.now();
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    debugPrint(
      'AutoMarkingService: programando alarma para '
      '${alarmTime.toIso8601String()} '
      '(${alarmTime.difference(now).inMinutes} min desde ahora)',
    );

    final result = await AndroidAlarmManager.oneShotAt(
      alarmTime,
      _alarmId,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    debugPrint('AutoMarkingService: alarma programada = $result');
    return result;
  }

  // ── Cancelar alarma ────────────────────────────────────────

  /// Cancela la alarma y limpia el estado de SharedPreferences.
  static Future<void> cancelAlarm() async {
    await AndroidAlarmManager.cancel(_alarmId);
    await AutoMarkingPrefs.setEnabled(false);
    debugPrint('AutoMarkingService: alarma cancelada y prefs limpiadas');
  }

  /// Cancelación completa al cerrar sesión (limpia TODO).
  static Future<void> cancelAndClearAll() async {
    await AndroidAlarmManager.cancel(_alarmId);
    await AutoMarkingPrefs.clearAll();
    debugPrint('AutoMarkingService: logout — todo limpiado');
  }

  // ── Callback de la alarma (Isolate separado) ───────────────

  /// Punto de entrada para el Isolate de la alarma.
  /// DEBE ser una función estática de nivel superior o anotada con
  /// @pragma('vm:entry-point').
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    debugPrint('AutoMarkingService: ⏰ alarma disparada');

    try {
      // 1. Verificar si la marcación automática sigue activa
      final enabled = await AutoMarkingPrefs.isEnabled();
      if (!enabled) {
        debugPrint('AutoMarkingService: marcación automática desactivada, abortando');
        return;
      }

      // 2. Leer datos desde SharedPreferences
      final token = await AutoMarkingPrefs.getToken();
      final paradaData = await AutoMarkingPrefs.getParadaData();
      final baseUrl = await AutoMarkingPrefs.getBaseUrl();

      if (token == null || paradaData == null || baseUrl == null) {
        debugPrint('AutoMarkingService: faltan datos (token/parada/url)');
        await NotificationService.showFromIsolate(
          title: '⚠️ Marcación automática',
          body: 'No se pudo marcar: faltan datos de configuración. '
              'Abre la app y reactiva la opción.',
        );
        return;
      }

      final paradaId = paradaData['parada_id'] as int;
      final paradaLat = paradaData['latitud'] as double;
      final paradaLng = paradaData['longitud'] as double;
      final paradaRadio = paradaData['radio'] as double;
      final paradaNombre = paradaData['parada_nombre'] as String;
      final obraNombre = paradaData['obra_nombre'] as String;

      // 3. Obtener posición GPS actual (US-NUEVA-08 CA-2/CA-4)
      //    getCurrentPosition() es una petición one-shot: obtiene una
      //    lectura y libera el sensor GPS automáticamente.
      //    Esto cumple CA-4: no se deja un servicio GPS corriendo.
      debugPrint('AutoMarkingService: encendiendo GPS (one-shot)...');

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30),
        );
      } catch (e) {
        debugPrint('AutoMarkingService: error GPS — $e');
        await NotificationService.showFromIsolate(
          title: '⚠️ Marcación automática',
          body: 'No se pudo obtener la ubicación GPS. '
              'Verifica que el GPS esté activo.',
        );
        return;
      }

      // CA-4: GPS liberado automáticamente tras getCurrentPosition.
      debugPrint(
        'AutoMarkingService: GPS liberado. Posición obtenida: '
        '${position.latitude}, ${position.longitude}',
      );

      // 4. Validar geocerca (Haversine)
      final distancia = _haversineDistance(
        position.latitude,
        position.longitude,
        paradaLat,
        paradaLng,
      );

      final dentroGeocerca = distancia <= paradaRadio;

      debugPrint(
        'AutoMarkingService: distancia=$distancia m, '
        'radio=$paradaRadio m, dentro=$dentroGeocerca',
      );

      // 5. Enviar marcación al backend
      debugPrint('AutoMarkingService: enviando POST marcar-entrada...');

      final response = await http.post(
        Uri.parse('$baseUrl/asistencia/marcar-entrada'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'parada_id': paradaId,
          'latitud': position.latitude,
          'longitud': position.longitude,
        }),
      );

      debugPrint(
        'AutoMarkingService: respuesta ${response.statusCode}: '
        '${response.body}',
      );

      final horaActual = DateTime.now();
      final horaStr =
          '${horaActual.hour.toString().padLeft(2, '0')}:'
          '${horaActual.minute.toString().padLeft(2, '0')}';

      if (response.statusCode == 201 || response.statusCode == 200) {
        // US-NUEVA-09 CA-1: éxito HTTP 201 → disparar notificación enriquecida
        // US-NUEVA-09 CA-2: detalla tipo, hora y validez GPS
        await NotificationService.showFromIsolate(
          title: '📍 Entrada registrada — $horaStr',
          body: dentroGeocerca
              ? '✅ Ubicación validada dentro de la geocerca'
              : '⚠️ Marcado fuera del área de la obra',
          tipo: 'Entrada',
          hora: horaActual,
          validaGps: dentroGeocerca,
          obraNombre: obraNombre,
        );
      } else {
        // Error del backend
        String errorMsg;
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMsg = errorData['error']?.toString() ??
              errorData['errors']?.toString() ??
              'Error desconocido';
        } catch (_) {
          errorMsg = 'Error HTTP ${response.statusCode}';
        }

        await NotificationService.showFromIsolate(
          title: '❌ Error al marcar entrada — $horaStr',
          body: '$errorMsg ($paradaNombre)',
        );
      }

      // 6. Re-programar para el día siguiente
      await scheduleAlarm();
    } catch (e, stack) {
      debugPrint('AutoMarkingService: error en callback — $e\n$stack');
      await NotificationService.showFromIsolate(
        title: '⚠️ Error en marcación automática',
        body: 'Ocurrió un error inesperado. Abre la app para más detalles.',
      );
    }
  }

  // ── Haversine (copia local para el Isolate) ────────────────

  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c * 1000; // metros
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
