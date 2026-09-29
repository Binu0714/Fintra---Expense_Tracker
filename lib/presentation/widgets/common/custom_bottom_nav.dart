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
    ];

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true, // Automatically calculates phone's bottom bar height!
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, IconData activeIcon, String label, bool isDark) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primaryMint
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}