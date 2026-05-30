import 'package:flutter/material.dart';
import '../solicitud_model.dart';
import '../ver_solicitudes_styles.dart';

/// Card displaying a single income request with avatar, info, and action buttons.
class SolicitudCard extends StatelessWidget {
  final SolicitudIngreso solicitud;
  final VoidCallback onVerPerfil;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    required this.onVerPerfil,
    required this.onAceptar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final isPendiente = solicitud.estado == EstadoSolicitud.pendiente;
    final isAceptada = solicitud.estado == EstadoSolicitud.aceptada;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: VerSolicitudesStyles.cardDecoration(isPending: isPendiente)
          .copyWith(
        border: !isPendiente
            ? Border.all(
                color: isAceptada
                    ? VerSolicitudesStyles.acceptColor.withValues(alpha: 0.4)
                    : VerSolicitudesStyles.rejectColor.withValues(alpha: 0.4),
                width: 1.2,
              )
            : null,
      ),
      child: Column(
        children: [
          _buildTopRow(isPendiente, isAceptada),
          const SizedBox(height: 12),
          _buildActionButtons(isPendiente),
        ],
      ),
    );
  }

  Widget _buildTopRow(bool isPendiente, bool isAceptada) {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(child: _buildInfo()),
        if (!isPendiente) _buildEstadoBadge(isAceptada),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: VerSolicitudesStyles.avatarRadius,
      backgroundColor: solicitud.avatarColor,
      child: Text(
        solicitud.iniciales,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          solicitud.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: VerSolicitudesStyles.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'DNI: ${solicitud.dni} · ${solicitud.fecha}',
          style: const TextStyle(
              fontSize: 12, color: VerSolicitudesStyles.textGray),
        ),
      ],
    );
  }

  Widget _buildEstadoBadge(bool isAceptada) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: VerSolicitudesStyles.estadoBadgeDecoration(isAceptada),
      child: Text(
        isAceptada ? 'Aceptado' : 'Rechazado',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAceptada
              ? VerSolicitudesStyles.acceptColor
              : VerSolicitudesStyles.rejectColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isPendiente) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onVerPerfil,
            style: VerSolicitudesStyles.verPerfilButtonStyle(),
            child: const Text('Ver perfil',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isPendiente ? onAceptar : null,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Aceptar',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            style: VerSolicitudesStyles.acceptButtonStyle(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isPendiente ? onRechazar : null,
            icon: Icon(Icons.cancel_outlined,
                size: 16,
                color: isPendiente
                    ? VerSolicitudesStyles.rejectColor
                    : VerSolicitudesStyles.rejectColor.withValues(alpha: 0.35)),
            label: Text(
              'Rechazar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPendiente
                    ? VerSolicitudesStyles.rejectColor
                    : VerSolicitudesStyles.rejectColor.withValues(alpha: 0.35),
              ),
            ),
            style: VerSolicitudesStyles.rejectOutlineButtonStyle(
                enabled: isPendiente),
          ),
        ),
      ],
    );
  }
}
