import 'category_type.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final CategoryType category;
  final DateTime date;
  final String? note;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });
}