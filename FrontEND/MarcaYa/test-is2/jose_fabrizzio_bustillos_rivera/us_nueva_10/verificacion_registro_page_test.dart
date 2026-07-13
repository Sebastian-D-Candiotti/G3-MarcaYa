// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:marcapp/pages/verificacion_registro/verificacion_registro_page.dart';
import 'package:marcapp/providers/verificacion_cuenta_provider.dart';
import 'package:marcapp/src/api_service.dart';
import 'package:provider/provider.dart';

class _Client extends http.BaseClient {
  _Client(this.response);

  final http.Response response;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

Widget _app(http.Response response) {
  final provider = VerificacionCuentaProvider(
    apiService: ApiService.createForTesting(client: _Client(response)),
  );
  final router = GoRouter(
    initialLocation: '/verify',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('LOGIN')),
      ),
      GoRoute(
        path: '/verify',
        builder: (_, _) => const VerificacionRegistroPage(
          correo: 'nuevo@test.com',
          rol: 'empleado',
        ),
      ),
    ],
  );

  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _enterCode(WidgetTester tester, String code) async {
  final fields = find.byType(TextField);
  for (var index = 0; index < code.length && index < 6; index++) {
    await tester.enterText(fields.at(index), code[index]);
  }
}

void main() {
  testWidgets('does not navigate with incomplete code', (tester) async {
    final response = http.Response('{}', 500);
    await tester.pumpWidget(_app(response));

    await _enterCode(tester, '12345');
    await tester.tap(find.text('Confirmar registro'));
    await tester.pump();

    expect(find.textContaining('Ingresa los 6'), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });

  testWidgets('input formatter rejects non numeric characters', (tester) async {
    await tester.pumpWidget(_app(http.Response('{}', 500)));

    await tester.enterText(find.byType(TextField).first, 'A');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('navigates only after backend confirms ACTIVO', (tester) async {
    await tester.pumpWidget(
      _app(
        http.Response(
          jsonEncode({
            'usuario': {'estado_verificacion': 'ACTIVO'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    await _enterCode(tester, '123456');
    await tester.tap(find.text('Confirmar registro'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('stays on verification page when backend rejects code', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        http.Response(
          jsonEncode({'error': 'Codigo incorrecto'}),
          422,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    await _enterCode(tester, '999999');
    await tester.tap(find.text('Confirmar registro'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsNothing);
    expect(find.textContaining('Código incorrecto'), findsOneWidget);
  });
}
