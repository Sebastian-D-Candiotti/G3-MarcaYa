import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';
import '../../core/theme/app_theme.dart';
import 'empleado_model.dart';
import 'ver_empleados_styles.dart';
import 'components/empleado_summary_card.dart';
import 'components/empleado_search_bar.dart';
import 'components/empleado_card.dart';
import 'components/empleado_detail_sheet.dart';

/// Employee list screen. Composed from reusable components.
class EmpleadosActualesPage extends StatefulWidget {
  const EmpleadosActualesPage({super.key});

  @override
  State<EmpleadosActualesPage> createState() => _EmpleadosActualesPageState();
}

class _EmpleadosActualesPageState extends State<EmpleadosActualesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // TODO: replace with real backend data
  static final List<Empleado> _empleados = [
    Empleado(
      id: '1',
      nombre: 'Wilson García',
      dni: '12345678',
      iniciales: 'WG',
      avatarColor: const Color(0xFF1565C0),
      asistencias: 22,
      tardanzas: 1,
    ),
    Empleado(
      id: '2',
      nombre: 'Andre Silva',
      dni: '87654321',
      iniciales: 'AS',
      avatarColor: const Color(0xFF00897B),
      asistencias: 19,
      tardanzas: 3,
    ),
    Empleado(
      id: '3',
      nombre: 'Miguel Torres',
      dni: '11223344',
      iniciales: 'MT',
      avatarColor: const Color(0xFF6A1B9A),
      asistencias: 21,
      tardanzas: 0,
    ),
    Empleado(
      id: '4',
      nombre: 'Gustavo Paz',
      dni: '44332211',
      iniciales: 'GP',
      avatarColor: const Color(0xFF558B2F),
      asistencias: 18,
      tardanzas: 5,
    ),
    Empleado(
      id: '5',
      nombre: 'Henry Castro',
      dni: '55667788',
      iniciales: 'HC',
      avatarColor: const Color(0xFFC62828),
      asistencias: 15,
      tardanzas: 1,
    ),
  ];

  List<Empleado> get _filtrados {
    if (_query.isEmpty) return _empleados;
    final q = _query.toLowerCase();
    return _empleados.where((e) {
      return e.nombre.toLowerCase().contains(q) ||
          e.dni.contains(q) ||
          e.iniciales.toLowerCase().contains(q);
    }).toList();
  }

  int get _totalActivos =>
      _empleados.where((e) => e.estado == EstadoEmpleado.activo).length;

  // ── Actions ────────────────────────────────────────────────────

  void _desactivar(Empleado e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VerEmpleadosStyles.cardRadius)),
        title: const Text('Desactivar empleado',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text(
          '¿Estás seguro de que deseas desactivar a ${e.nombre}?\n\n'
          'El sistema verificará que no tenga marcaciones activas antes de proceder.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => e.estado = EstadoEmpleado.inactivo);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${e.nombre} fue desactivado'),
                  backgroundColor: Colors.grey[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: VerEmpleadosStyles.desactivarButtonStyle(),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  void _verDetalle(Empleado e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EmpleadoDetailSheet(empleado: e),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Empleados')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          EmpleadoSummaryCard(totalActivos: _totalActivos),
          const SizedBox(height: 12),
          EmpleadoSearchBar(
            controller: _searchController,
            query: _query,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          if (lista.isEmpty)
            _buildEmptyState()
          else
            ...lista.map((e) => EmpleadoCard(
                  empleado: e,
                  onTap: () => _verDetalle(e),
                  onDesactivar: () => _desactivar(e),
                )),
          const SizedBox(height: 8),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Sin resultados para "$_query"',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
