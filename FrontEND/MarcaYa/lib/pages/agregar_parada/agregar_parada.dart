import 'package:flutter/material.dart';

class AgregarParadaPage extends StatelessWidget {

  const AgregarParadaPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Agregar Parada'),
      ),

      body: const Center(
        child: Text('Agregar Parada'),
      ),

    );

  }

}