import 'package:flutter/material.dart';
import '../../components/bottom_navbar.dart';
import '../agregar_parada/agregar_parada.dart';
import '../administrar_paradas/administrar_paradas.dart';
import '../perfil_empresa/perfil_empresa.dart';
import '../empleados_actuales/empleados_actuales.dart';
import '../ver_solicitudes/ver_solicitudes.dart';
class ResumenEmpresaPage extends StatelessWidget {

  const ResumenEmpresaPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Resumen Empresa'),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // AGREGAR PARADA
            ElevatedButton(

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgregarParadaPage(),
                  ),
                );

              },

              child: const Text('Agregar Parada'),

            ),

            const SizedBox(height: 20),

            // ADMINISTRAR PARADAS
            ElevatedButton(

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdministrarParadasPage(),
                  ),
                );

              },

              child: const Text('Administrar Paradas'),

            ),

            const SizedBox(height: 20),

            // VER EMPLEADOS
            ElevatedButton(

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmpleadosActualesPage(),
                  ),
                );

              },

              child: const Text('Ver Empleados'),

            ),

            const SizedBox(height: 20),

            // VER SOLICITUDES
            ElevatedButton(

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerSolicitudesPage(),
                  ),
                );

              },

              child: const Text('Ver Solicitudes'),

            ),

          ],

        ),

      ),

      bottomNavigationBar: BottomNavbar(

        currentIndex: 0,

        onTap: (index) {

          // HOME
          if (index == 0) {}

          // PERFIL
          if (index == 2) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PerfilEmpresaPage(),
              ),
            );

          }

        },

      ),

    );

  }

}