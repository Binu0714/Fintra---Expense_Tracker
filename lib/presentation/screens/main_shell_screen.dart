import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/common/custom_bottom_nav.dart';
import '../widgets/common/custom_sidebar.dart';
import 'categories_screen.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  final AuthRepository _authRepository = AuthRepository();

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

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _authRepository.getUserProfileStream(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();
        final currentAuthUser = _authRepository.currentUser;

        // Fallbacks if Firestore document is loading
        final userName = userData?['name'] ?? currentAuthUser?.displayName ?? 'User';
        final userEmail = userData?['email'] ?? currentAuthUser?.email ?? 'user@fintra.app';
        final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        final List<Widget> pages = [
          DashboardScreen(
            userName: userName,
            onSwitchTab: (targetIndex) {
              setState(() {
                _currentIndex = targetIndex;
              });
            },
          ),
          const ExpensesScreen(),
          const CategoriesScreen(),
          SettingsScreen(userName: userName, userEmail: userEmail),
        ];

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          drawer: CustomSidebar(
            selectedIndex: _currentIndex,
            userName: userName,
            userEmail: userEmail,
            userInitial: userInitial,
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
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.notifications_none_rounded, color: textPrimary, size: 20),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications'),
                          backgroundColor: AppColors.primaryMint,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _currentIndex == 3 ? Icons.settings_outlined : Icons.settings_outlined,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() => _currentIndex = 3); // Jumps to Settings Tab
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _currentIndex,
            onTabSelected: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }
}