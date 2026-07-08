import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'widgets/metricas_card.dart';
import 'widgets/grafico_horas.dart';
import 'widgets/grafico_puntualidad.dart';
import 'widgets/grafico_irregularidades.dart';
import 'widgets/filtro_obra.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().cargarEstadisticas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Indicadores'),
        elevation: 0,
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.cargarEstadisticas(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.estadisticas == null) {
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro de obra
                if (provider.obras.isNotEmpty)
                  FiltroObraWidget(
                    obras: provider.obras,
                    obraSeleccionada: provider.obraSeleccionada,
                    onObraSeleccionada: (obra) {
                      provider.seleccionarObra(obra);
                    },
                  ),
                const SizedBox(height: 24),

                // Periodo
                Text(
                  'Periodo: ${_obtenerMesAnio()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Tarjetas de métricas principales
                Row(
                  children: [
                    Expanded(
                      child: MetricasCard(
                        titulo: 'Horas Promedio',
                        valor: '${provider.estadisticas?['horas_promedio'] ?? 0}h',
                        icono: Icons.schedule,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricasCard(
                        titulo: 'Puntualidad',
                        valor: '${provider.estadisticas?['puntualidad_porcentaje'] ?? 0}%',
                        icono: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: MetricasCard(
                        titulo: 'Tardanzas',
                        valor: '${provider.estadisticas?['tardanzas_total'] ?? 0}',
                        icono: Icons.timer_off,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricasCard(
                        titulo: 'Faltas',
                        valor: '${provider.estadisticas?['faltas_total'] ?? 0}',
                        icono: Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Gráfico de horas
                const Text(
                  'Horas Trabajadas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GraficoHorasWidget(
                  datos: provider.estadisticas?['datos_diarios'] ?? [],
                ),
                const SizedBox(height: 24),

                // Gráfico de puntualidad
                const Text(
                  'Puntualidad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GraficoPuntualidadWidget(
                  puntualidad: provider.estadisticas?['puntualidad_porcentaje'] ?? 0,
                ),
                const SizedBox(height: 24),

                // Gráfico de irregularidades
                const Text(
                  'Irregularidades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GraficoIrregularidadesWidget(
                  tardanzas: provider.estadisticas?['tardanzas_total'] ?? 0,
                  faltas: provider.estadisticas?['faltas_total'] ?? 0,
                  fakeGps: provider.estadisticas?['fake_gps_intentos'] ?? 0,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  String _obtenerMesAnio() {
    final ahora = DateTime.now();
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${meses[ahora.month - 1]} ${ahora.year}';
  }
}
