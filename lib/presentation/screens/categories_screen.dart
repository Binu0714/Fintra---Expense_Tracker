import 'package:flutter/material.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category_type.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../widgets/categories/category_breakdown_card.dart';
import '../widgets/categories/category_donut_chart_card.dart';
import '../widgets/categories/category_month_selector.dart';
import '../widgets/expenses/expenses_empty_view.dart';
import 'add_edit_expense_bottom_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  DateTime _selectedMonth = DateTime.now();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  // Filter by month
  List<ExpenseModel> _filterByMonth(List<ExpenseModel> allExpenses) {
    return allExpenses.where((expense) {
      return expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    }).toList();
  }

  // Calculate total spent per category
  Map<CategoryType, double> _computeCategoryTotals(List<ExpenseModel> monthExpenses) {
    final Map<CategoryType, double> map = {};
    for (var expense in monthExpenses) {
      map[expense.category] = (map[expense.category] ?? 0.0) + expense.amount;
    }
    return map;
  }

  int _countPerCategory(List<ExpenseModel> monthExpenses, CategoryType cat) {
    return monthExpenses.where((e) => e.category == cat).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<ExpenseModel>>(
          stream: _expenseRepository.getExpensesStream(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryMint),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              );
            }

            final allExpenses = snapshot.data ?? [];
            final monthExpenses = _filterByMonth(allExpenses);
            final totals = _computeCategoryTotals(monthExpenses);
            final totalSpent = totals.values.fold(0.0, (sum, val) => sum + val);

            final sortedCategories = totals.keys.toList()
              ..sort((a, b) => (totals[b] ?? 0).compareTo(totals[a] ?? 0));

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  StaggeredSlideFade(
                    index: 0,
                    child: CategoryMonthSelector(
                      selectedMonth: _selectedMonth,
                      onPrevious: () => setState(() =>
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                      onNext: () => setState(() =>
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (monthExpenses.isEmpty) ...[
                    const SizedBox(height: 40),
                    ExpensesEmptyView(
                      onClearFilters: () {
                        setState(() => _selectedMonth = DateTime.now());
                      },
                    ),
                  ] else ...[
                    StaggeredSlideFade(
                      index: 1,
                      child: CategoryDonutChartCard(
                        categoryTotals: totals,
                        totalSpent: totalSpent,
                      ),
                    ),

                    const SizedBox(height: 24),

                    StaggeredSlideFade(
                      index: 2,
                      child: Text(
                        'Category Breakdown (${sortedCategories.length})',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...List.generate(sortedCategories.length, (index) {
                      final cat = sortedCategories[index];
                      final amount = totals[cat] ?? 0.0;
                      final count = _countPerCategory(monthExpenses, cat);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: StaggeredSlideFade(
                          index: 3 + index,
                          child: CategoryBreakdownCard(
                            category: cat,
                            amount: amount,
                            totalSpent: totalSpent,
                            transactionCount: count,
                            onTap: () {},
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}