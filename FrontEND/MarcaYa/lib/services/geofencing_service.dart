// lib/services/geofencing_service.dart
// Abstracción de geofencing con implementación nativa vía
// flutter_background_geofencing y fallback con geolocator polling.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

// ═════════════════════════════════════════════════════════════
// MODELOS
// ═════════════════════════════════════════════════════════════

/// Datos de una región de geocerca a registrar.
class GeofenceRegionData {
  const GeofenceRegionData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.data,
  });

  /// Identificador único (parada_id como string).
  final String id;

  /// Latitud del centro.
  final double latitude;

  /// Longitud del centro.
  final double longitude;

  /// Radio en metros.
  final double radiusMeters;

  /// Datos adicionales opcionales (ej. nombre de parada).
  final Map<String, dynamic>? data;
}

/// Evento emitido al entrar a una geocerca.
class GeofenceEvent {
  const GeofenceEvent({
    required this.regionId,
    required this.timestamp,
  });

  final String regionId;
  final DateTime timestamp;
}

// ═════════════════════════════════════════════════════════════
// ABSTRACCIÓN
// ═════════════════════════════════════════════════════════════

/// Interfaz base para servicios de geofencing.
///
/// Implementaciones concretas:
/// - [NativeGeofencingService]: usa el plugin nativo.
/// - [PollingGeofencingService]: fallback con geolocator + polling.
abstract class GeofencingService {
  /// Inicializa el servicio. Llamar una vez al inicio.
  Future<void> initialize();

  /// Registra [regions] como geocercas.
  /// Limpia geocercas previas automáticamente.
  Future<void> registerGeofences(List<GeofenceRegionData> regions);

  /// Elimina todas las geocercas registradas.
  Future<void> removeAllGeofences();

  /// Stream de eventos ENTER del OS geofencing.
  Stream<GeofenceEvent> get onGeofenceEvent;

  /// Libera recursos.
  void dispose();
}

// ═════════════════════════════════════════════════════════════
// IMPLEMENTACIÓN NATIVA (flutter_background_geofencing)
// ═════════════════════════════════════════════════════════════

/// Implementación usando el plugin [flutter_background_geofencing].
///
/// Solo funciona en Android / iOS. En web/desktop la inicialización
/// es no-op y [isAvailable] retorna `false`.
class NativeGeofencingService extends GeofencingService {
  // Import dinámico: el plugin se carga solo en Android/iOS.
  // Usamos un setter estático para inyectar el plugin desde fuera,
  // lo que permite mockeo en tests y evita crashes en web.
  static dynamic Function() pluginFactory = defaultPluginFactory;

  dynamic _plugin;
  StreamSubscription<dynamic>? _eventSub;
  final Set<String> _regionIds = {};
  final StreamController<GeofenceEvent> _ctrl =
      StreamController<GeofenceEvent>.broadcast();
  bool _initialized = false;

