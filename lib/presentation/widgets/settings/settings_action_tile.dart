import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? valueText;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.valueText,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: textSecondary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (valueText != null) ...[
                  Text(
                    valueText!,
                    style: TextStyle(
                      color: AppColors.primaryMint,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textSecondary),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(color: dividerColor, height: 1, indent: 60),
      ],
    );
  }
}