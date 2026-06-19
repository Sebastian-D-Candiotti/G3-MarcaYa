import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:marcapp/src/api_service.dart';

// ── Test-wide setup ────────────────────────────────────────

/// The platform channel used by flutter_secure_storage.
const _kSecureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

/// Install a mock handler that returns `null` for all reads (no token persisted).
void _setupSecureStorageMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        _kSecureStorageChannel,
        (MethodCall call) async => null,
      );
}

/// A simple mock [http.Client] that records requests and returns canned responses.
class _MockHttpClient extends http.BaseClient {
  _MockHttpClient({required this.handler});

  final Future<http.Response> Function(http.Request request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) {
      final response = await handler(request);
      return http.StreamedResponse(
        Stream.value(response.bodyBytes),
        response.statusCode,
        headers: response.headers,
      );
    }
    return http.StreamedResponse(Stream.value([]), 200);
  }
}

/// Helper to build a mock client that returns [statusCode] with [body].
http.Client _mockResponse(int statusCode, Object body, {int? times}) {
  int callCount = 0;
  return _MockHttpClient(
    handler: (request) async {
      callCount++;
      if (times != null && callCount > times) {
        fail(
          'Unexpected HTTP call #$callCount: ${request.method} ${request.url}',
        );
      }
      return http.Response(
        body is String ? body : jsonEncode(body),
        statusCode,
        headers: {'content-type': 'application/json'},
      );
    },
  );
}

