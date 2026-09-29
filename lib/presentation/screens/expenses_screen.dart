import 'package:flutter/material.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category_type.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../widgets/common/expense_item_tile.dart';
import '../widgets/common/fintra_dialog.dart';
import '../widgets/expenses/category_filter_bar.dart';
import '../widgets/expenses/date_filter_header.dart';
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

  // Filter Firestore stream results in memory
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
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryMint),
              );
            }

            // 2. Error State
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Failed to load expenses',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final rawExpenses = snapshot.data ?? [];
            final filteredList = _applyFilters(rawExpenses);
            final totalSpent = filteredList.fold(0.0, (sum, item) => sum + item.amount);

            return Column(
              children: [
                // Pinned Filter Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      ExpenseSearchBar(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        onClear: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      CategoryFilterBar(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                      ),
                      const SizedBox(height: 12),
                      DateFilterHeader(
                        selectedDateRange: _selectedDateRange,
                        totalCount: filteredList.length,
                        totalAmount: totalSpent,
                        onSelectDateRange: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDateRange: _selectedDateRange,
                          );
                          if (range != null) setState(() => _selectedDateRange = range);
                        },
                        onClearDateRange: () => setState(() => _selectedDateRange = null),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Realtime List from Firestore or Empty State
                Expanded(
                  child: filteredList.isEmpty
                      ? ExpensesEmptyView(
                    onClearFilters: () {
                      setState(() {
                        _searchController.clear();
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}