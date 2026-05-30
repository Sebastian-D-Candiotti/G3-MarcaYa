import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable styles for the solicitudes (requests) view.
class VerSolicitudesStyles {
  VerSolicitudesStyles._();

  // ── Sizes ──────────────────────────────────────────────────
  static const double cardRadius = 16;
  static const double avatarRadius = 22;
  static const double buttonHeight = 44;

  // ── Specific colors (mapped from AppColors) ────────────────
  static const Color acceptColor = AppColors.primary;
  static const Color rejectColor = AppColors.error;
  static const Color pendingBg = Color(0xFFFFF8E1);
  static const Color pendingBorder = Color(0xFFFFCC02);
  static const Color pendingIcon = Color(0xFFF9A825);
  static const Color pendingText = Color(0xFF795548);
  static const Color textDark = Color(0xFF212121);
  static const Color textGray = Color(0xFF9E9E9E);
  static const Color starColor = Color(0xFFFFC107);
  static const Color sheetHandle = Color(0xFFE0E0E0);

  // ── Gradients ──────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    colors: [AppColors.primaryHover, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Decorations ────────────────────────────────────────────
  static BoxDecoration cardDecoration({bool isPending = true}) =>
      BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: isPending
            ? null
            : Border.all(
                color: Colors.transparent,
                width: 1.2,
              ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration resolvedBorderDecoration(bool isAceptada) =>
      BoxDecoration(
        border: Border.all(
          color: isAceptada
              ? acceptColor.withValues(alpha: 0.4)
              : rejectColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      );

  static BoxDecoration bannerDecoration() => BoxDecoration(
        color: pendingBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pendingBorder, width: 1),
      );

  static BoxDecoration estadoBadgeDecoration(bool isAceptada) =>
      BoxDecoration(
        color: isAceptada
        ? acceptColor.withValues(alpha: 0.12)
        : rejectColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration whiteBgDecoration() => const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      );

  // ── Button styles ──────────────────────────────────────────
  static ButtonStyle acceptButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: acceptColor,
        disabledBackgroundColor: acceptColor.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      );

  static ButtonStyle rejectOutlineButtonStyle({required bool enabled}) =>
      OutlinedButton.styleFrom(
        side: BorderSide(
          color: enabled ? rejectColor : rejectColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      );

  static ButtonStyle verPerfilButtonStyle() => OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFBDBDBD), width: 1.2),
        foregroundColor: const Color(0xFF424242),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      );

  static ButtonStyle cerrarButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      );
}
