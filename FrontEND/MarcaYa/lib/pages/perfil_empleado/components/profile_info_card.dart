import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/app_user.dart';
import '../perfil_empleado_styles.dart';

/// Employee info card: name, DNI, rating, and stats row.
class ProfileInfoCard extends StatelessWidget {
  final AppUser? profile;
  final String dni;
  final double rating;
  final int reviews;
  final int attendances;
  final int lates;
  final int absences;

  const ProfileInfoCard({
    super.key,
    required this.profile,
    required this.dni,
    required this.rating,
    required this.reviews,
    required this.attendances,
    required this.lates,
    required this.absences,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            profile?.nombre ?? 'Andre Silva',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'DNI: $dni',
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          _buildRatingRow(),
          const SizedBox(height: 16),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star_rounded,
            color: PerfilEmpleadoStyles.starColor, size: 18),
        const SizedBox(width: 4),
        Text(
          '$rating',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          ' ($reviews reviews)',
          style:
              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatItem(
              '$attendances', 'Attendances', PerfilEmpleadoStyles.attendanceColor),
          PerfilEmpleadoStyles.divider(),
          _buildStatItem('$lates', 'Lates', PerfilEmpleadoStyles.lateColor),
          PerfilEmpleadoStyles.divider(),
          _buildStatItem(
              '$absences', 'Absences', PerfilEmpleadoStyles.absenceColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
