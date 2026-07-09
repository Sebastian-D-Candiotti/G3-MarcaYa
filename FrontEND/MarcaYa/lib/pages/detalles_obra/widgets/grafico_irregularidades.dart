import 'package:flutter/material.dart';
import '../../../models/estadisticas_obra.dart';
import '../../../theme/app_theme.dart';

/// Summary widget showing irregularities breakdown: tardanzas, faltas, fake GPS.
/// Displays per-employee data in a compact list format.
class GraficoIrregularidades extends StatelessWidget {
  const GraficoIrregularidades({
    super.key,
    required this.tardanzasTotal,
    required this.faltasTotal,
    required this.fakeGpsIntentos,
    required this.datosPorEmpleado,
  });

  final int tardanzasTotal;
  final int faltasTotal;
  final int fakeGpsIntentos;
  final List<DatosEmpleado> datosPorEmpleado;

  @override
  Widget build(BuildContext context) {
    final totalIrregularidades = tardanzasTotal + faltasTotal + fakeGpsIntentos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Irregularidades',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Summary row
        Row(
          children: [
            _buildSummaryChip(
              'Tardanzas',
              tardanzasTotal,
              AppColors.warning,
            ),
            const SizedBox(width: 8),
            _buildSummaryChip(
              'Faltas',
              faltasTotal,
              AppColors.error,
            ),
            const SizedBox(width: 8),
            _buildSummaryChip(
              'Fake GPS',
              fakeGpsIntentos,
              const Color(0xFF8B5CF6),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Per-employee breakdown (only those with irregularities)
        if (totalIrregularidades > 0) ...[
          const Text(
            'Empleados con irregularidades',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ..._employeesWithIrregularities().map(
            (e) => _buildEmployeeRow(e),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              'Sin irregularidades registradas',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  List<DatosEmpleado> _employeesWithIrregularities() {
    return datosPorEmpleado
        .where((e) => e.tardanzas + e.faltas + e.fakeGps > 0)
        .toList()
      ..sort((a, b) {
        final aTotal = a.tardanzas + a.faltas + a.fakeGps;
        final bTotal = b.tardanzas + b.faltas + b.fakeGps;
        return bTotal.compareTo(aTotal);
      });
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(DatosEmpleado empleado) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
          if (empleado.tardanzas > 0)
            _buildMiniBadge('${empleado.tardanzas}T', AppColors.warning),
          if (empleado.faltas > 0) ...[
            const SizedBox(width: 4),
            _buildMiniBadge('${empleado.faltas}F', AppColors.error),
          ],
          if (empleado.fakeGps > 0) ...[
            const SizedBox(width: 4),
            _buildMiniBadge(
              '${empleado.fakeGps}G',
              const Color(0xFF8B5CF6),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
