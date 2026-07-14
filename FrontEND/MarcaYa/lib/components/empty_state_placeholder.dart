import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyStatePlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool isCompact;

  const EmptyStatePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 10 : 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isCompact ? 28 : 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isCompact ? 8 : 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: isCompact ? 4 : 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: isCompact ? 12 : 20),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 24,
                    vertical: isCompact ? 8 : 12,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
