import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class OverviewChartCard extends StatefulWidget {
  final VoidCallback? onViewFullReport;

  const OverviewChartCard({super.key, this.onViewFullReport});

  @override
  State<OverviewChartCard> createState() => _OverviewChartCardState();
}

class _OverviewChartCardState extends State<OverviewChartCard> {
  int _selectedBarIndex = 9;

  late List<DateTime> _last10Dates;
  final List<double> _dailyExpenses = [
    45.0, 120.0, 30.0, 85.0, 160.0, 55.0, 95.0, 40.0, 110.0, 75.0
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _last10Dates = List.generate(10, (i) => now.subtract(Duration(days: 9 - i)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final variantBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;

    final maxSpend = _dailyExpenses.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.3 : 0.04),
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
                    'Daily Report (Last 10 Days)',
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
          const SizedBox(height: 20),

          // 10-Day Horizontal Scrollable Bar Chart
          SizedBox(
            height: 160,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(10, (index) {
                  final isSelected = index == _selectedBarIndex;
                  final date = _last10Dates[index];
                  final dayNumber = DateFormat('d').format(date);
                  final monthStr = DateFormat('MMM').format(date);
                  final spendAmount = _dailyExpenses[index];
                  final heightRatio = (spendAmount / maxSpend).clamp(0.2, 1.0);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedBarIndex = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Tooltip on Selected Bar
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
                                '\$${spendAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 21),

                          // Pill Bar (Green when selected)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 85 * heightRatio,
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.primaryGradient : null,
                              color: isSelected ? null : AppColors.primaryMint.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date Labels (e.g. "24\nMar")
                          Column(
                            children: [
                              Text(
                                dayNumber,
                                style: TextStyle(
                                  color: isSelected
                                      ? (isDark ? AppColors.white : AppColors.black)
                                      : textSecondary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                              Text(
                                monthStr,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryMint
                                      : textSecondary.withValues(alpha: 0.7),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
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