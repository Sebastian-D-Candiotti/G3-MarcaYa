import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/api_service.dart';
import 'src/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/geofencing_provider.dart';
import 'providers/push_provider.dart';
import 'providers/verificacion_cuenta_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      });
    } else if (screen == 'historial') {
      appRouter.go('/empleado/historial');
    }
  };

  // Inicializar push de forma asíncrona sin bloquear el render inicial
  pushProvider.initialize();

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
    );
  }
}
