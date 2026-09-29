import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final navShadow = [
      BoxShadow(
        color: AppColors.black.withValues(alpha: isDark ? 0.6 : 0.08),
        blurRadius: 24,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
      if (isDark)
        BoxShadow(
          color: AppColors.primaryMint.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, -1),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: navShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTab(0, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Dashboard', isDark),
            _buildTab(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Expenses', isDark),
            _buildTab(2, Icons.category_outlined, Icons.category_rounded, 'Categories', isDark),
            _buildTab(3, Icons.settings_outlined, Icons.settings_rounded, 'Settings', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, IconData activeIcon, String label, bool isDark) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryMint.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.primaryMint
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryMint
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}