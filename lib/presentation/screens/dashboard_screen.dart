import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/dashboard/active_budget_card.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/overview_chart_card.dart';
import '../widgets/dashboard/total_expenses_hero_card.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;

  const DashboardScreen({super.key, this.userName = 'User'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final todayStr = DateFormat('EEEE, MMM d').format(DateTime.now());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          StaggeredSlideFade(
            index: 0,
            child: DashboardHeader(
              dateString: todayStr,
              userName: userName,
            ),
          ),
          const SizedBox(height: 20),
          const StaggeredSlideFade(
            index: 1,
            child: TotalExpensesHeroCard(
              amount: '\$42,593.00',
              percentageChange: '-12.5%',
            ),
          ),
          const SizedBox(height: 16),
          StaggeredSlideFade(
            index: 2,
            child: OverviewChartCard(
              onViewFullReport: () {},
            ),
          ),
          const SizedBox(height: 24),
          StaggeredSlideFade(
            index: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          const StaggeredSlideFade(
            index: 4,
            child: ActiveBudgetCard(
              title: 'Food & Dining Redesign',
              subtitle: 'Due in 3 days',
              percent: 75,
              progressColor: AppColors.primaryMint,
            ),
          ),
          const SizedBox(height: 12),
          const StaggeredSlideFade(
            index: 5,
            child: ActiveBudgetCard(
              title: 'Marketing & Shopping',
              subtitle: 'Due in 12 days',
              percent: 45,
              progressColor: AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}