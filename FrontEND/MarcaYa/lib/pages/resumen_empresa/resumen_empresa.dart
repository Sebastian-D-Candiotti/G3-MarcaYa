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

    // MOCK TEMPORAL
    const int asistenciasTotales = 154;
    const int paradasActivas = 8;
    const double tendencia = 12.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.error,
            ),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Bienvenido, ${auth.state.currentUser?.name ?? 'Empresa'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    titulo: 'Asistencias',
                    valor: asistenciasTotales.toString(),
                    icono: Icons.fact_check,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard(
                    titulo: 'Paradas',
                    valor: paradasActivas.toString(),
                    icono: Icons.location_on,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _metricCard(
              titulo: 'Tendencia vs Ayer',
              valor: '+$tendencia%',
              icono: Icons.trending_up,
              color: Colors.orange,
              anchoCompleto: true,
            ),

            const SizedBox(height: 30),

            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [

                _actionCard(
                  titulo: 'Solicitudes',
                  icono: Icons.request_page,
                  color: Colors.blue,
                  onTap: () {
                    context.push('/empresa/solicitudes');
                  },
                ),

                _actionCard(
                  titulo: 'Empleados',
                  icono: Icons.group,
                  color: Colors.green,
                  onTap: () {
                    context.push('/empresa/empleados');
                  },
                ),

                _actionCard(
                  titulo: 'Nueva Parada',
                  icono: Icons.add_location_alt,
                  color: Colors.orange,
                  onTap: () {
                    context.push('/empresa/obras/agregar');
                  },
                ),

                _actionCard(
                  titulo: 'Administrar',
                  icono: Icons.settings,
                  color: Colors.purple,
                  onTap: () {
                    context.push('/empresa/paradas');
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.login),
                    title: Text('Juan Pérez ingresó a Obra A'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Carlos Ruiz salió de Obra B'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.request_page),
                    title: Text('Nueva solicitud recibida'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 0,
      ),
    );
  }

  static Widget _metricCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
    bool anchoCompleto = false,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icono,
              color: color,
              size: 35,
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _actionCard({
    required String titulo,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}