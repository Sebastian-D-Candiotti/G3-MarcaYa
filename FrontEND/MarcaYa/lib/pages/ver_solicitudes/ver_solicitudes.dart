import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_navbar.dart';
import '../../src/api_service.dart';
import '../../providers/auth_provider.dart';

class VerSolicitudesPage extends StatefulWidget {
  const VerSolicitudesPage({super.key});

  @override
  State<VerSolicitudesPage> createState() => _VerSolicitudesPageState();
}

class _VerSolicitudesPageState extends State<VerSolicitudesPage> {
  List<dynamic> _solicitudes = [];
  List<dynamic> _obras = [];
  bool _cargando = true;
  bool _cargandoObras = false;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    setState(() => _cargandoObras = true);
    try {
      final auth = context.read<AuthProvider>();
      final empresaId = auth.currentUserProfile?.empresaId != null
          ? int.tryParse(auth.currentUserProfile!.empresaId!)
          : null;
      if (empresaId == null) {
        setState(() => _cargandoObras = false);
        return;
      }
      final data = await ApiService.instance.obtenerObras(empresaId: empresaId);
      setState(() {
        _obras = data;
        _cargandoObras = false;
      });
    } catch (e) {
      setState(() => _cargandoObras = false);
      debugPrint('Error al cargar obras: $e');
    }
  }

  Future<void> _cargarSolicitudes() async {
    try {
      final data = await ApiService.instance.obtenerSolicitudes();
      setState(() {
        _solicitudes = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      debugPrint('Error al cargar solicitudes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar solicitudes'),
        ),
      );
    }
  }

  /// Diálogo para seleccionar una obra de la empresa donde asignar al empleado.
  Future<int?> _seleccionarObra() async {
    if (_obras.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay obras disponibles. Primero creá una obra.')),
      );
      return null;
    }

    int? obraSeleccionada;

    return showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Asignar a obra'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seleccioná la obra donde asignar al empleado:'),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: obraSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Obra',
                    border: OutlineInputBorder(),
                  ),
                  items: _obras.map<DropdownMenuItem<int>>((o) {
                    return DropdownMenuItem(
                      value: o['id'] as int,
                      child: Text(o['nombre'] ?? 'Obra #${o['id']}'),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => obraSeleccionada = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: obraSeleccionada == null
                  ? null
                  : () => Navigator.pop(ctx, obraSeleccionada),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }

  void _verPerfil(dynamic solicitud) {
    final empleado = solicitud['empleado'];
    if (empleado == null) return;

    final usuarioId = empleado['usuario_id'];
    if (usuarioId == null) return;

    context.push(
      '/perfil-publico',
      extra: {'usuarioId': usuarioId as int},
    );
  }
  /// Diálogo para seleccionar una parada de la obra elegida.
  Future<int?> _seleccionarParada(int obraId) async {
    List<dynamic> paradas;
    try {
      paradas = await ApiService.instance.obtenerParadas(obraId);
    } catch (_) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar paradas de la obra')),
      );
      return null;
    }

    if (paradas.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redirigiendo para crear una parada...'),
        ),
      );
      // Navegar a crear parada preseleccionando la obra elegida
      context.push('/empresa/paradas/agregar', extra: obraId);
      return null;
    }

    int? paradaSeleccionada;

    return showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Asignar a parada'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seleccioná la parada donde el empleado marcará asistencia:'),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: paradaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Parada',
                    border: OutlineInputBorder(),
                  ),
                  items: paradas.map<DropdownMenuItem<int>>((p) {
                    return DropdownMenuItem(
                      value: p['id'] as int,
                      child: Text(p['nombre'] ?? 'Parada #${p['id']}'),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => paradaSeleccionada = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: paradaSeleccionada == null
                  ? null
                  : () => Navigator.pop(ctx, paradaSeleccionada),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }

  void _aceptarSolicitud(dynamic s) async {
    try {
      // 1. Seleccionar obra
      final obraId = await _seleccionarObra();
      if (obraId == null) return;

      // 2. Seleccionar parada de esa obra
      final paradaId = await _seleccionarParada(obraId);
      if (paradaId == null) return;

      // 3. Obtener empleado_id de la solicitud
      final empleadoId = s['empleado']?['id'] as int?;
      if (empleadoId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: no se pudo identificar al empleado')),
        );
        return;
      }

      // 4. Aceptar solicitud (crea asignación empleado → obra)
      await ApiService.instance.aceptarSolicitud(s['id'], obraId: obraId);

      // 5. Asignar empleado a la parada
      await ApiService.instance.asignarEmpleadoAParada(
        paradaId: paradaId,
        empleadoId: empleadoId,
      );

      if (!mounted) return;
      setState(() {
        _solicitudes.removeWhere((sol) => sol['id'] == s['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada — empleado asignado a obra y parada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _rechazarSolicitud(dynamic s) async {
    try {
      await ApiService.instance.rechazarSolicitud(s['id']);
      setState(() {
        _solicitudes.removeWhere((sol) => sol['id'] == s['id']); // elimina de la lista
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de ingreso')),
      body: _solicitudes.isEmpty
          ? const Center(child: Text('No hay solicitudes pendientes'))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _solicitudes.length,
        itemBuilder: (context, index) {
          final s = _solicitudes[index];
          final empleado = s['empleado'];
          final obra = s['obra'];

          return Card(
            child: ListTile(
              title: Text('${empleado?['nombre'] ?? ''} ${empleado?['apellido'] ?? ''}'),
              subtitle: Text('Obra: ${obra != null ? obra['nombre'] : 'No seleccionada'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _verPerfil(s),
                    child: const Text('Ver perfil'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _aceptarSolicitud(s),  // ⚡ Aquí elimina de la lista
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rechazarSolicitud(s),  // ⚡ Aquí elimina de la lista
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 2,
      ),
    );
  }
}