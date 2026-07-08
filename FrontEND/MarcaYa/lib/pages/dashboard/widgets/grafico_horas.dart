import 'package:flutter/material.dart';

class GraficoHorasWidget extends StatelessWidget {
  final List<dynamic> datos;

  const GraficoHorasWidget({
    Key? key,
    required this.datos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No hay datos disponibles'),
        ),
      );
    }

    // Gráfico simple de barras usando información de datos
    double maxHoras = 0;
    for (var dato in datos) {
      if (dato['horas'] != null && dato['horas'] > maxHoras) {
        maxHoras = (dato['horas'] as num).toDouble();
      }
    }

    if (maxHoras == 0) maxHoras = 10;

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
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Horas',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  'Máx: ${maxHoras.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barras de horas
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: datos.length > 7 ? 7 : datos.length,
              itemBuilder: (context, index) {
                var dato = datos[index];
                double horas = (dato['horas'] as num).toDouble();
                double porcentaje = horas / maxHoras;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Día ${dato['fecha']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${horas.toStringAsFixed(1)}h',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            horas >= 8
                                ? Colors.green
                                : horas >= 6
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
