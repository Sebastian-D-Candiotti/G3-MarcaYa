import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../components/header_clipper.dart';

class RecuperarContrasenaPage extends StatefulWidget {

  const RecuperarContrasenaPage({super.key});

  @override
  State<RecuperarContrasenaPage> createState() => _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: SafeArea(

        child: Column(

          children: [

            // HEADER
            ClipPath(

              clipper: const HeaderClipper(),

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

                controller: _emailController,

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

                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese un correo electrónico'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final success = await context.read<AuthProvider>().solicitarCodigo(email);
                  if (success && mounted) {
                    context.push('/reset-password/code');
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al enviar el código. Intente de nuevo.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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

