// lib/services/notification_service.dart
//
// Servicio de notificaciones locales para confirmación de marcado (US-NUEVA-09).
//
// US-NUEVA-09 CA-1: Se dispara tras HTTP 201 en marcas.
// US-NUEVA-09 CA-2: Notificación detalla tipo, hora y validez GPS.
// US-NUEVA-09 CA-3: Tap abre la app directamente en /empleado/historial-asistencias.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

/// Ruta destino al tocar la notificación → historial de marcaciones (US-NUEVA-09 CA-3).
const String _kNotificationPayload = '/empleado/historial-asistencias';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  GoRouter? _router;

  // ── Canal Android ──────────────────────────────────────────
  static const _androidChannel = AndroidNotificationChannel(
    'marcaya_attendance',
    'Marcación de asistencia',
    description: 'Notificaciones de confirmación de marcado de asistencia',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ── Inicialización ─────────────────────────────────────────

  Future<void> initialize(GoRouter router) async {
    _router = router;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Crear canal en Android 8+
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_androidChannel);

      // Solicitar permiso de notificaciones en Android 13+
      await androidPlugin?.requestNotificationsPermission();
    }

    // Manejar tap en notificación que abrió la app (estaba cerrada)
    final launchDetails =
        await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchDetails?.notificationResponse != null) {
      _onNotificationTap(launchDetails!.notificationResponse!);
    }
  }

  // ── Mostrar notificación de marcación (US-NUEVA-09 CA-1 y CA-2) ──

  /// Muestra notificación local estructurada tras marcado exitoso (HTTP 201).
  ///
  /// [tipo]       — "Entrada" o "Salida"
  /// [hora]       — DateTime del registro
  /// [validaGps]  — si la ubicación fue validada dentro de la geocerca
  /// [obraNombre] — nombre de la obra/parada para contexto
  Future<void> showMarkingNotification({
    required String tipo,
    required DateTime hora,
    required bool validaGps,
    required String obraNombre,
  }) async {
    final horaFormateada =
        '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

    final gpsTexto = validaGps
        ? '✅ Ubicación validada dentro de la geocerca'
        : '⚠️ Marcado fuera del área de la obra';

    // US-NUEVA-09 CA-2: título con tipo + hora, cuerpo con validez GPS y obra
    final title = '📍 $tipo registrada — $horaFormateada';
    final body = '$gpsTexto\n🏗️ $obraNombre';

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      // BigTextStyle para mostrar el cuerpo completo sin truncar
      styleInformation: BigTextStyleInformation(
        body,
        summaryText: '$tipo · $horaFormateada · ${validaGps ? 'GPS ✓' : 'Fuera de zona'}',
      ),
      autoCancel: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID único por segundo
      title,
      body,
      details,
      payload: _kNotificationPayload, // US-NUEVA-09 CA-3: ruta historial
    );
  }

  // ── Versión para el Isolate de la alarma (US-NUEVA-08 CA-4) ──────

  /// Muestra notificación enriquecida desde el Isolate de la alarma.
  /// Recibe los datos del marcado automático directamente.
  ///
  /// [tipo]      — "Entrada" o "Salida" (por defecto "Entrada" en auto-marcado)
  /// [hora]      — hora del marcado (null = hora actual)
  /// [validaGps] — si la ubicación estaba dentro de la geocerca
  /// [obraNombre]— nombre de la obra
  static Future<void> showFromIsolate({
    required String title,
    required String body,
    String tipo = 'Entrada',
    DateTime? hora,
    bool? validaGps,
    String? obraNombre,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);
    await plugin.initialize(initSettings);

    // Construir cuerpo enriquecido si se pasan datos de marcación
    String richBody = body;
    String? summaryText;

    if (validaGps != null) {
      final horaStr = hora != null
          ? '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}'
          : '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

      final gpsTexto = validaGps
          ? '✅ Ubicación validada dentro de la geocerca'
          : '⚠️ Marcado fuera del área de la obra';

      richBody = '$gpsTexto${obraNombre != null ? '\n🏗️ $obraNombre' : ''}';
      summaryText =
          '$tipo · $horaStr · ${validaGps ? 'GPS ✓' : 'Fuera de zona'}';
    }

    final androidDetails = AndroidNotificationDetails(
      'marcaya_attendance',
      'Marcación de asistencia',
      channelDescription:
          'Notificaciones de confirmación de marcado de asistencia',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      autoCancel: true,
      // US-NUEVA-09 CA-2: BigText para notificación detallada
      styleInformation: BigTextStyleInformation(
        richBody,
        summaryText: summaryText,
      ),
    );

    final details = NotificationDetails(android: androidDetails);

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      richBody,
      details,
      payload: _kNotificationPayload, // US-NUEVA-09 CA-3: ruta historial
    );
  }

  // ── Ruteo al tocar la notificación (US-NUEVA-09 CA-3) ─────────────

  /// Navega al historial de asistencias al presionar la notificación.
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && _router != null) {
      debugPrint('NotificationService: navigating to $payload');
      _router!.go(payload);
    }
  }
}
