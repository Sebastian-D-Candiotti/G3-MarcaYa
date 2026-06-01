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
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
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

  void _aceptar(dynamic solicitud) async {
    try {
      await ApiService.instance.aceptarSolicitud(solicitud['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Solicitud de ${solicitud['empleado']?['nombre'] ?? 'Anónimo'} aceptada'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarSolicitudes();
    } catch (e) {
      debugPrint('Error aceptar solicitud: $e');
    }
  }

  void _rechazar(dynamic solicitud) async {
    try {
      await ApiService.instance.rechazarSolicitud(solicitud['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Solicitud de ${solicitud['empleado']?['nombre'] ?? 'Anónimo'} rechazada'),
          backgroundColor: Colors.red,
        ),
      );
      _cargarSolicitudes();
    } catch (e) {
      debugPrint('Error rechazar solicitud: $e');
    }
  }

  void _verPerfil(dynamic solicitud) {
    final empleado = solicitud['empleado'];
    if (empleado == null) return;

    // Navega al perfil del empleado pasando el ID
    context.push(
      '/empleado/perfil', // Asegúrate que esta ruta está registrada en tu app_router.dart
      extra: {'usuarioId': empleado['id']},
    );
  }
  void _aceptarSolicitud(dynamic s) async {
    try {
      await ApiService.instance.aceptarSolicitud(s['id']);
      setState(() {
        _solicitudes.removeWhere((sol) => sol['id'] == s['id']); // elimina de la lista
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada')),
      );
    } catch (e) {
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
              subtitle: Text('Obra: ${obra?['nombre'] ?? ''}'),
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
        currentIndex: 0,
      ),
    );
  }
}