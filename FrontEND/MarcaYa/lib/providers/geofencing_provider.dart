// lib/providers/geofencing_provider.dart
// Provider que orquesta el ciclo de vida de geofencing:
// - Al login: obtiene obra + paradas, registra geocercas nativas
// - Al evento ENTER: evalúa ventana horaria, consulta estado-hoy (cache 60s),
//   dispara notificación local si corresponde
// - Al logout: limpia geocercas y cache

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/geofencing_service.dart';
import '../src/api_service.dart';
import 'auth_provider.dart';
import 'push_provider.dart';

class GeofencingProvider extends ChangeNotifier {
  final ApiService _api;
  final PushProvider _pushProvider;
  final GeofencingService _geofencingService;

  GeofencingProvider({
    required ApiService api,
    required PushProvider pushProvider,
    GeofencingService? geofencingService,
  })  : _api = api,
        _pushProvider = pushProvider,
        _geofencingService =
            geofencingService ?? createGeofencingService();

  // ── Estado observable ──────────────────────────────────────

  bool _geofencesRegistered = false;
  /// Indica si hay geocercas registradas activamente.
  bool get geofencesRegistered => _geofencesRegistered;

  String? _lastError;
  /// Último error ocurrido (o `null` si todo ok).
  String? get lastError => _lastError;

  // ── Cache de estado-hoy (TTL 60s) ──────────────────────────

  DateTime? _lastEstadoHoyFetch;
  bool? _cachedMarcadoHoy;
  static const Duration _cacheTtl = Duration(seconds: 60);

  // ── Suscripción a eventos de geocerca ──────────────────────

  StreamSubscription<GeofenceEvent>? _eventSub;

  // ── Datos cacheados del empleado ───────────────────────────

  Map<String, dynamic>? _obraData;
  List<Map<String, dynamic>> _paradas = [];

  /// Obra cachead para construir el payload de las notificaciones.
  Map<String, dynamic>? get obraData => _obraData;

  // ═══════════════════════════════════════════════════════════
  // CICLO DE VIDA
  // ═══════════════════════════════════════════════════════════

  /// Inicia el monitoreo de geocercas.
  ///
  /// Debe llamarse después del login exitoso. Obtiene la obra y
  /// paradas del empleado, calcula la ventana horaria, registra
  /// las geocercas nativas y escucha eventos ENTER.
  Future<void> startMonitoring(AuthProvider auth) async {
    // Solo en Android/iOS
    if (!NativeGeofencingService.isAvailable) {
      debugPrint(
        'GeofencingProvider: geofencing no disponible en esta plataforma',
      );
      return;
    }

    try {
      final perfil = auth.currentUserProfile;
      if (perfil == null) {
        _lastError = 'No hay perfil de usuario';
        notifyListeners();
        return;
      }

      // 1. Obtener obras del empleado
      final empleadoId = perfil.employeeId ?? perfil.id;
      final obras = await _api.obtenerObrasEmpleado(empleadoId);
      if (obras.isEmpty) {
        _lastError = 'No hay obras asignadas';
        notifyListeners();
        return;
      }
      _obraData = obras.first as Map<String, dynamic>;

      // 2. Obtener paradas activas
      final paradasRaw =
          await _api.obtenerParadasEmpleado(int.tryParse(empleadoId) ?? 0);
      _paradas = paradasRaw.cast<Map<String, dynamic>>();

      if (_paradas.isEmpty) {
        _lastError = 'No hay paradas activas';
        notifyListeners();
        return;
      }

      // 3. Inicializar servicio de geofencing
      await _geofencingService.initialize();

      // 4. Registrar geocercas (límite iOS 20 — truncar si excede)
      var regions = _paradas.map((p) => GeofenceRegionData(
            id: p['id'].toString(),
            latitude: (p['latitud'] as num).toDouble(),
            longitude: (p['longitud'] as num).toDouble(),
            radiusMeters: (p['radio_metros'] as num).toDouble(),
            data: {'nombre': p['nombre'] as String?},
          )).toList();

      // iOS: máximo 20 regiones
      if (regions.length > 20) {
        debugPrint(
          'GeofencingProvider: truncando a 20 regiones (iOS limit)',
        );
        regions = regions.sublist(0, 20);
      }

      await _geofencingService.registerGeofences(regions);

      // 5. Escuchar eventos ENTER
      _eventSub?.cancel();
      _eventSub =
          _geofencingService.onGeofenceEvent.listen(_handleGeofenceEnter);

      _geofencesRegistered = true;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      _geofencesRegistered = false;
      debugPrint('GeofencingProvider.startMonitoring error: $e');
      notifyListeners();
    }
  }

