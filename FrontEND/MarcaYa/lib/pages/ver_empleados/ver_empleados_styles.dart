import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reusable styles for the employee list view.
class VerEmpleadosStyles {
  VerEmpleadosStyles._();

  // ── Sizes ──────────────────────────────────────────────────
  static const double cardRadius = 16;
  static const double avatarRadius = 24;
  static const double buttonHeight = 44;

  // ── Specific colors (mapped from AppColors) ────────────────
  static const Color searchIconColor = AppColors.textSecondary;
  static const Color hintColor = Color(0xFFBDBDBD);
  static const Color asistColor = AppColors.success;
  static const Color asistBg = Color(0xFFE8F5E9);
  static const Color tardColor = AppColors.warning;
  static const Color tardBg = Color(0xFFFFF8E1);
  static const Color inactivoBg = Color(0xFFFAFAFA);
  static const Color inactivoText = Color(0xFF9E9E9E);
  static const Color inactivoBorder = Color(0xFFE0E0E0);
  static const Color textDark = Color(0xFF212121);
  static const Color chevronColor = Color(0xFFBDBDBD);
  static const Color desactivarIcon = Color(0xFFEF9A9A);
  static const Color deleteRed = Color(0xFFEF5350);
  static const Color sheetHandle = Color(0xFFE0E0E0);

  // ── Gradients ──────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    colors: [AppColors.primaryHover, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient summaryGradient = LinearGradient(
    colors: [AppColors.primaryHover, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Decorations ────────────────────────────────────────────
  static BoxDecoration summaryCardDecoration() => BoxDecoration(
        gradient: summaryGradient,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3338A3A5),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration empleadoCardDecoration({bool isInactivo = false}) =>
      BoxDecoration(
        color: isInactivo ? inactivoBg : AppColors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: isInactivo
            ? Border.all(color: inactivoBorder, width: 1)
            : null,
        boxShadow: isInactivo
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      );

  static BoxDecoration metricDecoration(Color bg) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      );

  static BoxDecoration estadoBadgeDecoration() => BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration inactivoDotDecoration() => BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      );

  static BoxDecoration whiteBgDecoration() => const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      );

  static BoxDecoration accionDecoration(Color bg) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      );

  // ── Text styles ────────────────────────────────────────────
  static const TextStyle headerTitle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle summaryLabel = TextStyle(
    color: Colors.white70,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle summaryValue = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1,
  );

  // ── Search ─────────────────────────────────────────────────
  static InputDecoration searchDecoration({VoidCallback? onClear}) =>
      InputDecoration(
        hintText: 'Buscar empleado...',
        hintStyle: const TextStyle(color: VerEmpleadosStyles.hintColor, fontSize: 14),
        prefixIcon: const Icon(Icons.search,
            color: VerEmpleadosStyles.searchIconColor, size: 22),
        suffixIcon: onClear != null
            ? IconButton(
                icon: const Icon(Icons.clear,
                    color: VerEmpleadosStyles.hintColor, size: 20),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  // ── Button styles ──────────────────────────────────────────
  static ButtonStyle desactivarButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: deleteRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      );

  static ButtonStyle cerrarButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      );
}
