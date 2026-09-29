import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum CategoryType {
  food('Food & Dining', Icons.restaurant_rounded, Color(0xFFFF9F43)),
  shopping('Shopping', Icons.shopping_bag_rounded, Color(0xFF54A0FF)),
  transport('Transport', Icons.directions_car_filled_rounded, Color(0xFF1DD1A1)),
  bills('Bills & Utilities', Icons.receipt_long_rounded, Color(0xFFFF6B6B)),
  entertainment('Entertainment', Icons.movie_filter_rounded, Color(0xFF9B59B6)),
  health('Healthcare', Icons.favorite_rounded, Color(0xFFFF7675)),
  other('Other', Icons.category_rounded, AppColors.primaryMint);

  final String label;
  final IconData icon;
  final Color color;

  const CategoryType(this.label, this.icon, this.color);
}