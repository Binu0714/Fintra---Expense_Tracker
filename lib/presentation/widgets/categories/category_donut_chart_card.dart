import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_type.dart';

class CategoryDonutChartCard extends StatefulWidget {
  final Map<CategoryType, double> categoryTotals;
  final double totalSpent;

  const CategoryDonutChartCard({
    super.key,
    required this.categoryTotals,
    required this.totalSpent,
  });

  @override
  State<CategoryDonutChartCard> createState() => _CategoryDonutChartCardState();
}

class _CategoryDonutChartCardState extends State<CategoryDonutChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final categories = widget.categoryTotals.keys.toList();

    // Selected slice details
    final isSliceSelected = _touchedIndex >= 0 && _touchedIndex < categories.length;
    final activeCategory = isSliceSelected ? categories[_touchedIndex] : null;
    final activeAmount = isSliceSelected ? widget.categoryTotals[activeCategory] ?? 0.0 : widget.totalSpent;
    final activePercent = (widget.totalSpent > 0 && isSliceSelected)
        ? ((activeAmount / widget.totalSpent) * 100).toStringAsFixed(0)
        : null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Analytics',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap a slice to inspect details',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryMint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryMint.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryMint,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: AppColors.primaryMint,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Interactive Glowing Donut Chart
          SizedBox(
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient Radial Glow Backdrop
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (activeCategory?.color ?? AppColors.primaryMint).withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

                // Donut Chart
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 4,
                    centerSpaceRadius: 66,
                    sections: List.generate(categories.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final cat = categories[i];
                      final amount = widget.categoryTotals[cat] ?? 0.0;
                      final double radius = isTouched ? 28 : 20;

                      return PieChartSectionData(
                        color: cat.color,
                        value: amount,
                        title: '',
                        radius: radius,
                        badgeWidget: isTouched
                            ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.pitchDark,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: cat.color.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(cat.icon, size: 12, color: cat.color),
                        )
                            : null,
                        badgePositionPercentageOffset: 1.15,
                      );
                    }),
                  ),
                ),

                // Dynamic Animated Center Information
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Column(
                    key: ValueKey<String>('${activeCategory?.label}_$activeAmount'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (activeCategory != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(activeCategory.icon, size: 12, color: activeCategory.color),
                            const SizedBox(width: 4),
                            Text(
                              activeCategory.label.toUpperCase(),
                              style: TextStyle(
                                color: activeCategory.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currency.format(activeAmount),
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: activeCategory.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$activePercent% of total',
                            style: TextStyle(
                              color: activeCategory.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'TOTAL SPENT',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currency.format(widget.totalSpent),
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${categories.length} Categories',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Horizontal Mini Legend Badges
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = index == _touchedIndex;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _touchedIndex = (_touchedIndex == index) ? -1 : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? cat.color : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cat.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            color: isSelected ? textPrimary : textSecondary,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}