import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app_state.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'services/auto_marking_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicios de segundo plano (US-NUEVA-08 y US-NUEVA-09)
  await AutoMarkingService.initialize();
  await NotificationService.instance.initialize(appRouter);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(MarcaYAState()),
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
