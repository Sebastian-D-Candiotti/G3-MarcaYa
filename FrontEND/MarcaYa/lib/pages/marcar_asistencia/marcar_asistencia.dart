import 'package:flutter/material.dart';

class MarcarAsistenciaPage extends StatelessWidget {

  const MarcarAsistenciaPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Marcar Asistencia'),
      ),

      body: Center(

        child: ElevatedButton(

          onPressed: () {

            Navigator.pop(context);

          },

          child: const Text('Volver'),

        ),

      ),

    );

  }

}