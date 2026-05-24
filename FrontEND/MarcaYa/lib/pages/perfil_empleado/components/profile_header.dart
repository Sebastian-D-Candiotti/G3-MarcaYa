import 'package:flutter/material.dart';
import '../perfil_empleado_styles.dart';

/// Gradient header bar with employee name initials avatar.
class ProfileHeader extends StatelessWidget {
  final String name;

  const ProfileHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration:
          const BoxDecoration(gradient: PerfilEmpleadoStyles.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Perfil del empleado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            _buildAvatar(name),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';

    return Container(
      width: PerfilEmpleadoStyles.avatarSize,
      height: PerfilEmpleadoStyles.avatarSize,
      decoration: PerfilEmpleadoStyles.avatarDecoration(),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
