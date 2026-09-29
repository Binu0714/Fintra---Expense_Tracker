import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_type.dart';

class CategoryFilterBar extends StatelessWidget {
  final CategoryType? selectedCategory;
  final ValueChanged<CategoryType?> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // "All" Chip
          _buildChip(
            label: 'All',
            icon: Icons.apps_rounded,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
            cardBg: cardBg,
            cardBorder: cardBorder,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // Dynamic Category Chips
          ...CategoryType.values.map((cat) {
            final isSelected = selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChip(
                label: cat.label,
                icon: cat.icon,
                iconColor: cat.color,
                isSelected: isSelected,
                onTap: () => onCategorySelected(cat),
                cardBg: cardBg,
                cardBorder: cardBorder,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBg,
    required Color cardBorder,
    required Color textSecondary,
    required bool isDark,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.pitchDark : AppColors.black)
              : cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryMint : cardBorder,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryMint : (iconColor ?? textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}