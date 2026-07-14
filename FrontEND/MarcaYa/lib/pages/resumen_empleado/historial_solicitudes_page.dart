import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';

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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.find_in_page_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay solicitudes registradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aún no has solicitado unirte a ninguna obra o empresa. Busca opciones disponibles para enviar tu primera solicitud.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/empleado/buscar'),
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Buscar Empresas / Obras'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: solicitudes.length,
        itemBuilder: (context, index) {
          final solicitud = solicitudes[index];
          final empresa = solicitud['empresa'] as Map<String, dynamic>?;
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
                    empresa?['nombre']?.toString() ?? 'Empresa',
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