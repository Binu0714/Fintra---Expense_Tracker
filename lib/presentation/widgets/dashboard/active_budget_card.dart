import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ActiveBudgetCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int percent;
  final Color progressColor;

  const ActiveBudgetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percent,
    this.progressColor = AppColors.primaryMint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorder, width: 1.2),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 3.5,
                  backgroundColor: cardBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}