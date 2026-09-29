import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/common/custom_sidebar.dart';
import '../widgets/common/custom_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ExpensesScreen(),
    const PlaceholderPage(title: 'Categories Management'),
    const PlaceholderPage(title: 'Settings & Preferences'),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Expenses',
    'Categories',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: CustomSidebar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
      ),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.notes_rounded, color: textPrimary, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: textPrimary, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          if (_currentIndex == index) return;
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}