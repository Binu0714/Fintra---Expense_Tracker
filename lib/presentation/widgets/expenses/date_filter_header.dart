import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class DateFilterHeader extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final int totalCount;
  final double totalAmount;
  final VoidCallback onSelectDateRange;
  final VoidCallback onClearDateRange;

  const DateFilterHeader({
    super.key,
    required this.selectedDateRange,
    required this.totalCount,
    required this.totalAmount,
    required this.onSelectDateRange,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    String dateText = 'All Time';
    if (selectedDateRange != null) {
      final start = DateFormat('d MMM').format(selectedDateRange!.start);
      final end = DateFormat('d MMM yyyy').format(selectedDateRange!.end);
      dateText = '$start - $end';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date Range Trigger
          InkWell(
            onTap: onSelectDateRange,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primaryMint),
                const SizedBox(width: 8),
                Text(
                  dateText,
                  style: TextStyle(
                    color: selectedDateRange != null ? AppColors.primaryMint : textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primaryMint),
              ],
            ),
          ),

          // Total Count and Amount
          Row(
            children: [
              if (selectedDateRange != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                  onPressed: onClearDateRange,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (selectedDateRange != null) const SizedBox(width: 8),
              Text(
                '$totalCount items (${currency.format(totalAmount)})',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}