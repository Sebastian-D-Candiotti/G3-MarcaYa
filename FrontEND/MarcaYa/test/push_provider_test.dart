import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:marcapp/providers/push_provider.dart';
import 'package:marcapp/src/api_service.dart';

// ── Channel names ──────────────────────────────────────────
const _kSecureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);
const _kMessagingChannel = MethodChannel(
  'plugins.flutter.io/firebase_messaging',
);
const _kLocalNotificationsChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);

// ── Helpers ─────────────────────────────────────────────────
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Firebase Core mocks (Pigeon) ──────────────────────────
  setUpAll(() {
    setupFirebaseCoreMocks();
  });

  // ── Channel mocks ─────────────────────────────────────────
  setUp(() {
    // Flutter Secure Storage (devuelve null = sin token guardado)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _kSecureStorageChannel,
      (MethodCall call) async => null,
    );

    // Firebase Messaging
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _kMessagingChannel,
      (MethodCall call) async {
        switch (call.method) {
          case 'Messaging#getToken':
            return <String, String>{'token': 'test-fcm-token-123'};
          case 'Messaging#requestPermission':
            return <String, int>{
              'authorizationStatus': 1,
              'showBadge': 1,
              'showAlert': 1,
              'showSound': 1,
              'badge': 1,
              'alert': 1,
              'sound': 1,
              'criticalAlert': 0,
              'provisional': 0,
              'providesAppNotificationSettings': 0,
              'announcement': 0,
              'carPlay': 0,
              'timeSensitive': 0,
              'scheduledDelivery': 0,
              'allowsNotifications': 1,
              'deliversNotifications': 1,
            };
          case 'Messaging#getInitialMessage':
            return null;
          case 'Messaging#getNotificationSettings':
            return <String, int>{
              'authorizationStatus': 1,
              'showBadge': 1,
              'showAlert': 1,
              'showSound': 1,
              'badge': 1,
              'alert': 1,
              'sound': 1,
              'criticalAlert': 0,
              'provisional': 0,
              'providesAppNotificationSettings': 0,
              'announcement': 0,
              'carPlay': 0,
              'timeSensitive': 0,
              'scheduledDelivery': 0,
              'allowsNotifications': 1,
              'deliversNotifications': 1,
            };
          default:
            return null;
        }
      },
    );

    // Local notifications
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _kLocalNotificationsChannel,
      (MethodCall call) async {
        switch (call.method) {
          case 'initialize':
            return null;
          case 'show':
            return null;
          case 'cancel':
            return null;
          case 'cancelAll':
            return null;
          case 'getNotificationAppLaunchDetails':
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_kSecureStorageChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_kMessagingChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_kLocalNotificationsChannel, null);
  });

  group('PushProvider', () {
    // Inicializar Firebase una sola vez para todo el grupo
    setUpAll(() async {
      try {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project',
          ),
        );
      } catch (_) {
        // Ya se inicializó en un grupo anterior
      }
    });

    test('initialize registers FCM token via ApiService', () async {
      http.Request? capturedRequest;
      final client = _MockHttpClient(
        handler: (request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'mensaje': 'dispositivo registrado'}),
            201,
            headers: {'content-type': 'application/json'},
          );
        },
      );
      final api = ApiService.createForTesting(client: client);
      final provider = PushProvider(api: api);

      await provider.initialize();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, equals('POST'));
      expect(
        capturedRequest!.url.toString(),
        equals('http://127.0.0.1:3000/api/v1/dispositivo/registrar'),
      );
      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['fcm_token'], equals('test-fcm-token-123'));
      expect(body['platform'], isA<String>());
    });

    test('initialized flag becomes true after init', () async {
      final api = ApiService.createForTesting(
        client: _MockHttpClient(
          handler: (_) async => http.Response(
            jsonEncode({'mensaje': 'ok'}),
            201,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final provider = PushProvider(api: api);

      expect(provider.initialized, isFalse);

      await provider.initialize();

      expect(provider.initialized, isTrue);
    });

    test('fcmToken is populated after init', () async {
      final api = ApiService.createForTesting(
        client: _MockHttpClient(
          handler: (_) async => http.Response(
            jsonEncode({'mensaje': 'ok'}),
            201,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final provider = PushProvider(api: api);

      await provider.initialize();

      expect(provider.fcmToken, isNotNull);
      expect(provider.fcmToken, equals('test-fcm-token-123'));
    });
  });
}