  /// Indica si el servicio nativo está disponible en esta plataforma.
  static bool get isAvailable => testingOverrideIsAvailable ??
      (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

  /// Override para testing. Asignar `true` para forzar disponibilidad.
  @visibleForTesting
  static bool? testingOverrideIsAvailable;

  @override
  Future<void> initialize() async {
    if (!isAvailable || _initialized) return;

    try {
      _plugin = pluginFactory();
      await _plugin.initialize();
      _initialized = true;
    } catch (e) {
      debugPrint('NativeGeofencingService.initialize error: $e');
      rethrow;
    }
  }

  @override
  Future<void> registerGeofences(List<GeofenceRegionData> regions) async {
    if (!isAvailable || _plugin == null) return;

    // 1. Limpiar geocercas previas
    await removeAllGeofences();

    // 2. Registrar cada región
    for (final r in regions) {
      try {
        // El plugin acepta tanto GeofenceRegion como Map
        await _plugin.addGeofence(_toPluginRegion(r));
        _regionIds.add(r.id);
      } catch (e) {
        debugPrint('Error registrando geocerca ${r.id}: $e');
      }
    }

    // 3. Iniciar servicio background si hay regiones
    if (_regionIds.isNotEmpty) {
      try {
        await _plugin.startService(
          notificationTitle: 'MarcaYA',
          notificationText: 'Monitoreando geocercas',
          enableFallbackNotifications: true,
          fallbackNotificationTitle: 'Recordatorio de Asistencia',
          fallbackNotificationBody: 'Estás cerca de tu parada.',
        );
      } catch (e) {
        debugPrint('Error iniciando servicio geofencing: $e');
      }
    }

    // 4. Escuchar eventos
    _eventSub ??= _plugin.onGeofenceEvent.listen(
      (dynamic ev) {
        final regionId = ev.regionId as String?;
        if (regionId == null) return;
        final type = ev.type?.toString() ?? '';
        if (type.contains('enter')) {
          _ctrl.add(GeofenceEvent(
            regionId: regionId,
            timestamp: DateTime.now(),
          ));
        }
      },
      onError: (Object err) => debugPrint('Geofence stream error: $err'),
    );
  }

  @override
  Future<void> removeAllGeofences() async {
    if (!isAvailable || _plugin == null) return;

    for (final id in _regionIds.toList()) {
      try {
        await _plugin.removeGeofence(id);
      } catch (e) {
        debugPrint('Error eliminando geocerca $id: $e');
      }
    }
    _regionIds.clear();

    try {
      await _plugin.stopService();
    } catch (e) {
      debugPrint('Error deteniendo servicio: $e');
    }
  }

  @override
  Stream<GeofenceEvent> get onGeofenceEvent => _ctrl.stream;

  @override
  void dispose() {
    _eventSub?.cancel();
    _ctrl.close();
  }

  // ── Helpers ────────────────────────────────────────────

  Map<String, dynamic> _toPluginRegion(GeofenceRegionData d) => {
        'id': d.id,
        'latitude': d.latitude,
        'longitude': d.longitude,
        'radius': d.radiusMeters,
        'data': d.data ?? {},
      };

  /// Fábrica por defecto (lanza error si se usa sin mock).
  static dynamic defaultPluginFactory() {
    throw UnsupportedError(
      'NativeGeofencingService requiere flutter_background_geofencing. '
      'Usar NativeGeofencingService.pluginFactory para mock en tests.',
    );
  }

  /// Resetea la fábrica al valor por defecto (útil en tests).
  static void resetPluginFactory() {
    pluginFactory = defaultPluginFactory;
  }
}

// ═════════════════════════════════════════════════════════════
// IMPLEMENTACIÓN FALLBACK (geolocator + polling)
// ═════════════════════════════════════════════════════════════

/// Implementación fallback que verifica la ubicación cada 30s.
///
/// Consume más batería que la nativa. Solo usar cuando
/// [NativeGeofencingService] no esté disponible.
class PollingGeofencingService extends GeofencingService {
  Timer? _timer;
  List<GeofenceRegionData> _regions = [];
  final Set<String> _regionIds = {};
  final StreamController<GeofenceEvent> _ctrl =
      StreamController<GeofenceEvent>.broadcast();
  bool _initialized = false;

  static const Duration pollInterval = Duration(seconds: 30);

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  @override
  Future<void> registerGeofences(List<GeofenceRegionData> regions) async {
    await removeAllGeofences();
    _regions = List.from(regions);
    for (final r in regions) {
      _regionIds.add(r.id);
    }
    _startPolling();
  }

  @override
  Future<void> removeAllGeofences() async {
    _timer?.cancel();
    _timer = null;
    _regions.clear();
    _regionIds.clear();
  }

  @override
  Stream<GeofenceEvent> get onGeofenceEvent => _ctrl.stream;

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.close();
  }

  // ── Polling ─────────────────────────────────────────────

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => _checkProximity());
    _checkProximity(); // primera verificación inmediata
  }

  Future<void> _checkProximity() async {
    if (_regions.isEmpty) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      );

      for (final region in _regions) {
        final dist = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          region.latitude,
          region.longitude,
        );

        if (dist <= region.radiusMeters) {
          _ctrl.add(GeofenceEvent(
            regionId: region.id,
            timestamp: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      debugPrint('Polling check error: $e');
    }
  }
}

// ═════════════════════════════════════════════════════════════
// FACTORY
// ═════════════════════════════════════════════════════════════

/// Crea la implementación adecuada según la plataforma.
///
/// En Android/iOS retorna [NativeGeofencingService].
/// En web/desktop retorna [PollingGeofencingService] como fallback,
/// que a su vez es no-op si no hay geolocator disponible.
GeofencingService createGeofencingService() {
  if (NativeGeofencingService.isAvailable) {
    return NativeGeofencingService();
  }
  return PollingGeofencingService();
}
