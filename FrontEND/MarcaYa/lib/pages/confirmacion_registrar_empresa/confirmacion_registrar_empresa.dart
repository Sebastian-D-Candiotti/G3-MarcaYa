import 'package:flutter/material.dart';

class ConfirmacionRegistrarEmpresaPage extends StatelessWidget {

  const ConfirmacionRegistrarEmpresaPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Confirmación Empresa'),
      ),

      body: const Center(

        child: Padding(

          padding: EdgeInsets.symmetric(horizontal: 30),

          child: Text(

            'Esta es la confirmación de la empresa donde se recibirá un código mediante correo.',

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