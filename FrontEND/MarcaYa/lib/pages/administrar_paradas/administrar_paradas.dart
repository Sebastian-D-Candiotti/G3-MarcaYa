import 'package:flutter/material.dart';

import '../editar_parada/editar_parada.dart';

import '../ver_asistencia/ver_asistencia.dart';

class AdministrarParadasPage extends StatelessWidget {

  const AdministrarParadasPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Administrar Paradas'),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // EDITAR PARADA
            ElevatedButton(

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditarParadaPage(),
                  ),
                );

              },

              child: const Text('Editar Parada'),

            ),

            const SizedBox(height: 20),

            // VER ASISTENCIA
            ElevatedButton(

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerAsistenciaPage(),
                  ),
                );

              },

              child: const Text('Ver Asistencia'),

            ),

          ],

        ),

      ),

    );

  }

}