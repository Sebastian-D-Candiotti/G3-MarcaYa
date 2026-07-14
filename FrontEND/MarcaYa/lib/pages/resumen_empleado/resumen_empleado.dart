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
  List<dynamic> obras = [];
  bool cargando = true;
  int _obrasAsistidasCount = 0;
  int _solicitudesCount = 0;
  bool _cargandoMetricas = true;
  dynamic _activeShift;

  @override
  void initState() {
    super.initState();
    _cargarObrasAprobadas();
  }

  String _formatHora(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _cargarObrasAprobadas() async {
    final auth = context.read<AuthProvider>();
    final empleadoId = auth.currentUserProfile?.employeeId;
    if (empleadoId == null) {
      setState(() {
        cargando = false;
        _cargandoMetricas = false;
      });
      return;
    }
    try {
      final lista = await ApiService.instance
          .obtenerObrasEmpleado(empleadoId);
      if (mounted) {
        setState(() {
          obras = lista;
          cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => cargando = false);
      }
      debugPrint('Error al cargar obras aprobadas: $e');
    }

    try {
      final historialFuture = ApiService.instance.obtenerHistorial();
      final solicitudesFuture = ApiService.instance.obtenerSolicitudesEmpleado(empleadoId);

      final results = await Future.wait([historialFuture, solicitudesFuture]);
      final List<dynamic> historial = results[0];
      final List<dynamic> solicitudes = results[1];

      final uniqueObras = <dynamic>{};
      dynamic activeShift;

      // Sort history descending (newest first) to find if there is an active check-in
      historial.sort((a, b) {
        final fechaA = a['hora_entrada'] ?? a['created_at'] ?? '';
        final fechaB = b['hora_entrada'] ?? b['created_at'] ?? '';
        return fechaB.toString().compareTo(fechaA.toString());
      });

      if (historial.isNotEmpty) {
        final firstItem = historial.first;
        if (firstItem['hora_entrada'] != null && firstItem['hora_salida'] == null) {
          activeShift = firstItem;
        }
      }

      for (var record in historial) {
        final obraId = record['obra_id'] ?? record['obra']?['id'];
        final obraNombre = record['obra_nombre'] ?? record['obra']?['nombre'];
        if (obraId != null) {
          uniqueObras.add(obraId);
        } else if (obraNombre != null && obraNombre.toString().isNotEmpty) {
          uniqueObras.add(obraNombre);
        }
      }

      if (mounted) {
        setState(() {
          _obrasAsistidasCount = uniqueObras.length;
          _solicitudesCount = solicitudes.length;
          _activeShift = activeShift;
          _cargandoMetricas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoMetricas = false);
      }
      debugPrint('Error al cargar metricas: $e');
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 35,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          _cargandoMetricas
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _obrasAsistidasCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          const Text('Obras asistidas'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.send,
                            size: 35,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _cargandoMetricas
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _solicitudesCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          const Text('Solicitudes'),
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

            const SizedBox(height: 10),

            // Acceso directo al historial de marcaciones (US-NUEVA-09 CA-3)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/empleado/historial-asistencias');
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text('Ver historial de marcaciones'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A3A5),
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Integración de Pagos: historial de cobros del empleado
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/empleado/historial-cobros');
                },
                icon: const Icon(Icons.account_balance_wallet_rounded),
                label: const Text('Historial de cobros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4F7A),
                  foregroundColor: Colors.white,
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

            _cargandoMetricas
                ? const Center(child: CircularProgressIndicator())
                : _activeShift == null
                    ? Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.work_off_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Sin obra en curso',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'No tienes una marcación de entrada activa. Selecciona una de tus obras aprobadas a continuación para marcar asistencia.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Card(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.play_circle_fill_rounded,
                                size: 40,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _activeShift['obra_nombre'] ?? _activeShift['obra']?['nombre'] ?? 'Obra en curso',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Marcación de entrada registrada a las ${_formatHora(_activeShift['hora_entrada'])}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

            const SizedBox(height: 30),

            const Text('Mis Obras Aprobadas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            cargando
                ? const Center(child: CircularProgressIndicator())
                : obras.isEmpty
                ? Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.business_center_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aún no tienes obras aprobadas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Debes unirte a una obra para registrar asistencias. Busca una empresa o solicita acceso.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/empleado/buscar'),
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Buscar Empresas / Obras'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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