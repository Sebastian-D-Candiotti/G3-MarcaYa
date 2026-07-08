import 'package:flutter/material.dart';

class GraficoIrregularidadesWidget extends StatelessWidget {
  final int tardanzas;
  final int faltas;
  final int fakeGps;

  const GraficoIrregularidadesWidget({
    Key? key,
    required this.tardanzas,
    required this.faltas,
    required this.fakeGps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total = tardanzas + faltas + fakeGps;
    double maxValue = total == 0 ? 1 : total.toDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadística de Tardanzas
            _buildIrregularidadRow(
              titulo: 'Tardanzas',
              cantidad: tardanzas,
              color: Colors.orange,
              maxValue: maxValue,
            ),
            const SizedBox(height: 16),

            // Estadística de Faltas
            _buildIrregularidadRow(
              titulo: 'Faltas',
              cantidad: faltas,
              color: Colors.red,
              maxValue: maxValue,
            ),
            const SizedBox(height: 16),

            // Estadística de Fake GPS
            _buildIrregularidadRow(
              titulo: 'Marcas Fake GPS',
              cantidad: fakeGps,
              color: Colors.purple,
              maxValue: maxValue,
            ),
            const SizedBox(height: 16),

            // Resumen
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (total > 0) ...[
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Estado',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _obtenerEstado(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _obtenerColorEstado(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIrregularidadRow({
    required String titulo,
    required int cantidad,
    required Color color,
    required double maxValue,
  }) {
    double porcentaje = cantidad / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cantidad.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  String _obtenerEstado() {
    if (tardanzas + faltas + fakeGps == 0) {
      return 'Sin problemas';
    } else if (tardanzas + faltas + fakeGps <= 3) {
      return 'Normal';
    } else {
      return 'Requiere atención';
    }
  }

  Color _obtenerColorEstado() {
    if (tardanzas + faltas + fakeGps == 0) {
      return Colors.green;
    } else if (tardanzas + faltas + fakeGps <= 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
