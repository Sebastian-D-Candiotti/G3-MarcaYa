// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:marcapp/models/informe_asistencia.dart';
import 'package:marcapp/providers/informes_asistencia_provider.dart';
import 'package:marcapp/src/api_service.dart';

const _storageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

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

http.Response _json(int status, Map<String, Object?> body) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

Map<String, Object?> _reportJson({int id = 7}) {
  return {
    'id': id,
    'tipo_periodo': 'MENSUAL',
    'fecha_inicio': '2026-07-01',
    'fecha_fin': '2026-07-31',
    'estado': 'CERRADO',
    'checksum': 'abc',
    'version': 1,
    'snapshot': {
      'resumen': {'total_marcaciones': 2},
    },
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_storageChannel, (_) async => null);
  });

  test('exposes loading then parses history response', () async {
    final gate = Completer<http.Response>();
    final provider = InformesAsistenciaProvider(
      apiService: ApiService.createForTesting(
        client: _Client((_) => gate.future),
      ),
    );

    final future = provider.cargarHistorial(anio: 2026, mes: 7);
    expect(provider.cargando, isTrue);
    gate.complete(
      _json(200, {
        'items': [_reportJson()],
        'pagination': {'page': 1, 'per_page': 20, 'total': 1},
      }),
    );
    await future;

    expect(provider.cargando, isFalse);
    expect(provider.error, isNull);
    expect(provider.historial, hasLength(1));
    expect(provider.historial.single.id, 7);
    expect(provider.historial.single.resumen['total_marcaciones'], 2);
  });

  test('keeps error state when preview endpoint fails', () async {
    final provider = InformesAsistenciaProvider(
      apiService: ApiService.createForTesting(
        client: _Client((_) async => _json(422, {'error': 'Rango invalido'})),
      ),
    );

    await provider.generarVistaPrevia(
      tipoPeriodo: 'SEMANAL',
      fechaInicio: '2026-07-01',
      fechaFin: '2026-07-10',
    );

    expect(provider.vistaPrevia, isNull);
    expect(provider.error, contains('Rango invalido'));
    expect(provider.cargando, isFalse);
  });

  test(
    'downloads PDF bytes and generates deterministic safe filename',
    () async {
      final bytes = Uint8List.fromList('%PDF-1.4'.codeUnits);
      final provider = InformesAsistenciaProvider(
        apiService: ApiService.createForTesting(
          client: _Client(
            (_) async => http.Response.bytes(
              bytes,
              200,
              headers: {'content-type': 'application/pdf'},
            ),
          ),
        ),
      );
      final report = InformeAsistencia.fromJson(
        Map<String, dynamic>.from(_reportJson()),
      );

      final result = await provider.descargarPdf(report);

      expect(result, bytes);
      expect(provider.ultimoPdf, bytes);
      expect(provider.ultimoPdfNombre, 'informe_asistencia_2026_07.pdf');
    },
  );

  test('closing month refreshes matching history', () async {
    final paths = <String>[];
    final provider = InformesAsistenciaProvider(
      apiService: ApiService.createForTesting(
        client: _Client((request) async {
          paths.add(request.url.path);
          if (request.method == 'POST') {
            return _json(201, _reportJson(id: 9));
          }
          return _json(200, {
            'items': [_reportJson(id: 9)],
            'pagination': {'page': 1, 'per_page': 20, 'total': 1},
          });
        }),
      ),
    );

    final report = await provider.cerrarMes(anio: 2026, mes: 7);

    expect(report?.id, 9);
    expect(provider.historial.single.id, 9);
    expect(paths, hasLength(2));
    expect(paths.first, endsWith('/informes/asistencia/cerrar-mes'));
    expect(paths.last, endsWith('/informes/asistencia'));
  });
}
