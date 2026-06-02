import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';

class ResumenEmpleadoPage extends StatefulWidget {
  const ResumenEmpleadoPage({super.key});

  @override
  State<ResumenEmpleadoPage> createState() => _ResumenEmpleadoPageState();
}

class _ResumenEmpleadoPageState extends State<ResumenEmpleadoPage> {
  List<dynamic> obras = [];   // ← aquí van
  bool cargando = true;       // ← aquí van

  @override
  void initState() {
    super.initState();
    _cargarObrasAprobadas();
  }
  Future<void> _cargarObrasAprobadas() async {
    final auth = context.read<AuthProvider>();
    final empleadoId = auth.currentUserProfile?.employeeId;
    if (empleadoId == null) {
      setState(() => cargando = false);
      return;
    }
    try {
      final lista = await ApiService.instance
          .obtenerObrasEmpleado(empleadoId);
      setState(() {
        obras = lista;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      debugPrint('Error al cargar obras aprobadas: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${auth.state.currentUser?.name ?? ''}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.business,
                            size: 35,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '3',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Obras asistidas'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.send,
                            size: 35,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '5',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Solicitudes'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/empleado/solicitudes');
                },
                icon: const Icon(Icons.history),
                label: const Text(
                  'Ver historial de solicitudes',
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Obras actuales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

        const SizedBox(height: 30),

            const Text('Mis Obras Aprobadas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            cargando
                ? const Center(child: CircularProgressIndicator())
                : obras.isEmpty
                ? const Text('No tienes obras aprobadas')
                : Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Obra')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Acción')),
                  ],

                    rows: obras.map<DataRow>((obra) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(obra['nombre'] ?? ''),
                          ),

                          const DataCell(
                            Text('Activo'),
                          ),

                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                if (obra['latitud'] != null &&
                                    obra['longitud'] != null &&
                                    obra['radio'] != null) {

                                  context.push(
                                    '/empleado/marcar_asistencia',
                                    extra: {
                                      'obraId': obra['id'],
                                      'obraNombre': obra['nombre'],
                                      'latitud': obra['latitud'].toDouble(),
                                      'longitud': obra['longitud'].toDouble(),
                                      'radio': obra['radio'].toDouble(),
                                    },
                                  );

                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No se puede marcar asistencia: datos de ubicación incompletos',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Asistencia'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empleado',
        currentIndex: 0,
      ),
    );
  }
}