// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:marcapp/providers/verificacion_cuenta_provider.dart';
import 'package:marcapp/src/api_service.dart';

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

ApiService _api(Future<http.Response> Function(http.Request request) handler) {
  return ApiService.createForTesting(client: _Client(handler));
}

http.Response _json(int status, Map<String, Object?> body) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  test(
    'exposes loading and success only when backend confirms ACTIVO',
    () async {
      final gate = Completer<void>();
      final provider = VerificacionCuentaProvider(
        apiService: _api((request) async {
          await gate.future;
          return _json(200, {
            'usuario': {'estado_verificacion': 'ACTIVO'},
          });
        }),
      );

      final future = provider.verificarCodigo(
        correo: 'nuevo@test.com',
        codigo: '123456',
      );
      expect(provider.isLoading, isTrue);

      gate.complete();
      expect(await future, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    },
  );

  test('does not report success if backend user is not ACTIVO', () async {
    final provider = VerificacionCuentaProvider(
      apiService: _api(
        (_) async => _json(200, {
          'usuario': {'estado_verificacion': 'PENDIENTE_VERIFICACION'},
        }),
      ),
    );

    final result = await provider.verificarCodigo(
      correo: 'nuevo@test.com',
      codigo: '123456',
    );

    expect(result, isFalse);
  });

  for (final scenario in <(int, String, String)>[
    (422, 'Codigo incorrecto', 'Código incorrecto'),
    (422, 'Codigo vencido', 'Código vencido'),
    (404, 'Usuario no encontrado', 'Usuario no encontrado'),
    (409, 'Codigo ya utilizado', 'ya fue usado'),
  ]) {
    test('maps HTTP ${scenario.$1} ${scenario.$2}', () async {
      final provider = VerificacionCuentaProvider(
        apiService: _api(
          (_) async => _json(scenario.$1, {'error': scenario.$2}),
        ),
      );

      final result = await provider.verificarCodigo(
        correo: 'nuevo@test.com',
        codigo: '123456',
      );

      expect(result, isFalse);
      expect(provider.error, contains(scenario.$3));
      expect(provider.isLoading, isFalse);
    });
  }

  test('maps transport failure without leaking exception', () async {
    final provider = VerificacionCuentaProvider(
      apiService: _api((_) async => throw http.ClientException('offline')),
    );

    final result = await provider.verificarCodigo(
      correo: 'nuevo@test.com',
      codigo: '123456',
    );

    expect(result, isFalse);
    expect(provider.error, contains('Error de conexión'));
  });
}
