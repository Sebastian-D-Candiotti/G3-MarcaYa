import 'package:flutter/material.dart';
import '../registrar_empresa/registrar_empresa.dart';
import '../registrar_empleado/registrar_empleado.dart';
class RegistrarUsuarioPage extends StatelessWidget {

  const RegistrarUsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF111216),

      body: SafeArea(

        child: Column(

          children: [

            // HEADER
            ClipPath(

              clipper: CustomHeaderClipper(),

              child: Container(

                width: double.infinity,
                height: 100,

                decoration: const BoxDecoration(

                  gradient: LinearGradient(

                    colors: [
                      Color(0xFFF4D35E),
                      Color(0xFFF28C45),
                    ],

                  ),

                ),

                child: const Center(

                  child: Text(

                    'Registrar Usuario',

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),

                  ),

                ),

              ),

            ),

            const SizedBox(height: 30),

            // TITLE
            const Padding(

              padding: EdgeInsets.symmetric(horizontal: 25),

              child: Align(

                alignment: Alignment.centerLeft,

                child: Text(

                  'Seleccione tipo de usuario:',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),

                ),

              ),

            ),

            const SizedBox(height: 40),

            // BUTTONS
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                // EMPRESA
                SizedBox(

                  width: 170,
                  height: 60,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: const Color(0xFFF4B400),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                    ),

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistrarEmpresaPage(),
                        ),
                      );

                    },

                    child: const Text(

                      'Empresa',

                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),

                    ),

                  ),

                ),

                // EMPLEADO
                SizedBox(

                  width: 170,
                  height: 60,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: const Color(0xFFF4B400),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                    ),

                    onPressed: () {
                      /*
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistrarEmpleadoPage(),
                        ),
                      );
                      */
                    },

                    child: const Text(

                      'Empleado',

                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),

                    ),

                  ),

                ),

              ],

            ),

            const SizedBox(height: 70),


          ],

        ),

      ),

    );

  }

}

// HEADER SHAPE
class CustomHeaderClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {

    Path path = Path();

    path.lineTo(size.width - 40, 0);

    path.lineTo(size.width, size.height / 2);

    path.lineTo(size.width - 40, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;

  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

}