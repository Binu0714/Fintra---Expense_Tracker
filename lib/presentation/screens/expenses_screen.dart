import 'package:flutter/material.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category_type.dart';
import '../../data/models/expense_model.dart';
import '../widgets/common/expense_item_tile.dart';
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
  CategoryType? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  // Mock Expense Data
  final List<ExpenseModel> _allExpenses = [
    ExpenseModel(
      id: '1',
      title: 'Starbucks Caramel Macchiato',
      amount: 14.50,
      category: CategoryType.food,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ExpenseModel(
      id: '2',
      title: 'Nike Air Max 90 Sneakers',
      amount: 140.00,
      category: CategoryType.shopping,
      date: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    ExpenseModel(
      id: '3',
      title: 'Electricity & Power Utility',
      amount: 85.20,
      category: CategoryType.bills,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ExpenseModel(
      id: '4',
      title: 'Uber to International Airport',
      amount: 32.50,
      category: CategoryType.transport,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ExpenseModel(
      id: '5',
      title: 'Netflix 4K Ultra Subscription',
      amount: 19.99,
      category: CategoryType.entertainment,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  List<ExpenseModel> get _filteredExpenses {
    return _allExpenses.where((item) {
      // 1. Search Query Filter
      final query = _searchController.text.trim().toLowerCase();
      final matchQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          (item.note?.toLowerCase().contains(query) ?? false);

      // 2. Category Filter
      final matchCategory = _selectedCategory == null || item.category == _selectedCategory;

      // 3. Date Range Filter
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
        onSave: (savedExpense) {
          setState(() {
            final index = _allExpenses.indexWhere((e) => e.id == savedExpense.id);
            if (index >= 0) {
              _allExpenses[index] = savedExpense;
            } else {
              _allExpenses.insert(0, savedExpense);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredExpenses;
    final totalSpent = filteredList.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditSheet(),
        backgroundColor: AppColors.primaryMint,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: AppColors.black, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Controls (Pinned on Top)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  ExpenseSearchBar(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onClear: () {
                      _searchController.clear();
                      setState(() {});
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

            // Expense Items List or Empty State
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
                        onDelete: () {
                          setState(() => _allExpenses.removeWhere((e) => e.id == expense.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Expense deleted')),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}