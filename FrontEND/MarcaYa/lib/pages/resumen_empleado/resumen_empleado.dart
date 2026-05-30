import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ResumenEmpleadoPage extends StatelessWidget {
  const ResumenEmpleadoPage({super.key});

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, ${auth.state.currentUser?.name ?? ''}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fingerprint, color: AppColors.primary, size: 32),
                title: const Text('Marcar Asistencia', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Registra tu entrada o salida'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/empleado/asistencia'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.search, color: AppColors.primary, size: 32),
                title: const Text('Buscar Empresa', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Encuentra empresas registradas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/empleado/buscar'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        userRole: 'empleado',
        currentIndex: 0,
      ),
    );
  }
}
