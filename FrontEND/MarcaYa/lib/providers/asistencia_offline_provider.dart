import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/marcacion_pendiente.dart';
import '../repositories/marcacion_pendiente_repository.dart';
import '../services/connectivity_service.dart';
import '../src/api_service.dart';

enum MarcacionRegistroEstado {
  sincronizada,
  pendienteSincronizacion,
}

class AsistenciaOfflineProvider extends ChangeNotifier {
  AsistenciaOfflineProvider({
    MarcacionPendienteRepository? repository,
    ConnectivityService? connectivityService,
    ApiService? apiService,
  })  : _repository = repository ?? MarcacionPendienteRepository(),
        _connectivityService = connectivityService ?? ConnectivityService(),
        _apiService = apiService ?? ApiService.instance;

  final MarcacionPendienteRepository _repository;
  final ConnectivityService _connectivityService;
  final ApiService _apiService;

  StreamSubscription<bool>? _connectionSub;

  bool _isOnline = true;
  bool _isSyncing = false;
  int _pendingCount = 0;
  String? _lastError;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    _isOnline = await _connectivityService.hasConnection();
    await _refreshPendingCount();

    _connectionSub = _connectivityService.onConnectionChanged.listen((online) {
      _isOnline = online;
      notifyListeners();
      if (online) {
        sincronizarPendientes();
      }
    });

    if (_isOnline) {
      await sincronizarPendientes();
    }
  }

  Future<MarcacionRegistroEstado> registrarMarcacion({
    required int paradaId,
    required String tipoMarcacion,
    required double latitud,
    required double longitud,
    required DateTime marcadaEn,
    bool isMocked = false,
  }) async {
    final pendiente = MarcacionPendiente.nueva(
      paradaId: paradaId,
      tipoMarcacion: tipoMarcacion,
      latitud: latitud,
      longitud: longitud,
      marcadaEn: marcadaEn,
      isMocked: isMocked,
    );

    if (!_isOnline) {
      await _guardarPendiente(pendiente);
      return MarcacionRegistroEstado.pendienteSincronizacion;
    }

    try {
      if (tipoMarcacion.toLowerCase() == 'entrada') {
        await _apiService.marcarEntrada(
          paradaId: paradaId,
          latitud: latitud,
          longitud: longitud,
          isMocked: isMocked,
        );
      } else {
        await _apiService.marcarSalida(
          paradaId: paradaId,
          latitud: latitud,
          longitud: longitud,
          isMocked: isMocked,
        );
      }
      await sincronizarPendientes();
      return MarcacionRegistroEstado.sincronizada;
    } on ApiException {
      rethrow;
    } catch (e) {
      _isOnline = false;
      _lastError = 'Sin conexion. La marcacion quedo pendiente.';
      await _guardarPendiente(pendiente);
      notifyListeners();
      return MarcacionRegistroEstado.pendienteSincronizacion;
    }
  }

  Future<void> sincronizarPendientes() async {
    if (_isSyncing || !_isOnline) return;

    final pendientes = await _repository.obtenerPendientes();
    if (pendientes.isEmpty) {
      await _refreshPendingCount();
      return;
    }

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _apiService.sincronizarMarcacionesPendientes(
        pendientes.map((m) => m.toSyncJson()).toList(),
      );

      final idsLimpios = <String>[
        ..._clienteIds(response['sincronizados']),
        ..._clienteIds(response['duplicados']),
      ];
      await _repository.eliminarPorClienteIds(idsLimpios);

      final errores = <String, String>{};
      final fallidos = response['fallidos'];
      if (fallidos is List) {
        for (final item in fallidos) {
          if (item is! Map) continue;
          final clienteId = item['cliente_marcacion_id']?.toString();
          final error = item['error']?.toString() ?? 'Error desconocido';
          if (clienteId != null && clienteId.isNotEmpty) {
            errores[clienteId] = error;
          }
        }
      }
      await _repository.registrarErrores(errores);
      if (errores.isNotEmpty) {
        _lastError = 'Algunas marcaciones no pudieron sincronizarse.';
      }
    } catch (e) {
      _lastError = 'No se pudo sincronizar. Se reintentara automaticamente.';
    } finally {
      _isSyncing = false;
      await _refreshPendingCount();
      notifyListeners();
    }
  }

  List<String> _clienteIds(Object? value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) => item['cliente_marcacion_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
  }

  Future<void> _guardarPendiente(MarcacionPendiente pendiente) async {
    await _repository.guardar(pendiente);
    await _refreshPendingCount();
    notifyListeners();
  }

  Future<void> _refreshPendingCount() async {
    _pendingCount = await _repository.contarPendientes();
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }
}
