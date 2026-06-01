import 'package:flutter/material.dart';
import '../ver_empleados_styles.dart';

/// Summary card showing the total number of active employees.
class EmpleadoSummaryCard extends StatelessWidget {
  final int totalActivos;

  const EmpleadoSummaryCard({super.key, required this.totalActivos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: VerEmpleadosStyles.summaryCardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total de empleados',
                style: VerEmpleadosStyles.summaryLabel,
              ),
              const SizedBox(height: 2),
              Text(
                '$totalActivos',
                style: VerEmpleadosStyles.summaryValue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
