import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'components/comments_card.dart';
import 'components/profile_header.dart';
import 'components/profile_info_card.dart';
import 'components/rating_card.dart';

/// Employee profile view. Composed from small reusable components.
class PerfilEmpleadoPage extends StatefulWidget {
  const PerfilEmpleadoPage({super.key});

  @override
  State<PerfilEmpleadoPage> createState() => _PerfilEmpleadoPageState();
}

class _PerfilEmpleadoPageState extends State<PerfilEmpleadoPage> {
  int _myRating = 0;

  // TODO: replace with real backend data
  static const _mock = _MockData(
    dni: '12345678',
    rating: 4.8,
    reviews: 2,
    attendances: 19,
    lates: 3,
    absences: 1,
  );

  final List<CommentItem> _comments = [
    const CommentItem(
      initials: 'CX',
      author: 'Constructora XYZ',
      text: 'Great worker, punctual and responsible.',
      avatarColor: Color(0xFF00BCD4),
    ),
    const CommentItem(
      initials: 'MT',
      author: 'Miguel Torres',
      text: 'Excellent teammate, always willing to help.',
      avatarColor: Color(0xFF4CAF50),
    ),
    const CommentItem(
      initials: 'CM',
      author: 'Carlos M.',
      text: 'Always delivers on assigned tasks.',
      avatarColor: Color(0xFF9C27B0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentUserProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ProfileHeader(name: profile?.nombre ?? 'Employee'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileInfoCard(
                    profile: profile,
                    dni: _mock.dni,
                    rating: _mock.rating,
                    reviews: _mock.reviews,
                    attendances: _mock.attendances,
                    lates: _mock.lates,
                    absences: _mock.absences,
                  ),
                  const SizedBox(height: 12),
                  RatingCard(
                    myRating: _myRating,
                    onRatingChanged: (v) => setState(() => _myRating = v),
                    onRatePressed: () => _showRateSnackBar(),
                  ),
                  const SizedBox(height: 12),
                  CommentsCard(
                    comments: _comments,
                    onAddComment: () => _showCommentDialog(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const BottomNavbar(userRole: 'empleado', currentIndex: 3),
        ],
      ),
    );
  }

  void _showRateSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You rated $_myRating star${_myRating == 1 ? '' : 's'}',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCommentDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add comment'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write your comment...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _comments.add(CommentItem(
                    initials: 'ME',
                    author: 'Me',
                    text: controller.text.trim(),
                    avatarColor: AppColors.primary,
                  ));
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _MockData {
  final String dni;
  final double rating;
  final int reviews;
  final int attendances;
  final int lates;
  final int absences;

  const _MockData({
    required this.dni,
    required this.rating,
    required this.reviews,
    required this.attendances,
    required this.lates,
    required this.absences,
  });
}
