import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';

class VerificarOtpPage extends StatefulWidget {
  final String? ruc;
  final String? correo;

  const VerificarOtpPage({super.key, this.ruc, this.correo});

  @override
  State<VerificarOtpPage> createState() => _VerificarOtpPageState();
}

class _VerificarOtpPageState extends State<VerificarOtpPage> {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerificar() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'El código debe tener exactamente 6 dígitos');
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.currentUserProfile;
    final ruc = widget.ruc ?? user?.ruc;

    if (ruc == null || ruc.isEmpty) {
      setState(() => _error = 'RUC no encontrado para la verificación');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ApiService.instance.verificarOtp(
        ruc: ruc,
        codigo: code,
      );

      if (!mounted) return;

      // Código verificado con éxito, la cuenta queda pendiente de aprobación del admin
      await auth.fetchProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verificado. Tu cuenta está pendiente de aprobación.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/locked');
      }
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } catch (_) {
      setState(() => _error = 'Error al conectar con el servidor');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReenviar() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUserProfile;
    final ruc = widget.ruc ?? user?.ruc;
    final correo = widget.correo ?? user?.correo;

    if (ruc == null || ruc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: RUC no encontrado'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.instance.enviarCodigoSunat(ruc, correo: correo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código reenviado a ${res['correo_enmascarado'] ?? "el correo"}'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje), backgroundColor: AppColors.error),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo reenviar el código'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUserProfile;
    final displayCorreo = widget.correo ?? user?.correo ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Código'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await auth.logout();
            if (context.mounted) {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ingresa el código OTP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hemos enviado un token de 6 dígitos a tu correo corporativo:\n$displayCorreo',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  hintStyle: TextStyle(color: Colors.grey, letterSpacing: 8),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerificar,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Verificar código', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _handleReenviar,
                child: const Text('¿No recibiste el código? Reenviar código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
