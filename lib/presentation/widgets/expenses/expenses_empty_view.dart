import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExpensesEmptyView extends StatelessWidget {
  final VoidCallback onClearFilters;

  const ExpensesEmptyView({super.key, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryMint.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.primaryMint),
            ),
            const SizedBox(height: 18),
            Text(
              'No Expenses Found',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No records match your selected category or date range.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onClearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pitchDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Reset All Filters', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}