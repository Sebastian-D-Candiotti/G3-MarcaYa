import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../perfil_empleado_styles.dart';

/// A single comment model.
class CommentItem {
  final String initials;
  final String author;
  final String text;
  final Color avatarColor;

  const CommentItem({
    required this.initials,
    required this.author,
    required this.text,
    required this.avatarColor,
  });
}

/// Comments card with list and add button.
class CommentsCard extends StatelessWidget {
  final List<CommentItem> comments;
  final VoidCallback onAddComment;

  const CommentsCard({
    super.key,
    required this.comments,
    required this.onAddComment,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${comments.length} reviews',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...comments.map((c) => _buildCommentItem(c)),
          const SizedBox(height: 8),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentItem c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: c.avatarColor,
            child: Text(
              c.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.author,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: PerfilEmpleadoStyles.buttonHeight,
      child: OutlinedButton(
        onPressed: onAddComment,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Add comment',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
