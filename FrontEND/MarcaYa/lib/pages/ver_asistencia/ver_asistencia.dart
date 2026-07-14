import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';
import '../../components/empty_state_placeholder.dart';
import '../../src/api_service.dart';

class VerAsistenciaPage extends StatefulWidget {
  final int paradaId;

  const VerAsistenciaPage({super.key, required this.paradaId});

  @override
  State<VerAsistenciaPage> createState() => _VerAsistenciaPageState();
}

class _VerAsistenciaPageState extends State<VerAsistenciaPage> {
  List<dynamic> _registros = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data =
          await ApiService.instance.obtenerAsistenciaTiempoReal(widget.paradaId);
      setState(() {
        _registros = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar asistencia';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
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
              onPressed: _cargar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_registros.isEmpty) {
      return EmptyStatePlaceholder(
        icon: Icons.radio_button_checked,
        title: 'Esperando marcaciones...',
        description: 'No se registran entradas o salidas en esta parada el día de hoy.',
        actionLabel: 'Actualizar Monitor',
        onActionPressed: _cargar,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _registros.length,
      itemBuilder: (context, index) {
        final r = _registros[index] as Map<String, dynamic>;
        final empleado = r['empleado'];
        final nombreEmpleado = empleado is Map<String, dynamic>
            ? (empleado['nombre']?.toString() ?? '')
            : (r['nombre_empleado']?.toString() ?? '');
        final tipo = r['tipoMarcacion']?.toString() ??
            r['tipo_marcacion']?.toString() ??
            '—';
        final fecha = r['fechaHora']?.toString() ??
            r['fecha_hora']?.toString() ??
            '';

        return Card(
          child: ListTile(
            leading: nombreEmpleado.isNotEmpty
                ? CircleAvatar(child: Text(nombreEmpleado[0].toUpperCase()))
                : null,
            title: Text(nombreEmpleado.isNotEmpty ? nombreEmpleado : 'Empleado'),
            subtitle: Text('$tipo · $fecha'),
          ),
        );
      },
    );
  }
}
