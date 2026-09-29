import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../widgets/dashboard/active_budget_card.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/overview_chart_card.dart';
import '../widgets/dashboard/total_expenses_hero_card.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;
  DashboardScreen({super.key, this.userName = 'User'});

  final ExpenseRepository _expenseRepository = ExpenseRepository();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final todayStr = DateFormat('EEEE, MMM d').format(DateTime.now());

    return StreamBuilder<List<ExpenseModel>>(
      stream: _expenseRepository.getExpensesStream(),
      builder: (context, snapshot) {
        final allExpenses = snapshot.data ?? [];

        final now = DateTime.now();
        final currentMonthExpenses = allExpenses.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();

        final monthlyTotal = currentMonthExpenses.fold(
          0.0,
              (sum, item) => sum + item.amount,
        );

        final recentExpenses = allExpenses.take(2).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              StaggeredSlideFade(
                index: 0,
                child: DashboardHeader(
                  dateString: todayStr,
                  userName: userName,
                ),
              ),
              const SizedBox(height: 20),

              // Total Expense Live Card
              StaggeredSlideFade(
                index: 1,
                child: TotalExpensesHeroCard(
                  totalAmount: monthlyTotal, // Real Firestore Data!
                  title: 'Monthly Spending',
                  badgeText: '${currentMonthExpenses.length} items',
                ),
              ),
              const SizedBox(height: 16),

              // Overview 10-day Bar Chart
              StaggeredSlideFade(
                index: 2,
                child: OverviewChartCard(
                  onViewFullReport: () {},
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions Header
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
                    Text(
                      '${allExpenses.length} total',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Real Active Items from Firestore
              if (recentExpenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'No expenses recorded yet. Tap + to add one!',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                )
              else
                ...List.generate(recentExpenses.length, (index) {
                  final expense = recentExpenses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: StaggeredSlideFade(
                      index: 4 + index,
                      child: ActiveBudgetCard(
                        title: expense.title,
                        subtitle: DateFormat('d MMM yyyy').format(expense.date),
                        percent: (monthlyTotal > 0
                            ? (expense.amount / monthlyTotal) * 100
                            : 0)
                            .toInt(),
                        progressColor: expense.category.color,
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}