import 'package:flutter/material.dart';

class FiltroObraWidget extends StatelessWidget {
  final List<dynamic> obras;
  final dynamic obraSeleccionada;
  final Function(dynamic) onObraSeleccionada;

  const FiltroObraWidget({
    Key? key,
    required this.obras,
    required this.obraSeleccionada,
    required this.onObraSeleccionada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<dynamic>(
          isExpanded: true,
          underline: const SizedBox(),
          value: obraSeleccionada,
          items: [
            DropdownMenuItem(
              value: null,
              child: const Text('Todas las obras'),
            ),
            ...obras.map<DropdownMenuItem>((obra) {
              return DropdownMenuItem(
                value: obra,
                child: Text(obra['nombre'] ?? 'Sin nombre'),
              );
            }).toList(),
          ],
          onChanged: (valor) {
            if (valor != null || valor == null) {
              onObraSeleccionada(valor);
            }
          },
        ),
      ),
    );
  }
}
