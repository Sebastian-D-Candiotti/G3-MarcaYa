import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ResumenEmpresaPage extends StatelessWidget {
  const ResumenEmpresaPage({super.key});

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
                leading: const Icon(Icons.location_on, color: AppColors.primary, size: 32),
                title: const Text('Administrar Sitios', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Gestiona paradas y obras'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/empresa/paradas'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.group, color: AppColors.primary, size: 32),
                title: const Text('Empleados', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ver empleados registrados'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/empresa/empleados'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.request_page, color: AppColors.primary, size: 32),
                title: const Text('Solicitudes', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Revisa solicitudes de ingreso'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/empresa/solicitudes'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        userRole: 'empresa',
        currentIndex: 0,
      ),
    );
  }
}
