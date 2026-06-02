import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/bottom_navbar.dart';
import '../../src/api_service.dart';
import '../ver_empleados/empleado_model.dart';
import '../ver_empleados/components/empleado_card.dart';

const _avatarColors = [
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.indigo,
  Colors.cyan,
];

/// Internal grouping helper.
class _ObraGroup {
  final String obraNombre;
  final List<Empleado> empleados;

  const _ObraGroup({required this.obraNombre, required this.empleados});
}

/// Holds raw employee data alongside computed [Empleado] and obras.
class _EmpleadoEnriquecido {
  final Empleado empleado;
  final List<dynamic> obras;

  const _EmpleadoEnriquecido({required this.empleado, required this.obras});
}

class EmpleadosActualesPage extends StatefulWidget {
  const EmpleadosActualesPage({super.key});

  @override
  State<EmpleadosActualesPage> createState() => _EmpleadosActualesPageState();
}

class _EmpleadosActualesPageState extends State<EmpleadosActualesPage> {
  List<_ObraGroup> _grupos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  // ── helpers ─────────────────────────────────────────────────

  static String _iniciales(Map<String, dynamic> emp) {
    final n = (emp['nombre'] ?? '').toString();
    final a = (emp['apellido'] ?? '').toString();
    return '${n.isNotEmpty ? n[0].toUpperCase() : ''}${a.isNotEmpty ? a[0].toUpperCase() : ''}';
  }

  static Color _avatarColor(Map<String, dynamic> emp) {
    final name = '${emp['nombre'] ?? ''}${emp['apellido'] ?? ''}';
    final hash = name.hashCode.abs();
    return _avatarColors[hash % _avatarColors.length];
  }

  // ── data loading ────────────────────────────────────────────

  Future<void> _cargarEmpleados() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final empleados = await ApiService.instance.obtenerEmpleadosActuales();
      final grupos = await _procesarEmpleados(empleados);
      if (!mounted) return;
      setState(() {
        _grupos = grupos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar empleados';
        _cargando = false;
      });
    }
  }

  Future<List<_ObraGroup>> _procesarEmpleados(
      List<dynamic> empleados) async {
    // Fetch asistencias and obras per employee in parallel
    final enriquecidos =
        await Future.wait(empleados.map((emp) => _enriquecer(emp)));

    // Group by obra name
    final Map<String, List<Empleado>> grouped = {};
    for (final item in enriquecidos) {
      if (item.obras.isEmpty) {
        grouped.putIfAbsent('General', () => []).add(item.empleado);
      } else {
        for (final obra in item.obras) {
          final nombre = obra['nombre']?.toString() ?? 'General';
          grouped.putIfAbsent(nombre, () => []).add(item.empleado);
        }
      }
    }

    return grouped.entries
        .map((e) => _ObraGroup(
              obraNombre: e.key,
              empleados: e.value,
            ))
        .toList();
  }

  Future<_EmpleadoEnriquecido> _enriquecer(Map<String, dynamic> emp) async {
    final id = int.parse(emp['id'].toString());
    final idStr = emp['id'].toString();

    final results = await Future.wait([
      ApiService.instance.obtenerAsistenciasEmpleado(id),
      ApiService.instance.obtenerObrasEmpleado(idStr),
    ]);

    final asistencias = results[0] as List<dynamic>;
    final obras = results[1] as List<dynamic>;

    final asistenciasCount =
        asistencias.where((r) => r['tipoMarcacion'] == 'entrada').length;

    final empleado = Empleado(
      id: idStr,
      nombre: '${emp['nombre']} ${emp['apellido']}',
      dni: emp['dni'] ?? '',
      iniciales: _iniciales(emp),
      avatarColor: _avatarColor(emp),
      asistencias: asistenciasCount,
      tardanzas: 0,
      estado: EstadoEmpleado.activo,
    );

    return _EmpleadoEnriquecido(empleado: empleado, obras: obras);
  }

  // ── actions ─────────────────────────────────────────────────

  Future<void> _desactivarEmpleado(Empleado empleado) async {
    try {
      await ApiService.instance.desactivarEmpleado(int.parse(empleado.id));
      await _cargarEmpleados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al desactivar: $e')),
      );
    }
  }

  // ── build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 3,
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarEmpleados,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_grupos.isEmpty ||
        _grupos.every((g) => g.empleados.isEmpty)) {
      return const Center(child: Text('No hay empleados'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _grupos.length,
      itemBuilder: (context, index) {
        final grupo = _grupos[index];
        return _buildObraSection(grupo);
      },
    );
  }

  Widget _buildObraSection(_ObraGroup grupo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ──────────────────────────────
            Row(
              children: [
                const Icon(Icons.construction, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    grupo.obraNombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${grupo.empleados.length} empleados',
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            // ── Employee cards ─────────────────────────────
            ...grupo.empleados.map(
              (empleado) => EmpleadoCard(
                empleado: empleado,
                onTap: () => context.push(
                  '/perfil-publico',
                  extra: {'usuarioId': empleado.id},
                ),
                onDesactivar: () => _desactivarEmpleado(empleado),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