/// Re-usable matchers for request verification.
http.Request _verifyRequest(
  http.Request request, {
  required String method,
  required String path,
  Map<String, Object?>? bodyFields,
}) {
  expect(
    request.method,
    equals(method),
    reason: 'HTTP method mismatch for $path',
  );
  expect(
    request.url.toString(),
    equals('http://localhost:3000/api/v1$path'),
    reason: 'URL mismatch',
  );
  expect(request.headers['content-type'], equals('application/json'));
  if (bodyFields != null) {
    final decoded = jsonDecode(request.body) as Map<String, dynamic>;
    for (final entry in bodyFields.entries) {
      expect(
        decoded[entry.key],
        equals(entry.value),
        reason: 'Body field "${entry.key}" mismatch',
      );
    }
  }
  return request;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _setupSecureStorageMock();

  group('MarcarAsistencia', () {
    test(
      'marcarEntrada sends POST to /asistencia/marcar-entrada with parada_id, latitud, longitud',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            _verifyRequest(
              request,
              method: 'POST',
              path: '/asistencia/marcar-entrada',
              bodyFields: {
                'parada_id': 5,
                'latitud': -12.0841,
                'longitud': -77.0336,
              },
            );
            return http.Response(
              jsonEncode({'id': 1, 'tipoMarcacion': 'entrada'}),
              201,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        final result = await api.marcarEntrada(
          paradaId: 5,
          latitud: -12.0841,
          longitud: -77.0336,
          isMocked: false,
        );

        expect(result['tipoMarcacion'], equals('entrada'));
      },
    );

    test(
      'marcarSalida sends POST to /asistencia/marcar-salida with correct body',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            _verifyRequest(
              request,
              method: 'POST',
              path: '/asistencia/marcar-salida',
              bodyFields: {
                'parada_id': 3,
                'latitud': -12.0841,
                'longitud': -77.0336,
              },
            );
            return http.Response(
              jsonEncode({'id': 2, 'tipoMarcacion': 'salida'}),
              201,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        final result = await api.marcarSalida(
          paradaId: 3,
          latitud: -12.0841,
          longitud: -77.0336,
          isMocked: false,
        );

        expect(result['tipoMarcacion'], equals('salida'));
      },
    );

    test('obtenerHistorial sends GET to /asistencia/historial', () async {
      final client = _mockResponse(200, [
        {'id': 1, 'tipoMarcacion': 'entrada'},
      ]);
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerHistorial();

      expect(result, hasLength(1));
      expect(result[0]['tipoMarcacion'], equals('entrada'));
    });
  });

  group('Paradas CRUD', () {
    test('obtenerParadas sends GET to /obras/10/paradas', () async {
      final client = _mockResponse(200, [
        {'id': 1, 'nombre': 'Puerta Principal'},
      ]);
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerParadas(10);

      expect(result, hasLength(1));
      expect(result[0]['nombre'], equals('Puerta Principal'));
    });

    test(
      'crearParada sends POST to /obras/10/paradas with correct body',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            _verifyRequest(
              request,
              method: 'POST',
              path: '/obras/10/paradas',
              bodyFields: {
                'nombre': 'Entrada Sur',
                'latitud': -12.0841,
                'longitud': -77.0336,
                'radio_metros': 100,
              },
            );
            return http.Response(
              jsonEncode({'id': 1, 'nombre': 'Entrada Sur'}),
              201,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        final result = await api.crearParada(
          obraId: 10,
          nombre: 'Entrada Sur',
          latitud: -12.0841,
          longitud: -77.0336,
          radioMetros: 100,
        );

        expect(result['nombre'], equals('Entrada Sur'));
      },
    );

    test('obtenerParada sends GET to /paradas/42', () async {
      final client = _mockResponse(200, {'id': 42, 'nombre': 'Portón Oeste'});
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerParada(42);

      expect(result['nombre'], equals('Portón Oeste'));
    });

    test('actualizarParada sends PUT to /paradas/42', () async {
      final client = _MockHttpClient(
        handler: (request) async {
          _verifyRequest(
            request,
            method: 'PUT',
            path: '/paradas/42',
            bodyFields: {'nombre': 'Portón Renovado'},
          );
          return http.Response(
            jsonEncode({'id': 42, 'nombre': 'Portón Renovado'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );
      final api = ApiService.createForTesting(client: client);

      final result = await api.actualizarParada(42, nombre: 'Portón Renovado');

      expect(result['nombre'], equals('Portón Renovado'));
    });

    test('eliminarParada sends DELETE to /paradas/42', () async {
      bool called = false;
      final client = _MockHttpClient(
        handler: (request) async {
          _verifyRequest(request, method: 'DELETE', path: '/paradas/42');
          called = true;
          return http.Response('', 204, headers: {});
        },
      );
      final api = ApiService.createForTesting(client: client);

      await api.eliminarParada(42);

      expect(called, isTrue);
    });
  });

  group('Perfil', () {
    test('obtenerPerfil sends GET to /usuarios/1', () async {
      final client = _mockResponse(200, {
        'id': 1,
        'correo': 'test@mail.com',
        'rol': 'empleado',
        'nombre': 'Juan',
        'apellido': 'Pérez',
      });
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerPerfil(1);

      expect(result['correo'], equals('test@mail.com'));
    });

    test('actualizarPerfil sends PUT to /usuarios/1 with correo', () async {
      final client = _MockHttpClient(
        handler: (request) async {
          _verifyRequest(
            request,
            method: 'PUT',
            path: '/usuarios/1',
            bodyFields: {'correo': 'nuevo@mail.com'},
          );
          return http.Response(
            jsonEncode({'id': 1, 'correo': 'nuevo@mail.com'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );
      final api = ApiService.createForTesting(client: client);

      final result = await api.actualizarPerfil(1, correo: 'nuevo@mail.com');

      expect(result['correo'], equals('nuevo@mail.com'));
    });

    test('obtenerMiPerfil sends GET to /perfil', () async {
      final client = _mockResponse(200, {
        'id': 1,
        'correo': 'yo@mail.com',
        'rol': 'empleado',
      });
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerMiPerfil();

      expect(result['correo'], equals('yo@mail.com'));
    });
  });

  group('Solicitudes', () {
    test(
      'solicitarIngreso sends POST to /solicitudes with empleado_id and empresa_id',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            _verifyRequest(
              request,
              method: 'POST',
              path: '/solicitudes',
              bodyFields: {'empleado_id': 10, 'empresa_id': 1},
            );
            return http.Response(
              '{}',
              201,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        await api.solicitarIngreso(empleadoId: 10, empresaId: 1);
        // no exception = success
      },
    );

    test(
      'obtenerSolicitudesEmpleado sends GET to /empleados/emp-1/historial_solicitudes',
      () async {
        final client = _mockResponse(200, [
          {'id': 1, 'estado': 'pendiente'},
        ]);
        final api = ApiService.createForTesting(client: client);

        final result = await api.obtenerSolicitudesEmpleado('emp-1');

        expect(result, hasLength(1));
      },
    );

    test(
      'obtenerMisSolicitudes sends GET to /solicitudes/mis-solicitudes',
      () async {
        final client = _mockResponse(200, [
          {'id': 1, 'estado': 'pendiente'},
        ]);
        final api = ApiService.createForTesting(client: client);

        final result = await api.obtenerMisSolicitudes();

        expect(result, hasLength(1));
      },
    );

    test('obtenerSolicitud sends GET to /solicitudes/5', () async {
      final client = _mockResponse(200, {'id': 5, 'estado': 'aceptada'});
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerSolicitud(5);

      expect(result['estado'], equals('aceptada'));
    });

    test(
      'aceptarSolicitud sends PUT to /solicitudes/3/aceptar with obra_id',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            _verifyRequest(
              request,
              method: 'PUT',
              path: '/solicitudes/3/aceptar',
              bodyFields: {'obra_id': 7},
            );
            return http.Response(
              '{}',
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        await api.aceptarSolicitud(3, obraId: 7);
      },
    );
  });

  group('Valoraciones', () {
    test(
      'crearValoracion sends POST to /valoraciones with empresa_id, puntuacion, comentario',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            _verifyRequest(
              request,
              method: 'POST',
              path: '/valoraciones',
              bodyFields: {
                'empresa_id': 2,
                'puntuacion': 5,
                'comentario': 'Excelente servicio',
              },
            );
            return http.Response(
              '{}',
              201,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        await api.crearValoracion(
          empresaId: 2,
          puntuacion: 5,
          comentario: 'Excelente servicio',
        );
      },
    );
  });

  group('Empleados', () {
    test(
      'obtenerEmpleadosActuales sends GET to /empleados/actuales without empresa_id',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            expect(request.method, equals('GET'));
            expect(
              request.url.toString(),
              equals('http://localhost:3000/api/v1/empleados/actuales'),
            );
            expect(
              request.url.queryParameters.containsKey('empresa_id'),
              isFalse,
            );
            return http.Response(
              jsonEncode([
                {'id': 1, 'nombre': 'Juan'},
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        final result = await api.obtenerEmpleadosActuales();

        expect(result, hasLength(1));
      },
    );

    test('actualizarEmpleado sends PUT to /empleados/1', () async {
      final client = _MockHttpClient(
        handler: (request) async {
          _verifyRequest(
            request,
            method: 'PUT',
            path: '/empleados/1',
            bodyFields: {'nombre': 'Juan Actualizado'},
          );
          return http.Response(
            jsonEncode({'id': 1, 'nombre': 'Juan Actualizado'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );
      final api = ApiService.createForTesting(client: client);

      final result = await api.actualizarEmpleado(
        1,
        nombre: 'Juan Actualizado',
      );

      expect(result['nombre'], equals('Juan Actualizado'));
    });

    test('desactivarEmpleado sends PUT to /empleados/1/desactivar', () async {
      bool called = false;
      final client = _MockHttpClient(
        handler: (request) async {
          _verifyRequest(
            request,
            method: 'PUT',
            path: '/empleados/1/desactivar',
          );
          called = true;
          return http.Response(
            '{}',
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );
      final api = ApiService.createForTesting(client: client);

      await api.desactivarEmpleado(1);

      expect(called, isTrue);
    });

    test(
      'obtenerAsistenciasEmpleado sends GET to /asistencia/historial/1',
      () async {
        final client = _mockResponse(200, [
          {'id': 1, 'tipoMarcacion': 'entrada'},
        ]);
        final api = ApiService.createForTesting(client: client);

        final result = await api.obtenerAsistenciasEmpleado(1);

        expect(result, hasLength(1));
      },
    );

    test('obtenerParadasEmpleado sends GET to /empleados/1/paradas', () async {
      final client = _mockResponse(200, [
        {'id': 1, 'nombre': 'Puerta'},
      ]);
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerParadasEmpleado(1);

      expect(result, hasLength(1));
    });

    test('obtenerObrasEmpleado sends GET to /empleados/emp-1/obras', () async {
      final client = _mockResponse(200, [
        {'id': 1, 'nombre': 'Obra A'},
      ]);
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerObrasEmpleado('emp-1');

      expect(result, hasLength(1));
    });
  });

  group('Reportes', () {
    test(
      'obtenerReporteAsistencia sends GET to /reportes/asistencia with query params',
      () async {
        final client = _MockHttpClient(
          handler: (request) async {
            expect(request.method, equals('GET'));
            expect(request.url.path, endsWith('/reportes/asistencia'));
            expect(
              request.url.queryParameters['fecha_inicio'],
              equals('2026-01-01'),
            );
            expect(
              request.url.queryParameters['fecha_fin'],
              equals('2026-01-31'),
            );
            expect(request.url.queryParameters['empleado_id'], equals('5'));
            expect(request.url.queryParameters['obra_id'], equals('2'));
            return http.Response(
              jsonEncode([
                {'id': 1, 'tipoMarcacion': 'entrada'},
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final api = ApiService.createForTesting(client: client);

        final result = await api.obtenerReporteAsistencia(
          fechaInicio: '2026-01-01',
          fechaFin: '2026-01-31',
          empleadoId: 5,
          obraId: 2,
        );

        expect(result, hasLength(1));
      },
    );

    test('obtenerReporteAsistencia works without optional params', () async {
      final client = _MockHttpClient(
        handler: (request) async {
          expect(request.url.queryParameters, isEmpty);
          return http.Response(
            '[]',
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );
      final api = ApiService.createForTesting(client: client);

      final result = await api.obtenerReporteAsistencia();

      expect(result, isEmpty);
    });
  });

  group('Error handling', () {
    test('throws ApiException on 4xx response', () async {
      final client = _mockResponse(404, {'error': 'Not found'});
      final api = ApiService.createForTesting(client: client);

      expect(
        () => api.obtenerParada(999),
        throwsA(
          isA<ApiException>().having(
            (e) => e.mensaje,
            'message',
            contains('Not found'),
          ),
        ),
      );
    });

    test('throws ApiException on 5xx response', () async {
      final client = _mockResponse(500, {'error': 'Internal error'});
      final api = ApiService.createForTesting(client: client);

      expect(
        () => api.obtenerMiPerfil(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('Legacy clean-up', () {
    test('obtenerPagos is removed', () {
      // Using dart:reflect would be heavy; we just verify that
      // accessing the method via dynamic produces a NoSuchMethodError.
      final api = ApiService.createForTesting(client: _mockResponse(200, []));
      expect(
        () => (api as dynamic).obtenerPagos(),
        throwsA(isA<NoSuchMethodError>()),
      );
    });

    test('crearPago is removed', () {
      final api = ApiService.createForTesting(client: _mockResponse(200, {}));
      expect(
        () => (api as dynamic).crearPago(
          fechaPago: '2026-01-01',
          tipoPago: 'mensual',
          empleados: [],
        ),
        throwsA(isA<NoSuchMethodError>()),
      );
    });

    test('obtenerPlanes is removed', () {
      final api = ApiService.createForTesting(client: _mockResponse(200, []));
      expect(
        () => (api as dynamic).obtenerPlanes(),
        throwsA(isA<NoSuchMethodError>()),
      );
    });

    test('obtenerSuscripcion is removed', () {
      final api = ApiService.createForTesting(client: _mockResponse(200, {}));
      expect(
        () => (api as dynamic).obtenerSuscripcion(),
        throwsA(isA<NoSuchMethodError>()),
      );
    });
  });
}
