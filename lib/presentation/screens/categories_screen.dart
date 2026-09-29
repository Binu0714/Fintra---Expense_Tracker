import 'package:flutter/material.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category_type.dart';
import '../../data/models/expense_model.dart';
import '../widgets/categories/category_breakdown_card.dart';
import '../widgets/categories/category_donut_chart_card.dart';
import '../widgets/categories/category_month_selector.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  DateTime _selectedMonth = DateTime.now();

  // Mock Expense Data
  final List<ExpenseModel> _mockExpenses = [
    ExpenseModel(
      id: '1',
      title: 'Whole Foods Market',
      amount: 180.50,
      category: CategoryType.food,
      date: DateTime.now(),
    ),
    ExpenseModel(
      id: '2',
      title: 'Starbucks Coffee',
      amount: 24.50,
      category: CategoryType.food,
      date: DateTime.now(),
    ),
    ExpenseModel(
      id: '3',
      title: 'Nike Air Max',
      amount: 140.00,
      category: CategoryType.shopping,
      date: DateTime.now(),
    ),
    ExpenseModel(
      id: '4',
      title: 'Electricity & Gas Bill',
      amount: 110.00,
      category: CategoryType.bills,
      date: DateTime.now(),
    ),
    ExpenseModel(
      id: '5',
      title: 'Uber to Office',
      amount: 45.00,
      category: CategoryType.transport,
      date: DateTime.now(),
    ),
    ExpenseModel(
      id: '6',
      title: 'Netflix Subscription',
      amount: 19.99,
      category: CategoryType.entertainment,
      date: DateTime.now(),
    ),
  ];

  Map<CategoryType, double> get _categoryTotals {
    final Map<CategoryType, double> map = {};
    for (var cat in CategoryType.values) {
      final total = _mockExpenses
          .where((e) => e.category == cat)
          .fold(0.0, (sum, item) => sum + item.amount);
      if (total > 0) {
        map[cat] = total;
      }
    }
    return map;
  }

  int _countPerCategory(CategoryType cat) {
    return _mockExpenses.where((e) => e.category == cat).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final totals = _categoryTotals;
    final totalSpent = totals.values.fold(0.0, (sum, val) => sum + val);

    // Sort categories from highest spend to lowest
    final sortedCategories = totals.keys.toList()
      ..sort((a, b) => (totals[b] ?? 0).compareTo(totals[a] ?? 0));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Month Switcher
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

              // 2. Spending Distribution Donut Card
              StaggeredSlideFade(
                index: 1,
                child: CategoryDonutChartCard(
                  categoryTotals: totals,
                  totalSpent: totalSpent,
                ),
              ),

              const SizedBox(height: 24),

              // 3. Category List Section Title
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

              // 4. Staggered Category Breakdown Cards
              ...List.generate(sortedCategories.length, (index) {
                final cat = sortedCategories[index];
                final amount = totals[cat] ?? 0.0;
                final count = _countPerCategory(cat);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: StaggeredSlideFade(
                    index: 3 + index,
                    child: CategoryBreakdownCard(
                      category: cat,
                      amount: amount,
                      totalSpent: totalSpent,
                      transactionCount: count,
                      onTap: () {
                        // Open filtered list sheet if needed
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}