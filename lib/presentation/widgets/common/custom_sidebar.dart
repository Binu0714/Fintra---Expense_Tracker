import 'package:flutter/material.dart';
import '../../../core/animations/staggered_slide_fade.dart';
import '../../../core/theme/app_colors.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark ? 'assets/fintra_dark.png' : 'assets/fintra_light.png';
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // 1. Big Logo Animation
              StaggeredSlideFade(
                index: 0,
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: Image.asset(
                    logoAsset,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: Text(
                          'F',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Embossed Premium User Card
              StaggeredSlideFade(
                index: 1,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const CircleAvatar(
                          radius: 19,
                          backgroundColor: AppColors.darkSurfaceVariant,
                          child: Text(
                            'M',
                            style: TextStyle(
                              color: AppColors.primaryMint,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mateen',
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'mateen@fintra.app',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildAnimatedNavItem(
                context,
                index: 0,
                animIndex: 2,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Dashboard',
              ),
              _buildAnimatedNavItem(
                context,
                index: 1,
                animIndex: 3,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Expenses',
              ),
              _buildAnimatedNavItem(
                context,
                index: 2,
                animIndex: 4,
                icon: Icons.category_outlined,
                activeIcon: Icons.category_rounded,
                label: 'Categories',
              ),
              _buildAnimatedNavItem(
                context,
                index: 3,
                animIndex: 5,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
              ),

              const Spacer(),

              StaggeredSlideFade(
                index: 6,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Fintra v1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem(
      BuildContext context, {
        required int index,
        required int animIndex,
        required IconData icon,
        required IconData activeIcon,
        required String label,
      }) {
    final isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: StaggeredSlideFade(
        index: animIndex,
        duration: const Duration(milliseconds: 400),
        child: InkWell(
          onTap: () {
            onItemSelected(index);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryMint.withValues(alpha: isDark ? 0.15 : 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: AppColors.primaryMint.withValues(alpha: 0.3), width: 1.2)
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                // Glowing Mint Indicator Bar for active state
                if (isSelected)
                  Container(
                    width: 4,
                    height: 18,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMint,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMint.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),

                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.primaryMint : textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 14),

                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? (isDark ? AppColors.white : AppColors.black) : textSecondary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),

                if (isSelected)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primaryMint,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}