  /// Detiene el monitoreo y limpia todos los recursos.
  ///
  /// Debe llamarse durante el logout.
  Future<void> stopMonitoring() async {
    _eventSub?.cancel();
    _eventSub = null;

    try {
      await _geofencingService.removeAllGeofences();
    } catch (e) {
      debugPrint('GeofencingProvider.stopMonitoring error: $e');
    }

    _geofencesRegistered = false;
    _obraData = null;
    _paradas.clear();
    _lastEstadoHoyFetch = null;
    _cachedMarcadoHoy = null;
    _lastError = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // MANEJO DE EVENTOS
  // ═══════════════════════════════════════════════════════════

  /// Evalúa si el empleado está dentro de la ventana horaria y,
  /// de ser así, consulta estado-hoy (con cache) y notifica.
  void _handleGeofenceEnter(GeofenceEvent event) {
    // 1. Verificar ventana horaria
    if (!_isWithinTimeWindow()) {
      debugPrint('GeofencingProvider: fuera de ventana — silencioso');
      return;
    }

    // 2. Consultar estado-hoy (con cache) y notificar si aplica
    _checkAndNotify();
  }

  /// Retorna `true` si la hora actual está dentro de la ventana
  /// [hora_inicio - 15min, hora_inicio + 15min].
  bool _isWithinTimeWindow() {
    if (_obraData == null) return false;

    final horaInicioStr = _obraData!['hora_inicio'] as String?;
    if (horaInicioStr == null || horaInicioStr.isEmpty) return false;

    final parts = horaInicioStr.split(':');
    if (parts.length < 2) return false;

    final hora = int.tryParse(parts[0]);
    final minuto = int.tryParse(parts[1]);
    if (hora == null || minuto == null) return false;

    final now = DateTime.now();
    final horaInicio =
        DateTime(now.year, now.month, now.day, hora, minuto);

    // Tolerancia adicional si está disponible en la obra
    final toleranciaMin =
        (_obraData!['tolerancia_entrada_min'] as int?) ?? 0;

    final windowStart = horaInicio.subtract(
      Duration(minutes: toleranciaMin + 15),
    );
    final windowEnd = horaInicio.add(
      const Duration(minutes: 15),
    );

    return now.isAfter(windowStart) && now.isBefore(windowEnd);
  }

  /// Consulta `estado-hoy` (con cache TTL 60s) y dispara
  /// notificación si el empleado NO ha marcado aún.
  Future<void> _checkAndNotify() async {
    // Cache hit?
    if (_lastEstadoHoyFetch != null &&
        _cachedMarcadoHoy != null &&
        DateTime.now().difference(_lastEstadoHoyFetch!) < _cacheTtl) {
      if (_cachedMarcadoHoy!) {
        debugPrint('GeofencingProvider: ya marcó (cache) — silencioso');
      } else {
        await _showReminder();
      }
      return;
    }

    try {
      final result = await _api.obtenerEstadoHoy();
      final marcadoHoy = result['marcado_hoy'] as bool;

      // Actualizar cache
      _lastEstadoHoyFetch = DateTime.now();
      _cachedMarcadoHoy = marcadoHoy;

      if (!marcadoHoy) {
        await _showReminder();
      } else {
        debugPrint('GeofencingProvider: ya marcó hoy — silencioso');
      }
    } catch (e) {
      // Error de red / API → degradación silenciosa
      debugPrint('GeofencingProvider: error estado-hoy — $e');
    }
  }

  /// Muestra la notificación local de recordatorio vía PushProvider.
  Future<void> _showReminder() async {
    final obraData = _obraData ?? <String, dynamic>{};
    await _pushProvider.showGeofenceReminder(obraData);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _geofencingService.dispose();
    super.dispose();
  }
}
