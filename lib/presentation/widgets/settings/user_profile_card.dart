import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class UserProfileCard extends StatelessWidget {
  final String userName;
  final String email;
  final VoidCallback onEdit;

  const UserProfileCard({
    super.key,
    required this.userName,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered Avatar with Floating Edit Pencil Badge
            GestureDetector(
              onTap: onEdit,
              child: Stack(
                children: [
                  // Outer Avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE2E8F0),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),

                  // Floating Edit Pencil Badge (matching reference)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue, // Vibrant blue from reference
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentBlue.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Centered User Full Name
            Text(
              userName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),

            // Centered Email Subtitle
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}