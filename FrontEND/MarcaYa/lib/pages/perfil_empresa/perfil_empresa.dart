import 'package:flutter/material.dart';

class PerfilEmpresaPage extends StatelessWidget {

  const PerfilEmpresaPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Perfil Empresa'),
      ),

      body: const Center(
        child: Text(
          'Perfil Empresa',
          style: TextStyle(fontSize: 24),
        ),
      ),

    );

  }

}