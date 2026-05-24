import 'package:flutter/material.dart';
import '../codigo_contrasena/codigo_contrasena.dart';

class RecuperarContrasenaPage extends StatelessWidget {

  const RecuperarContrasenaPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

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

                    'Restablecer contraseña',

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),

                  ),

                ),

              ),

            ),

            const SizedBox(height: 60),

            // INPUT
            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 40),

              child: TextField(

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(

                  hintText: 'Ingrese su correo',

                  hintStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),

                  filled: true,

                  fillColor: const Color(0xFF5A5A5A),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 18,
                  ),

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(40),

                    borderSide: BorderSide.none,

                  ),

                ),

              ),

            ),

            const SizedBox(height: 40),

            // BUTTON
            SizedBox(

              width: 170,
              height: 60,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: const Color(0xFFF4B400),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),

                ),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CodigoContrasenaPage(),
                    ),
                  );

                },

                child: const Text(

                  'Enviar',

                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                ),

              ),

            ),

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