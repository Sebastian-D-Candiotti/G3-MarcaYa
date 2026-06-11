import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';

class RegistrarEmpleadoPage extends StatefulWidget {
  const RegistrarEmpleadoPage({super.key});

  @override
  State<RegistrarEmpleadoPage> createState() => _RegistrarEmpleadoPageState();
}

class _RegistrarEmpleadoPageState extends State<RegistrarEmpleadoPage> {
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;
  bool _obscureClave = true;
  bool _obscureConfirmar = true;
  @override
  void dispose() {
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    _confirmarCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _dniCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegistro() async {
    final dni = _dniCtrl.text.trim();

    // 1. Validar que el DNI tenga exactamente 8 números
    if (!RegExp(r'^\d{8}$').hasMatch(dni)) {
      setState(() => _error = 'El DNI debe tener exactamente 8 números');
      return;
    }

    // 2. Validar contraseña
    if (_claveCtrl.text != _confirmarCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    if (_claveCtrl.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final correo = _correoCtrl.text.trim();

      await ApiService.instance.registrarEmpleado(
        correo: _correoCtrl.text.trim(),
        clave: _claveCtrl.text,
        nombre: _nombreCtrl.text.trim().isNotEmpty ? _nombreCtrl.text.trim() : 'PENDIENTE_RENIEC',
        apellido: _apellidoCtrl.text.trim().isNotEmpty ? _apellidoCtrl.text.trim() : '',
        dni: dni,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empleado registrado. Revisa tu correo para verificar la cuenta.'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go('/register/verify', extra: {
        'correo': correo,
        'rol': 'empleado',
      });
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
      appBar: AppBar(title: const Text('Registrar empleado')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Datos personales',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completá tus datos para registrarte como empleado',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              _buildField('Nombres', _nombreCtrl),
              const SizedBox(height: 16),
              _buildField('Apellidos', _apellidoCtrl),
              const SizedBox(height: 16),
              _buildField(
                'DNI',
                _dniCtrl,
                tipo: TextInputType.number,
                maxLength: 8,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(
                'Correo electrónico',
                _correoCtrl,
                tipo: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildField(
                'Contraseña',
                _claveCtrl,
                obscure: true,
                obscureCtrl: () =>
                    setState(() => _obscureClave = !_obscureClave),
                isObscure: _obscureClave,
              ),
              const SizedBox(height: 16),
              _buildField(
                'Confirmar contraseña',
                _confirmarCtrl,
                obscure: true,
                obscureCtrl: () =>
                    setState(() => _obscureConfirmar = !_obscureConfirmar),
                isObscure: _obscureConfirmar,
              ),

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
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Después de registrarte, podrás buscar empresas y solicitar ingreso.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure ? isObscure! : false,
      keyboardType: tipo,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: (_) {
        if (onChanged != null) onChanged();
      },
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  isObscure! ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: obscureCtrl,
              )
            : null,
      ),
    );
  }
}
