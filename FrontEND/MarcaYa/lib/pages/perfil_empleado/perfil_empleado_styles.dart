import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable styles for the employee profile view.
class PerfilEmpleadoStyles {
  PerfilEmpleadoStyles._();

  // ── Sizes ──────────────────────────────────────────────────
  static const double avatarSize = 72;
  static const double cardRadius = 16;
  static const double statIconSize = 32;
  static const double iconSize = 24;
  static const double buttonHeight = 44;

  // ── Specific colors (mapped from AppColors) ────────────────
  static const Color starColor = Colors.amber;
  static const Color attendanceColor = AppColors.primary;
  static const Color lateColor = AppColors.warning;
  static const Color absenceColor = AppColors.error;

  // ── Gradients ──────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    colors: [AppColors.primaryHover, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryHover],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Decorations ────────────────────────────────────────────
  static BoxDecoration cardDecoration() => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration avatarDecoration() => BoxDecoration(
        gradient: avatarGradient,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3338A3A5),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration navItemDecoration(bool selected) => BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      );

  static EdgeInsets sectionPadding = const EdgeInsets.symmetric(horizontal: 16);

  // ── Vertical divider ───────────────────────────────────────
  static Container divider() => Container(
        height: 36,
        width: 1,
        color: AppColors.cardBorder,
      );
}
