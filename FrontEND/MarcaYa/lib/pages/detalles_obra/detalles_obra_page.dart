import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../components/bottom_navbar.dart';

class DetallesObraPage extends StatefulWidget {
  final int obraId;
  final String obraNombre;

  const DetallesObraPage({
    super.key,
    required this.obraId,
    required this.obraNombre,
  });

  @override
  State<DetallesObraPage> createState() => _DetallesObraPageState();
}

class _DetallesObraPageState extends State<DetallesObraPage> {
  @override
  void initState() {
    super.initState();
    // Cargar estadísticas de la obra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.seleccionarObra({'id': widget.obraId, 'nombre': widget.obraNombre});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles - ${widget.obraNombre}'),
        centerTitle: true,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.reintentar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final stats = provider.estadisticas;
          if (stats == null) {
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Período
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Período: ${provider.periodo}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Métricas principales en grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMetricCard(
                      context,
                      'Horas Totales',
                      '${stats['attributes']?['horas_totales'] ?? stats['horas_totales'] ?? 0}h',
                      Icons.access_time,
                      Colors.blue,
                    ),
                    _buildMetricCard(
                      context,
                      'Promedio Horas',
                      '${stats['attributes']?['horas_promedio'] ?? stats['horas_promedio'] ?? 0}h',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildMetricCard(
                      context,
                      'Puntualidad',
                      '${stats['attributes']?['puntualidad_porcentaje'] ?? stats['puntualidad_porcentaje'] ?? 0}%',
                      Icons.check_circle,
                      Colors.teal,
                    ),
                    _buildMetricCard(
                      context,
                      'Días Trabajados',
                      '${stats['attributes']?['dias_trabajados'] ?? stats['dias_trabajados'] ?? 0}',
                      Icons.calendar_today,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Problemas/Irregularidades
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Irregularidades',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildIrregularityRow(
                          'Tardanzas',
                          stats['attributes']?['tardanzas_total'] ??
                              stats['tardanzas_total'] ??
                              0,
                          Colors.amber,
                        ),
                        _buildIrregularityRow(
                          'Faltas',
                          stats['attributes']?['faltas_total'] ??
                              stats['faltas_total'] ??
                              0,
                          Colors.red,
                        ),
                        _buildIrregularityRow(
                          'Fake GPS',
                          stats['attributes']?['fake_gps_intentos'] ??
                              stats['fake_gps_intentos'] ??
                              0,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Información de la obra
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de la Obra',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Nombre', widget.obraNombre),
                        if (stats['attributes']?['empleados_activos'] !=
                                null ||
                            stats['empleados_activos'] != null)
                          _buildInfoRow(
                            'Empleados Activos',
                            '${stats['attributes']?['empleados_activos'] ?? stats['empleados_activos'] ?? 0}',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detalles por empleado si disponible
                if (stats['attributes']?['datos_por_empleado'] != null ||
                    stats['datos_por_empleado'] != null)
                  _buildEmpleadosSection(
                    context,
                    stats['attributes']?['datos_por_empleado'] ??
                        stats['datos_por_empleado'],
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavbar(
        userRole: 'empresa',
        currentIndex: 3,
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIrregularityRow(String label, dynamic count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpleadosSection(
    BuildContext context,
    List<dynamic>? empleados,
  ) {
    if (empleados == null || empleados.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles por Empleado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...empleados.map((emp) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp['nombre'] ?? 'Empleado desconocido',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Horas: ${emp['horas_trabajadas'] ?? 0}'),
                        Text('Tardanzas: ${emp['tardanzas'] ?? 0}'),
                        Text('Faltas: ${emp['faltas'] ?? 0}'),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
