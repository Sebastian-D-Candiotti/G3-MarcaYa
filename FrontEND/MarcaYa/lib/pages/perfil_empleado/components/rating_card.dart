import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../perfil_empleado_styles.dart';

/// Rating card with static display stars, interactive rating stars, and rate button.
class RatingCard extends StatelessWidget {
  final int myRating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onRatePressed;

  const RatingCard({
    super.key,
    required this.myRating,
    required this.onRatingChanged,
    required this.onRatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: PerfilEmpleadoStyles.sectionPadding,
      padding: const EdgeInsets.all(20),
      decoration: PerfilEmpleadoStyles.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall rating',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildDisplayStars(),
          const SizedBox(height: 16),
          const Text(
            'Rate this employee',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          _buildInteractiveStars(),
          const SizedBox(height: 16),
          _buildRateButton(context),
        ],
      ),
    );
  }

  Widget _buildDisplayStars() {
    return Row(
      children: List.generate(5, (i) {
        if (i < 4) {
          return const Icon(Icons.star_rounded,
              color: PerfilEmpleadoStyles.starColor, size: 32);
        } else {
          return const Icon(Icons.star_half_rounded,
              color: PerfilEmpleadoStyles.starColor, size: 32);
        }
      }),
    );
  }

  Widget _buildInteractiveStars() {
    return Row(
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => onRatingChanged(i + 1),
          child: Icon(
            i < myRating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: i < myRating
                ? PerfilEmpleadoStyles.starColor
                : AppColors.inputBorder,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: PerfilEmpleadoStyles.buttonHeight,
      child: ElevatedButton(
        onPressed: myRating > 0 ? onRatePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Rate',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
