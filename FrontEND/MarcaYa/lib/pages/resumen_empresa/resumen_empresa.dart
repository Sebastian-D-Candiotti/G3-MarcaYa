import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';

class ResumenEmpresaPage extends StatefulWidget {
  const ResumenEmpresaPage({super.key});

  @override
  State<ResumenEmpresaPage> createState() => _ResumenEmpresaPageState();
}

class _ResumenEmpresaPageState extends State<ResumenEmpresaPage> {
  int _asistenciasTotales = 0;
  int _paradasActivas = 0;
  double _tendencia = 0.0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final auth = context.read<AuthProvider>();
      final empresaId = auth.currentUserProfile?.empresaId != null
          ? int.tryParse(auth.currentUserProfile!.empresaId!)
          : null;

      if (empresaId == null) {
        if (mounted) setState(() => _cargando = false);
        return;
      }

      // ── 1. Obtener obras de la empresa ──────────────────
      final obras = await ApiService.instance.obtenerObras(empresaId: empresaId);

      // ── 2. Contar paradas activas en todas las obras ────
      int activas = 0;
      for (final obra in obras) {
        try {
          final paradas =
              await ApiService.instance.obtenerParadas(obra['id'] as int);
          for (final parada in paradas) {
            if (parada['estado'] == 'activo') activas++;
          }
        } catch (_) {
          // Si falla una obra, seguimos con las demás
        }
      }

      // ── 3. Asistencias de hoy ───────────────────────────
      final hoy = DateTime.now().toString().split(' ')[0];
      final asistenciasHoy = await ApiService.instance
          .obtenerReporteAsistencia(fechaInicio: hoy, fechaFin: hoy);

      // ── 4. Asistencias de ayer para tendencia ───────────
      final ayer =
          DateTime.now().subtract(const Duration(days: 1)).toString().split(' ')[0];
      final asistenciasAyer = await ApiService.instance
          .obtenerReporteAsistencia(fechaInicio: ayer, fechaFin: ayer);

      // ── 5. Calcular tendencia ───────────────────────────
      final hoyCount = asistenciasHoy.length;
      final ayerCount = asistenciasAyer.length;
      double tendencia = 0.0;
      if (ayerCount > 0) {
        tendencia = ((hoyCount - ayerCount) / ayerCount) * 100;
      }

      if (mounted) {
        setState(() {
          _asistenciasTotales = hoyCount;
          _paradasActivas = activas;
          _tendencia = tendencia;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando datos del resumen: $e');
      if (mounted) setState(() => _cargando = false);
    }
  }

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
            icon: const Icon(
              Icons.logout,
              color: AppColors.error,
            ),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          valor: _asistenciasTotales.toString(),
                          icono: Icons.fact_check,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _metricCard(
                          titulo: 'Paradas',
                          valor: _paradasActivas.toString(),
                          icono: Icons.location_on,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _metricCard(
                    titulo: 'Tendencia vs Ayer',
                    valor: _tendencia >= 0
                        ? '+${_tendencia.toStringAsFixed(1)}%'
                        : '${_tendencia.toStringAsFixed(1)}%',
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
                        titulo: 'Mis Obras',
                        icono: Icons.business,
                        color: Colors.teal,
                        onTap: () {
                          context.push('/empresa/obras');
                        },
                      ),

                      _actionCard(
                        titulo: 'Nueva Obra',
                        icono: Icons.add_business,
                        color: Colors.orange,
                        onTap: () {
                          context.push('/empresa/obras/agregar');
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
