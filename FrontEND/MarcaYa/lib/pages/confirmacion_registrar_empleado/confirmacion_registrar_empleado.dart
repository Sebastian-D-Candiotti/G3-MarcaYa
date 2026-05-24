import 'package:flutter/material.dart';

class ConfirmacionRegistrarEmpleadoPage extends StatelessWidget {

  const ConfirmacionRegistrarEmpleadoPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Confirmación Empleado'),
      ),

      body: const Center(

        child: Padding(

          padding: EdgeInsets.symmetric(horizontal: 30),

          child: Text(

            'Esta es la confirmación del empleado donde se recibirá un código mediante correo.',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 24,
            ),

          ),

        ),

      ),

    );

  }

}