// lib/pages/sign_in/sign_in_page.dart
// VERSIÓN CONECTADA AL BACKEND RUBY

import 'package:flutter/material.dart';
import '../../src/api_service.dart';
import '../recuperar_contrasena/recuperar_contrasena.dart';
import '../resumen_empleado/resumen_empleado.dart';
import '../resumen_empresa/resumen_empresa.dart';
import '../registrar_usuario/registrar_usuario.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _rememberUser = false;
  bool _isLoading    = false;
  String? _error;

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  final Color backgroundColor = const Color(0xFF111111);
  final Color textFieldColor  = const Color(0xFF5A5A5A);
  final Color buttonColor     = const Color(0xFFFFB800);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Login conectado al backend ─────────────────────────────
  Future<void> _handleLogin() async {
    final correo = _emailController.text.trim();
    final clave  = _passwordController.text;

    if (correo.isEmpty || clave.isEmpty) {
      setState(() => _error = 'Ingresa tu correo y contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
      _error     = null;
    });

    try {
      final result = await ApiService.instance.login(correo, clave);

      if (!mounted) return;

      // Navegar según el rol que devuelve el backend
      if (result.rol == 'empleado') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResumenEmpleadoPage()),
        );
      } else if (result.rol == 'empresa') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResumenEmpresaPage()),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } catch (e) {
      setState(() => _error = 'No se pudo conectar al servidor.\n¿Está corriendo el backend?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // LOGO
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 40),

              // USERNAME
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: textFieldColor,
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

              const SizedBox(height: 25),

              // PASSWORD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: textFieldColor,
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

              const SizedBox(height: 20),

              // CHECKBOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Row(
                  children: [
                    Checkbox(
                      value: _rememberUser,
                      activeColor: buttonColor,
                      checkColor: Colors.black,
                      onChanged: (value) {
                        setState(() => _rememberUser = value!);
                      },
                    ),
                    const Text(
                      'Recordar usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // ERROR MESSAGE
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 10),

              // BUTTON
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 90),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // RECUPERAR CONTRASEÑA
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecuperarContrasenaPage(),
                          ),
                        );
                      },
                      child: const Text(
                        '¿Ha olvidado su contraseña? Haga click aquí',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // REGISTRARSE
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrarUsuarioPage(),
                          ),
                        );
                      },
                      child: const Text(
                        '¿Aún no es miembro? Regístrese ahora',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
