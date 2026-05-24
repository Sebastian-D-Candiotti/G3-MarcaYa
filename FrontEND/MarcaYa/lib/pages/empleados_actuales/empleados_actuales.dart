import 'package:flutter/material.dart';

class EmpleadosActualesPage extends StatelessWidget {

  const EmpleadosActualesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Empleados Actuales'),
      ),

      body: const Center(
        child: Text(
          'Empleados Actuales',
          style: TextStyle(fontSize: 24),
        ),
      ),

    );

  }

}