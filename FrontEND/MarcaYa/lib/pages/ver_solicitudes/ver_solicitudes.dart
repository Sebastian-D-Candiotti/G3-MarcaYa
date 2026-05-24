import 'package:flutter/material.dart';

class VerSolicitudesPage extends StatelessWidget {

  const VerSolicitudesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Ver Solicitudes'),
      ),

      body: const Center(
        child: Text(
          'Ver Solicitudes',
          style: TextStyle(fontSize: 24),
        ),
      ),

    );

  }

}