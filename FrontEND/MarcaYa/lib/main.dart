import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'src/api_service.dart';
import 'src/app_state.dart';
import 'providers/alertas_ausencia_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/asistencia_offline_provider.dart';
import 'providers/geofencing_provider.dart';
import 'providers/informes_asistencia_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/push_provider.dart';
import 'providers/verificacion_cuenta_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'services/auto_marking_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('ST-LOG: Iniciando inicialización de servicios...');

  try {
    debugPrint('ST-LOG: Cargando AutoMarkingService...');
    await AutoMarkingService.initialize();
    debugPrint('ST-LOG: AutoMarkingService inicializado con éxito.');
  } catch (e) {
    debugPrint('ST-LOG: ERROR al inicializar AutoMarkingService: $e');
  }

  try {
    debugPrint('ST-LOG: Cargando NotificationService...');
    await NotificationService.instance.initialize(appRouter);
    debugPrint('ST-LOG: NotificationService inicializado con éxito.');
  } catch (e) {
    debugPrint('ST-LOG: ERROR al inicializar NotificationService: $e');
  }

  try {
    debugPrint('ST-LOG: Cargando Firebase...');
    await Firebase.initializeApp();
    debugPrint('ST-LOG: Firebase inicializado con éxito.');
  } catch (e) {
    debugPrint('ST-LOG: ERROR al inicializar Firebase: $e');
  }

  debugPrint('ST-LOG: Configurando PushProvider...');
  final pushProvider = PushProvider();

  // Deep link desde notificaciones push
  pushProvider.onNotificationTap = (data) {
    final screen = data['screen'] as String?;

    if (data['type'] == 'geofence_reminder') {
      appRouter.go('/empleado/marcar_asistencia', extra: {
        'obraId': data['obraId'],
        'obraNombre': data['obraNombre'],
        'latitud': data['latitud'],
        'longitud': data['longitud'],
        'radio': data['radio'],
        'horaInicio': data['horaInicio'] ?? '08:00',
        'horaFin': data['horaFin'] ?? '18:00',
      });
    } else if (screen == 'historial') {
      appRouter.go('/empleado/historial');
    }
  };

  // Inicializar push de forma asíncrona sin bloquear el render inicial
  debugPrint('ST-LOG: Ejecutando pushProvider.initialize()...');
  pushProvider.initialize();
  debugPrint('ST-LOG: Preparado para llamar a runApp()...');


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(MarcaYAState()),
        ),
        ChangeNotifierProvider(
          create: (_) => VerificacionCuentaProvider(),
        ),
        ChangeNotifierProvider.value(value: pushProvider),
        ChangeNotifierProvider(
          create: (context) {
            final auth = context.read<AuthProvider>();
            final geo = GeofencingProvider(
              api: ApiService.instance,
              pushProvider: pushProvider,
            );

            // Conectar ciclo de vida de geofencing con auth
            auth.onLoginCallback = () => geo.startMonitoring(auth);
            auth.onLogoutCallback = () => geo.stopMonitoring();

            return geo;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AsistenciaOfflineProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertasAusenciaProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InformesAsistenciaProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
      ],
      child: const MarcaYA(),
    ),
  );
}

class MarcaYA extends StatelessWidget {
  const MarcaYA({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'PE'),
        Locale('es', ''),
        Locale('en', 'US'),
      ],
    );
  }
}
