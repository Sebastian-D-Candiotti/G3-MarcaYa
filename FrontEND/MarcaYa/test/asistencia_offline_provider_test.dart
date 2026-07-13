import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:marcapp/models/marcacion_pendiente.dart';
import 'package:marcapp/providers/asistencia_offline_provider.dart';
import 'package:marcapp/repositories/marcacion_pendiente_repository.dart';
import 'package:marcapp/services/connectivity_service.dart';
import 'package:marcapp/src/api_service.dart';

const _storageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

class _MemoryRepository extends MarcacionPendienteRepository {
  final List<MarcacionPendiente> records = [];
  final List<String> deleted = [];
  final Map<String, String> errors = {};

  @override
  Future<void> guardar(MarcacionPendiente marcacion) async {
    if (records.every((item) => item.clienteMarcacionId != marcacion.clienteMarcacionId)) {
      records.add(marcacion);
    }
  }

  @override
  Future<List<MarcacionPendiente>> obtenerPendientes() async => List.of(records);

  @override
  Future<int> contarPendientes() async => records.length;

  @override
  Future<void> eliminarPorClienteIds(List<String> clienteIds) async {
    deleted.addAll(clienteIds);
    records.removeWhere((item) => clienteIds.contains(item.clienteMarcacionId));
  }

  @override
  Future<void> registrarErrores(Map<String, String> nuevosErrores) async {
    errors.addAll(nuevosErrores);
  }
}

class _Client extends http.BaseClient {
  _Client(this.handler);
  final Future<http.Response> Function(http.Request request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

ConnectivityService _connectivity(bool online) {
  return ConnectivityService(
    checker: () async => [
      online ? ConnectivityResult.wifi : ConnectivityResult.none,
    ],
    changes: const Stream.empty(),
  );
}

MarcacionPendiente _pending(String id) {
  return MarcacionPendiente(
    clienteMarcacionId: id,
    paradaId: 10,
    tipoMarcacion: 'ENTRADA',
    latitud: -12.119,
    longitud: -77.034,
    marcadaEn: DateTime.utc(2026, 7, 12, 8),
  );
}

http.Response _json(int status, Map<String, Object?> body) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_storageChannel, (_) async => null);
  });

  test('offline mark is stored with original time and pending count', () async {
    final repository = _MemoryRepository();
    final provider = AsistenciaOfflineProvider(
      repository: repository,
      connectivityService: _connectivity(false),
      apiService: ApiService.createForTesting(
        client: _Client((_) async => throw StateError('HTTP must not be called')),
      ),
    );
    await provider.initialize();
    final original = DateTime.utc(2026, 7, 12, 8, 15);

    final result = await provider.registrarMarcacion(
      paradaId: 10,
      tipoMarcacion: 'entrada',
      latitud: -12.119,
      longitud: -77.034,
      marcadaEn: original,
    );

    expect(result, MarcacionRegistroEstado.pendienteSincronizacion);
    expect(provider.isOnline, isFalse);
    expect(provider.pendingCount, 1);
    expect(repository.records.single.marcadaEn, original);
    expect(repository.records.single.estado, MarcacionPendiente.estadoPendiente);
  });

  test('partial success deletes only synchronized and duplicate records', () async {
    final repository = _MemoryRepository()
      ..records.addAll([_pending('ok'), _pending('duplicate'), _pending('failed')]);
    final provider = AsistenciaOfflineProvider(
      repository: repository,
      connectivityService: _connectivity(true),
      apiService: ApiService.createForTesting(
        client: _Client((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final sent = body['marcaciones'] as List;
          expect(sent, hasLength(3));
          expect(sent.first['fecha_hora_original'], '2026-07-12T08:00:00.000Z');
          return _json(207, {
            'sincronizados': [
              {'cliente_marcacion_id': 'ok'}
            ],
            'duplicados': [
              {'cliente_marcacion_id': 'duplicate'}
            ],
            'fallidos': [
              {'cliente_marcacion_id': 'failed', 'error': 'invalid'}
            ],
          });
        }),
      ),
    );

    await provider.initialize();

    expect(repository.deleted, containsAll(['ok', 'duplicate']));
    expect(repository.records.map((item) => item.clienteMarcacionId), ['failed']);
    expect(repository.errors['failed'], 'invalid');
    expect(provider.pendingCount, 1);
    expect(provider.lastError, isNotNull);
  });

  test('HTTP 500 keeps all local records', () async {
    final repository = _MemoryRepository()..records.add(_pending('keep-me'));
    final provider = AsistenciaOfflineProvider(
      repository: repository,
      connectivityService: _connectivity(true),
      apiService: ApiService.createForTesting(
        client: _Client((_) async => _json(500, {'error': 'server error'})),
      ),
    );

    await provider.initialize();

    expect(repository.records, hasLength(1));
    expect(repository.deleted, isEmpty);
    expect(provider.lastError, contains('No se pudo sincronizar'));
  });

  test('concurrent synchronization starts only one HTTP request', () async {
    final repository = _MemoryRepository()..records.add(_pending('only-once'));
    final gate = Completer<http.Response>();
    var requests = 0;
    final provider = AsistenciaOfflineProvider(
      repository: repository,
      connectivityService: _connectivity(true),
      apiService: ApiService.createForTesting(
        client: _Client((_) {
          requests++;
          return gate.future;
        }),
      ),
    );

    final initialization = provider.initialize();
    await Future<void>.delayed(Duration.zero);
    final concurrent = provider.sincronizarPendientes();
    expect(requests, 1);
    expect(provider.isSyncing, isTrue);

    gate.complete(_json(200, {
      'sincronizados': [
        {'cliente_marcacion_id': 'only-once'}
      ],
      'duplicados': [],
      'fallidos': [],
    }));
    await initialization;
    await concurrent;

    expect(requests, 1);
    expect(provider.isSyncing, isFalse);
  });

  test('does not call backend when storage is empty', () async {
    final repository = _MemoryRepository();
    var requests = 0;
    final provider = AsistenciaOfflineProvider(
      repository: repository,
      connectivityService: _connectivity(true),
      apiService: ApiService.createForTesting(
        client: _Client((_) async {
          requests++;
          return _json(200, {});
        }),
      ),
    );

    await provider.initialize();

    expect(requests, 0);
    expect(provider.pendingCount, 0);
  });
}
