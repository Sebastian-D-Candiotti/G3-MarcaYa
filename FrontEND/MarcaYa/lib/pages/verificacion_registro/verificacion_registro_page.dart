import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/verificacion_cuenta_provider.dart';
import '../../theme/app_theme.dart';

class VerificacionRegistroPage extends StatefulWidget {
  const VerificacionRegistroPage({
    super.key,
    required this.correo,
    required this.rol,
  });

  final String correo;
  final String rol;

  @override
  State<VerificacionRegistroPage> createState() =>
      _VerificacionRegistroPageState();
}

class _VerificacionRegistroPageState extends State<VerificacionRegistroPage> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _verificar() async {
    final codigo = _controllers.map((controller) => controller.text).join();
    if (codigo.length != 6) {
      context.read<VerificacionCuentaProvider>().limpiarError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa los 6 dígitos del código.')),
      );
      return;
    }

    final ok = await context.read<VerificacionCuentaProvider>().verificarCodigo(
          correo: widget.correo,
          codigo: codigo,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta verificada. Ahora inicia sesión.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/');
    }
  }

  Future<void> _reenviar() async {
    final ok = await context
        .read<VerificacionCuentaProvider>()
        .reenviarCodigo(correo: widget.correo);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te enviamos un nuevo código.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificacionCuentaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verificar cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primary,
                    size: 44,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingresa el código de verificación enviado a tu correo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.correo} · ${widget.rol}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _controllers.length,
                      (index) => _DigitField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _onDigitChanged(value, index),
                      ),
                    ),
                  ),
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _verificar,
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Confirmar registro'),
                    ),
                  ),
                  TextButton(
                    onPressed: provider.isLoading ? null : _reenviar,
                    child: const Text('Reenviar código'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DigitField extends StatelessWidget {
  const _DigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 54,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
