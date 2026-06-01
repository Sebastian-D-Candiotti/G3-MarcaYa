import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../src/api_service.dart';
import '../../components/bottom_navbar.dart';

class SolicitudesPage extends StatefulWidget {
  const SolicitudesPage({super.key});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  List<dynamic> solicitudes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
  }

  Future<void> cargarSolicitudes() async {
    try {
      final data = await ApiService.instance.obtenerSolicitudes(); // Trae de tu backend
      setState(() {
        solicitudes = data;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });
      debugPrint("Error al cargar solicitudes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de ingreso'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : solicitudes.isEmpty
          ? const Center(child: Text('No hay solicitudes pendientes'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: solicitudes.map((sol) {
            final empleado = sol['empleado'] ?? {};
            final obra = sol['obra'] ?? {};
            final fecha = sol['fecha'] ?? '';
            final estado = sol['estado'] ?? 'pendiente';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          empleado['nombre'] != null &&
                              empleado['nombre'].isNotEmpty
                              ? empleado['nombre'][0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(
                        '${empleado['nombre'] ?? ''} ${empleado['apellido'] ?? ''}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'DNI: ${empleado['documento'] ?? ''} | Obra: ${obra['nombre'] ?? ''}\nFecha: $fecha'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: estado == 'pendiente'
                              ? () {
                            // Lógica para aceptar
                          }
                              : null,
                          child: const Text('Aceptar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: estado == 'pendiente'
                              ? () {
                            // Lógica para rechazar
                          }
                              : null,
                          child: const Text('Rechazar'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            context.push(
                              '/perfil-publico',
                              extra: {
                                'usuarioId': empleado['id']
                              },
                            );
                          },
                          child: const Text('Ver perfil'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 0, // Navbar en 0 para la empresa
      ),
    );
  }
}