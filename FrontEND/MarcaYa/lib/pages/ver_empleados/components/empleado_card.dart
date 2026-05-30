import 'package:flutter/material.dart';
import '../empleado_model.dart';
import '../ver_empleados_styles.dart';

/// Individual employee card showing avatar, info, metrics, and actions.
class EmpleadoCard extends StatelessWidget {
  final Empleado empleado;
  final VoidCallback onTap;
  final VoidCallback onDesactivar;

  const EmpleadoCard({
    super.key,
    required this.empleado,
    required this.onTap,
    required this.onDesactivar,
  });

  @override
  Widget build(BuildContext context) {
    final isInactivo = empleado.estado == EstadoEmpleado.inactivo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: VerEmpleadosStyles.empleadoCardDecoration(
            isInactivo: isInactivo),
        child: Row(
          children: [
            _buildAvatar(isInactivo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameRow(isInactivo),
                  const SizedBox(height: 2),
                  _buildDni(),
                  const SizedBox(height: 10),
                  if (!isInactivo) _buildMetricsRow(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActions(isInactivo),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isInactivo) {
    return Stack(
      children: [
        CircleAvatar(
          radius: VerEmpleadosStyles.avatarRadius,
          backgroundColor:
              isInactivo ? Colors.grey[400] : empleado.avatarColor,
          child: Text(
            empleado.iniciales,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        if (isInactivo)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: VerEmpleadosStyles.inactivoDotDecoration(),
            ),
          ),
      ],
    );
  }

  Widget _buildNameRow(bool isInactivo) {
    return Row(
      children: [
        Expanded(
          child: Text(
            empleado.nombre,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isInactivo
                  ? VerEmpleadosStyles.inactivoText
                  : VerEmpleadosStyles.textDark,
            ),
          ),
        ),
        if (isInactivo)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: VerEmpleadosStyles.estadoBadgeDecoration(),
            child: const Text(
              'Inactivo',
              style: TextStyle(
                fontSize: 11,
                color: VerEmpleadosStyles.inactivoText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDni() {
    return Text(
      'DNI: ${empleado.dni}',
      style: const TextStyle(
          fontSize: 12, color: VerEmpleadosStyles.inactivoText),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        _buildMetric(
          'Asistencias',
          empleado.asistencias,
          VerEmpleadosStyles.asistBg,
          VerEmpleadosStyles.asistColor,
        ),
        const SizedBox(width: 8),
        _buildMetric(
          'Tardanzas',
          empleado.tardanzas,
          VerEmpleadosStyles.tardBg,
          VerEmpleadosStyles.tardColor,
        ),
      ],
    );
  }

  Widget _buildMetric(String label, int value, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: VerEmpleadosStyles.metricDecoration(bg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.8)),
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isInactivo) {
    return Column(
      children: [
        const Icon(Icons.chevron_right,
            color: VerEmpleadosStyles.chevronColor, size: 22),
        if (!isInactivo) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onDesactivar,
            child: const Icon(Icons.person_off_outlined,
                color: VerEmpleadosStyles.desactivarIcon, size: 20),
          ),
        ],
      ],
    );
  }
}
