import 'package:flutter/material.dart';
import '../sign_in/sign_in_page.dart';

class NuevaContrasenaPage extends StatelessWidget {

  const NuevaContrasenaPage({super.key});

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

                    'Nueva contraseña',

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),

                  ),

                ),

              ),

            ),

            const SizedBox(height: 50),

            // INPUT NUEVA CONTRASEÑA
            buildInput('Ingrese nueva contraseña'),

            const SizedBox(height: 25),

            // INPUT CONFIRMAR
            buildInput('Confirmar contraseña'),

            const SizedBox(height: 40),

            // BOTON
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

                  // MENSAJE
                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(

                      content: Text(
                        'Contraseña cambiada exitosamente',
                      ),

                      backgroundColor: Colors.green,

                    ),

                  );

                  // ESPERA 2 SEGUNDOS
                  Future.delayed(const Duration(seconds: 2), () {

                    Navigator.pushAndRemoveUntil(

                      context,

                      MaterialPageRoute(
                        builder: (_) => const SignInPage(),
                      ),

                          (route) => false,

                    );

                  });

                },

                child: const Text(

                  'Cambiar',

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

// INPUT
Widget buildInput(String hint) {

  return Padding(

    padding: const EdgeInsets.symmetric(horizontal: 40),

    child: TextField(

      obscureText: true,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(

        hintText: hint,

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

  );

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