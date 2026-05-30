import 'package:flutter/material.dart';
import '../ver_solicitudes_styles.dart';

/// Notification banner showing the number of pending requests.
class SolicitudBanner extends StatelessWidget {
  final int pendientes;

  const SolicitudBanner({super.key, required this.pendientes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: VerSolicitudesStyles.bannerDecoration(),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: VerSolicitudesStyles.pendingIcon, size: 20),
          const SizedBox(width: 10),
          Text(
            '$pendientes solicitude${pendientes == 1 ? '' : 's'} pendiente${pendientes == 1 ? '' : 's'}',
            style: const TextStyle(
              color: VerSolicitudesStyles.pendingText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
