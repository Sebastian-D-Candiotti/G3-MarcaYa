import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';
import '../marcar_asistencia/marcar_asistencia.dart';
import '../perfil_empleado/perfil_empleado.dart';

class ResumenEmpleadoPage extends StatelessWidget {

  const ResumenEmpleadoPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Resumen Empleado'),
      ),

      body: Center(

        child: SizedBox(

          width: 250,
          height: 60,

          child: ElevatedButton(

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MarcarAsistenciaPage(),
                ),
              );

            },

            child: const Text(
              'MARCAR ASISTENCIA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

          ),

        ),

      ),

      bottomNavigationBar: BottomNavbar(

        currentIndex: 0,

        onTap: (index) {

          // HOME
          if (index == 0) {

          }

          // BUSCAR
          /*
          if (index == 1) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BuscarPerfilesPage(),
              ),
            );

          }
          */
          // PERFIL
          if (index == 2) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PerfilEmpleadoPage(),
              ),
            );

          }

        },

      ),

    );

  }

}