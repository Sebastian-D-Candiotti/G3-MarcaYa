import 'package:flutter/material.dart';
import '../solicitud_model.dart';
import '../ver_solicitudes_styles.dart';

/// Bottom sheet showing a request applicant's profile with rating.
class SolicitudPerfilSheet extends StatelessWidget {
  final SolicitudIngreso solicitud;

  const SolicitudPerfilSheet({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    final estrellas = solicitud.valoracionPromedio.round();

    return Container(
      decoration: VerSolicitudesStyles.whiteBgDecoration(),
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
          const SizedBox(height: 12),
          _buildRatingRow(estrellas),
          const SizedBox(height: 8),
          _buildRatingLabel(),
          const SizedBox(height: 20),
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
        color: VerSolicitudesStyles.sheetHandle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 36,
      backgroundColor: solicitud.avatarColor,
      child: Text(
        solicitud.iniciales,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22),
      ),
    );
  }

  Widget _buildName() {
    return Text(
      solicitud.nombre,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: VerSolicitudesStyles.textDark),
    );
  }

  Widget _buildDni() {
    return Text(
      'DNI: ${solicitud.dni}',
      style: const TextStyle(
          fontSize: 13, color: VerSolicitudesStyles.textGray),
    );
  }

  Widget _buildRatingRow(int estrellas) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < estrellas
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: VerSolicitudesStyles.starColor,
            size: 26,
          );
        }),
        const SizedBox(width: 8),
        Text(
          solicitud.valoracionPromedio.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VerSolicitudesStyles.textDark),
        ),
      ],
    );
  }

  Widget _buildRatingLabel() {
    return Text(
      'Valoración promedio por otras empresas',
      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
    );
  }

  Widget _buildCerrarButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: VerSolicitudesStyles.buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: VerSolicitudesStyles.cerrarButtonStyle(),
        child: const Text('Cerrar',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
