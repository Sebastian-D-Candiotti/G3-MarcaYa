import 'package:flutter/material.dart';
import '../../../models/estadisticas_obra.dart';
import '../../../theme/app_theme.dart';

/// Horizontal bar chart showing hours worked per employee.
/// Uses [LinearProgressIndicator] for each employee — no external chart libs.
class GraficoHoras extends StatelessWidget {
  const GraficoHoras({super.key, required this.datosPorEmpleado});

  final List<DatosEmpleado> datosPorEmpleado;

  @override
  Widget build(BuildContext context) {
    if (datosPorEmpleado.isEmpty) {
      return _buildEmptyState('Sin datos de horas');
    }

    // Sort by hours descending, take top 10 for readability
    final sorted = List<DatosEmpleado>.from(datosPorEmpleado)
      ..sort((a, b) => b.horasTrabajadas.compareTo(a.horasTrabajadas));
    final top = sorted.take(10).toList();

    final maxHours = top.first.horasTrabajadas;
    if (maxHours <= 0) {
      return _buildEmptyState('Sin datos de horas');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horas por Empleado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...top.map((e) => _buildBar(e, maxHours)),
      ],
    );
  }

  Widget _buildBar(DatosEmpleado empleado, double maxHours) {
    final fraction = maxHours > 0
        ? (empleado.horasTrabajadas / maxHours).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  empleado.nombre,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${empleado.horasTrabajadas.toStringAsFixed(1)}h',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
