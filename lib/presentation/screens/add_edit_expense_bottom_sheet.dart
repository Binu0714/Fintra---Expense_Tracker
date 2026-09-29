import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category_type.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../widgets/common/fintra_dialog.dart';

class AddEditExpenseBottomSheet extends StatefulWidget {
  final ExpenseModel? existingExpense;
  final VoidCallback? onExpenseAdded;

  const AddEditExpenseBottomSheet({
    super.key,
    this.existingExpense,
    this.onExpenseAdded,
  });

  @override
  State<AddEditExpenseBottomSheet> createState() => _AddEditExpenseBottomSheetState();
}

class _AddEditExpenseBottomSheetState extends State<AddEditExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late CategoryType _selectedCategory;
  late DateTime _selectedDate;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingExpense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.existingExpense != null ? widget.existingExpense!.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: widget.existingExpense?.note ?? '');
    _selectedCategory = widget.existingExpense?.category ?? CategoryType.food;
    _selectedDate = widget.existingExpense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final isNew = widget.existingExpense == null;

      if (isNew) {
        // 1. Add New
        final newExpense = ExpenseModel(
          id: '',
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          category: _selectedCategory,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
        await _expenseRepository.addExpense(newExpense);
      } else {
        // 2. Update Existing
        final updatedExpense = ExpenseModel(
          id: widget.existingExpense!.id,
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          category: _selectedCategory,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
        await _expenseRepository.updateExpense(updatedExpense);
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.pop(context);
      widget.onExpenseAdded?.call();


      FintraDialog.show(
        context,
        type: DialogType.success,
        title: isNew ? 'Expense Added!' : 'Expense Updated!',
        message: isNew
            ? 'Your expense of \$${_amountController.text.trim()} has been recorded.'
            : 'Your expense "${_titleController.text.trim()}" has been updated.',
        confirmText: 'Done',
        onConfirm: () {},
      );

    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      FintraDialog.show(
        context,
        type: DialogType.danger,
        title: 'Error',
        message: e.toString(),
        confirmText: 'Okay',
        onConfirm: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: cardBorder, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.6 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag Handle Pill
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Header Title with Close Button
              StaggeredSlideFade(
                index: 0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingExpense == null ? 'Add Expense' : 'Edit Expense',
                      style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Hero Center Amount Card
              StaggeredSlideFade(
                index: 1,
                duration: const Duration(milliseconds: 350),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMint.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'AMOUNT SPENT',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryMint,
                            letterSpacing: -1,
                          ),
                          decoration: InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            prefixText: '\RS ',
                            prefixStyle: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: textSecondary.withValues(alpha: 0.3),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),

                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter an amount';
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                            return null;
                          },

                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Title Input Card
              StaggeredSlideFade(
                index: 2,
                duration: const Duration(milliseconds: 400),
                child: TextFormField(
                  controller: _titleController,
                  style: TextStyle(color: textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Expense Title / Merchant',
                    prefixIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primaryMint, size: 20),
                  ),
                  validator: (val) =>
                  (val == null || val.trim().length < 3) ? 'Minimum 3 characters required' : null,
                ),
              ),
              const SizedBox(height: 18),

              // 5. Category Selection Grid
              StaggeredSlideFade(
                index: 3,
                duration: const Duration(milliseconds: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CategoryType.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return InkWell(
                          onTap: () => setState(() => _selectedCategory = cat),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryMint.withValues(alpha: 0.15)
                                  : cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryMint : cardBorder,
                                width: isSelected ? 1.4 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 16, color: cat.color),
                                const SizedBox(width: 6),
                                Text(
                                  cat.label,
                                  style: TextStyle(
                                    color: isSelected ? textPrimary : textSecondary,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 6. Date Selection
              StaggeredSlideFade(
                index: 4,
                duration: const Duration(milliseconds: 500),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.primaryMint),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                              style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Icon(Icons.edit_calendar_rounded, size: 16, color: textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Optional Note Input
              StaggeredSlideFade(
                index: 5,
                duration: const Duration(milliseconds: 550),
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Notes / Details (Optional)',
                    prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.primaryMint, size: 22),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 8. Creative Save Action Button
              StaggeredSlideFade(
                index: 6,
                duration: const Duration(milliseconds: 600),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMint ,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMint.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.black),
                    )
                        : Text(
                      widget.existingExpense == null ? 'Save Expense' : 'Update Expense',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}