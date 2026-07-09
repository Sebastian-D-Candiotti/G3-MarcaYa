import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/estadisticas_obra.dart';
import '../../theme/app_theme.dart';
import 'widgets/metricas_card.dart';
import 'widgets/grafico_horas.dart';
import 'widgets/grafico_puntualidad.dart';
import 'widgets/grafico_irregularidades.dart';

class DetallesObraPage extends StatefulWidget {
  const DetallesObraPage({
    super.key,
    required this.obraId,
    this.obraNombre,
  });

  final int obraId;
  final String? obraNombre;

  @override
  State<DetallesObraPage> createState() => _DetallesObraPageState();
}

class _DetallesObraPageState extends State<DetallesObraPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().cargarEstadisticas(widget.obraId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.obraNombre ?? 'Detalles de Obra'),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar estadísticas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.cargarEstadisticas(widget.obraId),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = provider.estadisticas;
          if (stats == null) {
            return const Center(
              child: Text(
                'Sin datos disponibles',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            );
          }

          return _buildContent(stats);
        },
      ),
    );
  }

  Widget _buildContent(EstadisticasObra stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary metrics grid
          _buildMetricsGrid(stats),
          const SizedBox(height: 24),
          // Punctuality chart
          GraficoPuntualidad(
            puntualidadPorcentaje: stats.puntualidadPorcentaje,
          ),
          const SizedBox(height: 24),
          // Irregularities summary
          GraficoIrregularidades(
            tardanzasTotal: stats.tardanzasTotal,
            faltasTotal: stats.faltasTotal,
            fakeGpsIntentos: stats.fakeGpsIntentos,
            datosPorEmpleado: stats.datosPorEmpleado,
          ),
          const SizedBox(height: 24),
          // Hours chart
          GraficoHoras(datosPorEmpleado: stats.datosPorEmpleado),
          const SizedBox(height: 24),
          // Employee breakdown
          _buildEmployeeBreakdown(stats.datosPorEmpleado),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(EstadisticasObra stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricasCard(
                titulo: 'Horas Totales',
                valor: stats.horasTotales.toStringAsFixed(1),
                icono: Icons.access_time,
                subtitulo: '${stats.horasPromedio.toStringAsFixed(1)}h promedio',
                colorDesde: const Color(0xFF38A3A5),
                colorHasta: const Color(0xFF22577A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricasCard(
                titulo: 'Días Trabajados',
                valor: stats.diasTrabajados.toString(),
                icono: Icons.calendar_today,
                subtitulo: 'días en el periodo',
                colorDesde: const Color(0xFF8B5CF6),
                colorHasta: const Color(0xFF6D28D9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricasCard(
                titulo: 'Empleados Activos',
                valor: stats.empleadosActivos.toString(),
                icono: Icons.people,
                subtitulo: '${stats.empleadosConIrregularidades} con irregularidades',
                colorDesde: const Color(0xFF10B981),
                colorHasta: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricasCard(
                titulo: 'Tardanzas',
                valor: stats.tardanzasTotal.toString(),
                icono: Icons.schedule,
                subtitulo: '${stats.faltasTotal} faltas',
                colorDesde: const Color(0xFFF59E0B),
                colorHasta: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeBreakdown(List<DatosEmpleado> employees) {
    if (employees.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desglose por Empleado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Empleado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Horas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Falt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'GPS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...employees.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          e.nombre,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.horasTrabajadas.toStringAsFixed(1),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.tardanzas.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: e.tardanzas > 0
                                ? AppColors.warning
                                : AppColors.textPrimary,
                            fontWeight: e.tardanzas > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.faltas.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: e.faltas > 0
                                ? AppColors.error
                                : AppColors.textPrimary,
                            fontWeight: e.faltas > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.fakeGps.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: e.fakeGps > 0
                                ? const Color(0xFF8B5CF6)
                                : AppColors.textPrimary,
                            fontWeight: e.fakeGps > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
