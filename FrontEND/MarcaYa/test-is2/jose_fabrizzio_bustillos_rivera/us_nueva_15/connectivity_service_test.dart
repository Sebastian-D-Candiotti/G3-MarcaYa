import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/services/connectivity_service.dart';

void main() {
  test('reports disconnected initial state without real network', () async {
    final service = ConnectivityService(
      checker: () async => [ConnectivityResult.none],
    );

    expect(await service.hasConnection(), isFalse);
  });

  test('emits offline to online transition and ignores duplicates', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final service = ConnectivityService(
      checker: () async => [ConnectivityResult.none],
      changes: controller.stream,
    );
    final emitted = service.onConnectionChanged.take(2).toList();

    controller.add([ConnectivityResult.none]);
    controller.add([ConnectivityResult.none]);
    controller.add([ConnectivityResult.wifi]);

    expect(await emitted, [false, true]);
    await controller.close();
  });
}
