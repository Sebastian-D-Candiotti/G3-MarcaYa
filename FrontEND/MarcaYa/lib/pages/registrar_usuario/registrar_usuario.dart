import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class RegistrarUsuarioPage extends StatelessWidget {
  const RegistrarUsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),

              Icon(
                Icons.person_add_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seleccioná el tipo de usuario',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 48),

              // EMPRESA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.business, size: 28),
                  label: const Text(
                    'Empresa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => context.push('/register/empresa'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // EMPLEADO
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person, size: 28),
                  label: const Text(
                    'Empleado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => context.push('/register/empleado'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Ya tengo cuenta — Iniciar sesión',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
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
