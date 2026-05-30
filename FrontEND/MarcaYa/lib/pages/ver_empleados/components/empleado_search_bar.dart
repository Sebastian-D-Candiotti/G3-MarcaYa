import 'package:flutter/material.dart';
import '../ver_empleados_styles.dart';

/// Search bar for filtering employees by name, DNI, or initials.
class EmpleadoSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;

  const EmpleadoSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: VerEmpleadosStyles.searchDecoration(
        onClear: query.isNotEmpty
            ? () {
                controller.clear();
                onChanged('');
              }
            : null,
      ),
    );
  }
}
