import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';

class CodigoContrasenaPage extends StatefulWidget {

  const CodigoContrasenaPage({super.key});

  @override
  State<CodigoContrasenaPage> createState() =>
      _CodigoContrasenaPageState();

}

class _CodigoContrasenaPageState
    extends State<CodigoContrasenaPage> {

  final List<TextEditingController> controllers =
  List.generate(
    6,
        (_) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthProvider>();
    if (auth.recoveryEmail == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/reset-password'));
      return const SizedBox.shrink();
    }

    return Scaffold(

      backgroundColor: Colors.black,

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 30),

              // TEXTO
              const Text(

                'Le hemos enviado un c\u00F3digo de verificaci\u00F3n a su correo, ingresarlo en el siguiente recuadro:',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),

              ),

              const SizedBox(height: 40),

              // CUADROS
              Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: List.generate(

                  6,

                      (index) => SizedBox(

                    width: 50,
                    height: 60,

                    child: TextField(

                      controller: controllers[index],

                      textAlign: TextAlign.center,

                      keyboardType: TextInputType.number,

                      maxLength: 1,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),

                      decoration: InputDecoration(

                        counterText: '',

                        filled: true,

                        fillColor: const Color(0xFF5A5A5A),

                        border: OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(12),

                          borderSide: BorderSide.none,

                        ),

                      ),

                    ),

                  ),

                ),

              ),

              const SizedBox(height: 70),

              // BOTON
              Center(

                child: SizedBox(

                  width: 180,
                  height: 60,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                      const Color(0xFFF4B400),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(40),
                      ),

                    ),

                    onPressed: () async {

                      // UNIR CODIGO
                      String codigo = controllers
                          .map((c) => c.text)
                          .join();

                      if (codigo.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingrese el c\u00F3digo completo de 6 d\u00EDgitos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        final token = await context.read<AuthProvider>().verificarCodigo(codigo);
                        if (token != null && mounted) {
                          context.push('/reset-password/new');
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

                      'Validar',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),

                    ),

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}
