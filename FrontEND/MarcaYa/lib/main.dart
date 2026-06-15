import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/push_provider.dart';
import 'providers/verificacion_cuenta_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final pushProvider = PushProvider();
  // Inicializar push de forma asíncrona sin bloquear el render inicial
  pushProvider.initialize();

  // Deep link desde notificaciones push
  pushProvider.onNotificationTap = (data) {
    final screen = data['screen'] as String?;
    if (screen == 'historial') {
      appRouter.go('/empleado/historial');
    }
  };

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
