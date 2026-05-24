// lib/pages/registrar_empresa/registrar_empresa.dart
// VERSIÓN CONECTADA AL BACKEND RUBY

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/header_clipper.dart';
import '../../src/api_service.dart';

class RegistrarEmpresaPage extends StatefulWidget {
  const RegistrarEmpresaPage({super.key});

  @override
  State<RegistrarEmpresaPage> createState() => _RegistrarEmpresaPageState();
}

class _RegistrarEmpresaPageState extends State<RegistrarEmpresaPage> {
  final _correoController      = TextEditingController();
  final _claveController       = TextEditingController();
  final _confirmarController   = TextEditingController();
  final _rucController         = TextEditingController();
  final _razonSocialController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    _confirmarController.dispose();
    _rucController.dispose();
    _razonSocialController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistro() async {
    // Validaciones
    if (_claveController.text != _confirmarController.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (_rucController.text.length != 11) {
      setState(() => _error = 'El RUC debe tener 11 dígitos');
      return;
    }

    setState(() {
      _isLoading = true;
      _error     = null;
    });

    try {
      await ApiService.instance.registrarEmpresa(
        correo:      _correoController.text.trim(),
        clave:       _claveController.text,
        ruc:         _rucController.text.trim(),
        razonSocial: _razonSocialController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empresa registrada. Ahora inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/');
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } catch (e) {
      setState(() => _error = 'No se pudo conectar al servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      colors: [Color(0xFFF4D35E), Color(0xFFF28C45)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Registrar empresa',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _buildInput('Correo electrónico', _correoController,
                  tipo: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildInput('Contraseña', _claveController, obscure: true),
              const SizedBox(height: 20),
              _buildInput('Confirmar contraseña', _confirmarController, obscure: true),
              const SizedBox(height: 20),
              _buildInput('RUC (11 dígitos)', _rucController,
                  tipo: TextInputType.number),
              const SizedBox(height: 20),
              _buildInput('Razón social', _razonSocialController),

              // ERROR
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 30),

              // BOTÓN
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
                  onPressed: _isLoading ? null : _handleRegistro,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      String hint,
      TextEditingController controller, {
        bool obscure = false,
        TextInputType tipo = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: tipo,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


