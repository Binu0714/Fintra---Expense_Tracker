import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/expense_model.dart';

class OverviewChartCard extends StatefulWidget {
  final List<ExpenseModel> allExpenses; // Real Firestore Data passed from Dashboard!
  final VoidCallback? onViewFullReport;

  const OverviewChartCard({
    super.key,
    required this.allExpenses,
    this.onViewFullReport,
  });

  @override
  State<OverviewChartCard> createState() => _OverviewChartCardState();
}

class _OverviewChartCardState extends State<OverviewChartCard> {
  int _selectedBarIndex = 6; // Defaults to Today (7th day)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final variantBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;

    // 1. Generate the last 7 calendar days ending today
    final now = DateTime.now();
    final last7Dates = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    // 2. Aggregate REAL expense totals for each of the 7 days
    final List<double> dailyTotals = last7Dates.map((date) {
      return widget.allExpenses.where((expense) {
        return DateUtils.isSameDay(expense.date, date);
      }).fold(0.0, (sum, item) => sum + item.amount);
    }).toList();

    // 3. Find the day with maximum expense
    final double maxSpend = dailyTotals.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Daily Report (Last 7 Days)',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: variantBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today_rounded, size: 16, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 7-Day Chart Row
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isSelected = index == _selectedBarIndex;
                final date = last7Dates[index];
                final dayLabel = DateFormat('E').format(date); // Mon, Tue, etc.
                final dayNumber = DateFormat('d').format(date);
                final spendAmount = dailyTotals[index];

                // Check if this day is the highest spender of the week
                final isHighestDay = maxSpend > 0 && spendAmount == maxSpend;

                // Dynamic height based on proportion of max spend
                final heightRatio = maxSpend > 0
                    ? (spendAmount / maxSpend).clamp(0.18, 1.0)
                    : 0.18;

                return GestureDetector(
                  onTap: () => setState(() => _selectedBarIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tooltip showing actual amount when selected
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.pitchDark,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'Rs ${spendAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 21),

                      // Pill Bar: Solid Mint Gradient if Maximum Day or Selected!
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 85 * heightRatio,
                        decoration: BoxDecoration(
                          gradient: (isHighestDay || isSelected)
                              ? AppColors.primaryGradient
                              : null,
                          color: (isHighestDay || isSelected)
                              ? null
                              : AppColors.primaryMint.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: (isHighestDay || isSelected)
                              ? [
                            BoxShadow(
                              color: AppColors.primaryMint.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Day & Date Labels
                      Column(
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? (isDark ? AppColors.white : AppColors.black)
                                  : textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                          Text(
                            dayNumber,
                            style: TextStyle(
                              color: (isHighestDay || isSelected)
                                  ? AppColors.primaryMint
                                  : textSecondary.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Action Button
          InkWell(
            onTap: widget.onViewFullReport,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.pitchDark,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text(
                  'View Full Report',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}