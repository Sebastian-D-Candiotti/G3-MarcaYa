import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';

class RegistrarEmpresaPage extends StatefulWidget {
  const RegistrarEmpresaPage({super.key});

  @override
  State<RegistrarEmpresaPage> createState() => _RegistrarEmpresaPageState();
}

class _RegistrarEmpresaPageState extends State<RegistrarEmpresaPage> {
  final _correoCtrl      = TextEditingController();
  final _claveCtrl       = TextEditingController();
  final _confirmarCtrl   = TextEditingController();
  final _rucCtrl         = TextEditingController();
  final _razonSocialCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;
  bool _obscureClave = true;
  bool _obscureConfirmar = true;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    _confirmarCtrl.dispose();
    _rucCtrl.dispose();
    _razonSocialCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegistro() async {
    // Validaciones
    if (_claveCtrl.text != _confirmarCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (_claveCtrl.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (_rucCtrl.text.trim().length != 11) {
      setState(() => _error = 'El RUC debe tener 11 dígitos');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ApiService.instance.registrarEmpresa(
        correo:      _correoCtrl.text.trim(),
        clave:       _claveCtrl.text,
        ruc:         _rucCtrl.text.trim(),
        razonSocial: _razonSocialCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empresa registrada correctamente. Ahora iniciá sesión.'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go('/');
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } catch (_) {
      setState(() => _error = 'No se pudo conectar al servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar empresa')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Datos de la empresa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completá los datos para registrar tu empresa',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              _buildField('Razón social', _razonSocialCtrl),
              const SizedBox(height: 16),
              _buildField('RUC (11 dígitos)', _rucCtrl,
                  tipo: TextInputType.number, maxLength: 11),
              const SizedBox(height: 16),
              _buildField('Correo electrónico', _correoCtrl,
                  tipo: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField('Contraseña', _claveCtrl,
                  obscure: true,
                  obscureCtrl: () => setState(() => _obscureClave = !_obscureClave),
                  isObscure: _obscureClave),
              const SizedBox(height: 16),
              _buildField('Confirmar contraseña', _confirmarCtrl,
                  obscure: true,
                  obscureCtrl: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                  isObscure: _obscureConfirmar),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistro,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Crear cuenta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType tipo = TextInputType.text,
    VoidCallback? obscureCtrl,
    bool? isObscure,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure ? isObscure! : false,
      keyboardType: tipo,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(isObscure! ? Icons.visibility : Icons.visibility_off),
                onPressed: obscureCtrl,
              )
            : null,
      ),
    );
  }
}
