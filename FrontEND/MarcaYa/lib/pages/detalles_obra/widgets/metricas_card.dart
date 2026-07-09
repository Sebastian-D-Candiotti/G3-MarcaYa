import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MetricasCard extends StatelessWidget {
  const MetricasCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.subtitulo,
    this.colorDesde,
    this.colorHasta,
  });

  final String titulo;
  final String valor;
  final IconData icono;
  final String subtitulo;
  final Color? colorDesde;
  final Color? colorHasta;

  @override
  Widget build(BuildContext context) {
    final desde = colorDesde ?? AppColors.primary;
    final hasta = colorHasta ?? AppColors.primaryHover;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [desde, hasta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icono, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
