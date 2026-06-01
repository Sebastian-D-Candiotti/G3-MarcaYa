import 'package:flutter/material.dart';
import '../../src/api_service.dart';

class HistorialSolicitudesPage extends StatefulWidget {
  final String empleadoId;

  const HistorialSolicitudesPage({
    super.key,
    required this.empleadoId,
  });

  @override
  State<HistorialSolicitudesPage> createState() =>
      _HistorialSolicitudesPageState();
}

class _HistorialSolicitudesPageState
    extends State<HistorialSolicitudesPage> {

  List<dynamic> solicitudes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    try {
      final data = await ApiService.instance
          .obtenerSolicitudesEmpleado(widget.empleadoId);

      setState(() {
        solicitudes = data;
        cargando = false;
      });
    } catch (e) {
      debugPrint('Error: $e');

      setState(() {
        cargando = false;
      });
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aceptada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de solicitudes'),
      ),
      body: cargando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : solicitudes.isEmpty
          ? const Center(
        child: Text(
          'No hay solicitudes registradas',
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: solicitudes.length,
        itemBuilder: (context, index) {
          final solicitud = solicitudes[index];
          final obra = solicitud['obra'];
          final estado = solicitud['estado'];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Padding(
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    obra?['nombre'] ??
                        'Obra desconocida',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Text(
                        'Estado: ',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      Text(
                        estado,
                        style: TextStyle(
                          color:
                          _colorEstado(
                              estado),
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}