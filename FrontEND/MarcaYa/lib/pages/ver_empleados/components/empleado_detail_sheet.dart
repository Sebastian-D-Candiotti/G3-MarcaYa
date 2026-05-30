import 'package:flutter/material.dart';
import '../empleado_model.dart';
import '../ver_empleados_styles.dart';

/// Bottom sheet showing employee detail with quick actions.
class EmpleadoDetailSheet extends StatelessWidget {
  final Empleado empleado;

  const EmpleadoDetailSheet({super.key, required this.empleado});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: VerEmpleadosStyles.whiteBgDecoration(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),
          _buildAvatar(),
          const SizedBox(height: 12),
          _buildName(),
          _buildDni(),
          const SizedBox(height: 20),
          _buildAccionesRow(context),
          const SizedBox(height: 16),
          _buildCerrarButton(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: VerEmpleadosStyles.sheetHandle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 36,
      backgroundColor: empleado.avatarColor,
      child: Text(
        empleado.iniciales,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22),
      ),
    );
  }

  Widget _buildName() {
    return Text(
      empleado.nombre,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: VerEmpleadosStyles.textDark),
    );
  }

  Widget _buildDni() {
    return Text(
      'DNI: ${empleado.dni}',
      style: const TextStyle(
          fontSize: 13, color: VerEmpleadosStyles.inactivoText),
    );
  }

  Widget _buildAccionesRow(BuildContext context) {
    return Row(
      children: [
        _buildAccion(
          context,
          Icons.history_rounded,
          'Ver historial',
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
        ),
        const SizedBox(width: 10),
        _buildAccion(
          context,
          Icons.location_on_rounded,
          'Ver paradas',
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
        ),
        const SizedBox(width: 10),
        _buildAccion(
          context,
          Icons.edit_rounded,
          'Editar',
          const Color(0xFFFFF3E0),
          const Color(0xFFF57C00),
        ),
      ],
    );
  }

  Widget _buildAccion(
      BuildContext context, IconData icon, String label, Color bg, Color fg) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label: ${empleado.nombre}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: fg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: VerEmpleadosStyles.accionDecoration(bg),
          child: Column(
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11, color: fg, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCerrarButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: VerEmpleadosStyles.buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: VerEmpleadosStyles.cerrarButtonStyle(),
        child: const Text('Cerrar',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
