import 'package:flutter/material.dart';

class GraficoPuntualidadWidget extends StatelessWidget {
  final double puntualidad;

  const GraficoPuntualidadWidget({
    Key? key,
    required this.puntualidad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asegurar que puntualidad esté entre 0 y 100
    double valor = puntualidad.clamp(0, 100);
    
    // Determinar color según puntualidad
    Color colorProgressBar;
    if (valor >= 90) {
      colorProgressBar = Colors.green;
    } else if (valor >= 75) {
      colorProgressBar = Colors.orange;
    } else {
      colorProgressBar = Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: valor / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(colorProgressBar),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${valor.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Puntual',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Descripción según puntualidad
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorProgressBar.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _obtenerDescripcion(valor),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorProgressBar,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerDescripcion(double valor) {
    if (valor >= 95) {
      return 'Excelente puntualidad ✓';
    } else if (valor >= 85) {
      return 'Buena puntualidad';
    } else if (valor >= 70) {
      return 'Puntualidad aceptable';
    } else {
      return 'Requiere mejora en puntualidad';
    }
  }
}
