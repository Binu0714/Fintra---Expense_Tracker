import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Gradient
  static const Color primaryMint = Color(0xFF00E871);
  static const Color primaryCyan = Color(0xFF00D2B4);
  static const Color primaryDarkGreen = Color(0xFF00965E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryMint, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0C0E12);
  static const Color darkCard = Color(0xFF161B22);
  static const Color darkInput = Color(0xFF1E242E);
  static const Color darkBorder = Color(0xFF2B3240);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightInput = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Functional Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color transparent = Colors.transparent;
}