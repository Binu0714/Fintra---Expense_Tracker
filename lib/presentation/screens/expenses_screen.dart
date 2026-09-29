import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category_type.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../widgets/common/expense_item_tile.dart';
import '../widgets/common/fintra_dialog.dart';
import '../widgets/dashboard/total_expenses_hero_card.dart';
import '../widgets/expenses/category_filter_bar.dart';
import '../widgets/expenses/expense_search_bar.dart';
import '../widgets/expenses/expenses_empty_view.dart';
import 'add_edit_expense_bottom_sheet.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  String _searchQuery = '';
  CategoryType? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseModel> _applyFilters(List<ExpenseModel> allExpenses) {
    return allExpenses.where((item) {
      final query = _searchQuery.trim().toLowerCase();
      final matchQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          (item.note?.toLowerCase().contains(query) ?? false);

      final matchCategory = _selectedCategory == null || item.category == _selectedCategory;

      final matchDate = _selectedDateRange == null ||
          (item.date.isAfter(_selectedDateRange!.start.subtract(const Duration(seconds: 1))) &&
              item.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

      return matchQuery && matchCategory && matchDate;
    }).toList();
  }

  void _openAddEditSheet([ExpenseModel? expense]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditExpenseBottomSheet(
        existingExpense: expense,
      ),
    );
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    try {
      await _expenseRepository.deleteExpense(expense.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${expense.title}"'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      FintraDialog.show(
        context,
        type: DialogType.danger,
        title: 'Delete Failed',
        message: e.toString(),
        confirmText: 'Okay',
        onConfirm: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditSheet(),
        backgroundColor: AppColors.primaryMint,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: AppColors.black, size: 28),
      ),
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

            final rawExpenses = snapshot.data ?? [];
            final filteredList = _applyFilters(rawExpenses);
            final totalFiltered = filteredList.fold(0.0, (sum, item) => sum + item.amount);

            String dateFilterLabel = 'All Time';
            if (_selectedDateRange != null) {
              final start = DateFormat('d MMM').format(_selectedDateRange!.start);
              final end = DateFormat('d MMM yyyy').format(_selectedDateRange!.end);
              dateFilterLabel = '$start - $end';
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          StaggeredSlideFade(
                            index: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ExpenseSearchBar(
                                    controller: _searchController,
                                    onChanged: (val) => setState(() => _searchQuery = val),
                                    onClear: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Date Range Icon Button
                                InkWell(
                                  onTap: () async {
                                    final range = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      initialDateRange: _selectedDateRange,
                                    );
                                    if (range != null) setState(() => _selectedDateRange = range);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: _selectedDateRange != null
                                          ? AppColors.primaryMint.withValues(alpha: 0.15)
                                          : cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _selectedDateRange != null
                                            ? AppColors.primaryMint
                                            : cardBorder,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      color: _selectedDateRange != null
                                          ? AppColors.primaryMint
                                          : textSecondary,
                                      size: 22,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          //  Total Expense Hero Card
                          StaggeredSlideFade(
                            index: 0,
                            child: TotalExpensesHeroCard(
                              totalAmount: totalFiltered,
                              title: 'Filtered Total',
                              badgeText: '${filteredList.length} items',
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Category Filter Chips
                          StaggeredSlideFade(
                            index: 2,
                            child: CategoryFilterBar(
                              selectedCategory: _selectedCategory,
                              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Active Filters Status Tag Row
                          if (_selectedDateRange != null || _selectedCategory != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (_selectedDateRange != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryMint.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                dateFilterLabel,
                                                style: const TextStyle(
                                                  color: AppColors.primaryMint,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              InkWell(
                                                onTap: () => setState(() => _selectedDateRange = null),
                                                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primaryMint),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        'Showing ${filteredList.length} expenses',
                                        style: TextStyle(color: textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = null;
                                        _selectedDateRange = null;
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                    child: const Text(
                                      'Reset',
                                      style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: filteredList.isEmpty
                  ? ExpensesEmptyView(
                onClearFilters: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _selectedCategory = null;
                    _selectedDateRange = null;
                  });
                },
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final expense = filteredList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: StaggeredSlideFade(
                      index: index,
                      child: ExpenseItemTile(
                        expense: expense,
                        onTap: () => _openAddEditSheet(expense),
                        onDelete: () => _deleteExpense(expense),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}