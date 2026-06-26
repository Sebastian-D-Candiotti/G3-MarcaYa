import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../src/api_service.dart';

/// Provider que maneja el ciclo de vida de notificaciones push:
/// registro de FCM token, recepción de mensajes, notificaciones locales
/// y deep link navigation.
///
/// **Importante**: Asume que `Firebase.initializeApp()` ya fue llamado en
/// `main.dart` antes de crear esta instancia.
class PushProvider extends ChangeNotifier {
  final ApiService _api;
  final FirebaseMessaging? _messagingOverride;

  /// Lazy getter — solo se evalúa cuando se necesita (dentro de initialize),
  /// permitiendo que Firebase.initializeApp() se haya llamado primero.
  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;

  PushProvider({
    ApiService? api,
    FirebaseMessaging? messaging,
  })  : _api = api ?? ApiService.instance,
        _messagingOverride = messaging;

  // ── Callbacks ─────────────────────────────────────────────
  /// Se invoca cuando el usuario toca una notificación.
  /// Recibe el data payload de la notificación.
  void Function(Map<String, dynamic> data)? onNotificationTap;

  // ── Estado observable ─────────────────────────────────────
  String? _fcmToken;
  bool _initialized = false;
  String? _lastError;

  String? get fcmToken => _fcmToken;
  bool get initialized => _initialized;
  String? get lastError => _lastError;

  // ── Inicialización ────────────────────────────────────────
  /// Inicializa el manejo de notificaciones push.
  ///
  /// Debe llamarse después de `Firebase.initializeApp()`. Obtiene el FCM token,
  /// lo registra en el backend, y configura listeners para mensajes.
  Future<void> initialize() async {
    try {
      // 1. Configurar notificaciones locales
      await _setupLocalNotifications();

      // 2. Solicitar permisos
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('PushProvider: permisos de notificación denegados');
      }

      // 3. Obtener FCM token inicial
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _api.registrarDispositivo(_fcmToken!, _platformName());
      }

      // 4. Escuchar refresco de token FCM
      _messaging.onTokenRefresh.listen((token) async {
        _fcmToken = token;
        try {
          await _api.registrarDispositivo(token, _platformName());
        } catch (e) {
          debugPrint('PushProvider: error registrando token renovado: $e');
        }
        notifyListeners();
      });

      // 5. Manejar mensajes en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Manejar tap en notificación desde background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // 7. Manejar tap en notificación desde cold start
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationTap(initialMessage);
        });
      }

      _initialized = true;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      debugPrint('PushProvider: error en initialize — $e');
      rethrow;
    }
  }

  // ── Plataforma ────────────────────────────────────────────
  String _platformName() {
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isMacOS) return 'macos';
    } catch (_) {}
    return 'unknown';
  }

  // ── Notificaciones locales ────────────────────────────────
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> _setupLocalNotifications() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null) {
            try {
              final data = _decodePayload(payload);
              onNotificationTap?.call(data);
            } catch (_) {
              debugPrint('PushProvider: error decodificando payload local');
            }
          }
        },
      );
    } catch (e) {
      // Notificaciones locales no disponibles (tests, web, etc.)
      debugPrint('PushProvider: notificaciones locales no disponibles — $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification?.title != null || notification?.body != null) {
      _showLocalNotification(
        id: data['marcacion_id']?.hashCode ??
            DateTime.now().millisecondsSinceEpoch,
        title: notification?.title ?? 'MarcaYA',
        body: notification?.body ?? '',
        payload: data.isNotEmpty ? jsonEncode(data) : null,
      );
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'push_asistencia',
      'Notificaciones de Asistencia',
      channelDescription: 'Alertas de marcación de asistencia',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    if (data.isNotEmpty) {
      onNotificationTap?.call(data);
    }
  }

  Map<String, dynamic> _decodePayload(String payload) {
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return {'screen': payload};
    }
  }

  // ════════════════════════════════════════════════════════════
  // NOTIFICACIONES DE GEOCERCA
  // ════════════════════════════════════════════════════════════

  /// Muestra una notificación local de recordatorio de geocerca.
  ///
  /// El payload incluye los datos de la obra para que al hacer tap
  /// se pueda navegar a la pantalla de marcación.
  Future<void> showGeofenceReminder(Map<String, dynamic> obraData) async {
    final data = <String, dynamic>{
      'type': 'geofence_reminder',
      'screen': 'marcar',
      'obraId': obraData['id'],
      'obraNombre': obraData['nombre'],
      'latitud': obraData['latitud'],
      'longitud': obraData['longitud'],
      'radio': obraData['radio_metros'],
    };

    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Recordatorio de Asistencia',
      body: 'Estás cerca de tu parada. No olvides marcar tu entrada.',
      payload: jsonEncode(data),
    );
  }
}
