import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';
import '../../components/header_clipper.dart';

class NuevaContrasenaPage extends StatefulWidget {

  const NuevaContrasenaPage({super.key});

  @override
  State<NuevaContrasenaPage> createState() => _NuevaContrasenaPageState();
}

class _NuevaContrasenaPageState extends State<NuevaContrasenaPage> {

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthProvider>();
    if (auth.verificationToken == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/reset-password'));
      return const SizedBox.shrink();
    }

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

                    'Nueva contrase\u00F1a',

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

            // INPUT NUEVA CONTRASE\u00D1A
            buildInput('Ingrese nueva contrase\u00F1a', _passwordController),

            const SizedBox(height: 25),

            // INPUT CONFIRMAR
            buildInput('Confirmar contrase\u00F1a', _confirmController),

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

                onPressed: () async {
                  final password = _passwordController.text;
                  final confirm = _confirmController.text;

                  if (password.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Complete ambos campos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (password != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Las contrase\u00F1as no coinciden'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (password.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('La contrase\u00F1a debe tener al menos 8 caracteres'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final success = await context.read<AuthProvider>().restablecerContrasena(password);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contrase\u00F1a cambiada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) context.go('/');
                      });
                    }
                  } on ApiException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.mensaje),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error de conexi\u00F3n. Intente de nuevo.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
Widget buildInput(String hint, TextEditingController controller) {

  return Padding(

    padding: const EdgeInsets.symmetric(horizontal: 40),

    child: TextField(

      controller: controller,

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
