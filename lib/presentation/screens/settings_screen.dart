import 'package:flutter/material.dart';
import '../../core/animations/staggered_slide_fade.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/common/fintra_dialog.dart';
import '../widgets/settings/edit_profile_bottom_sheet.dart';
import '../widgets/settings/settings_action_tile.dart';
import '../widgets/settings/settings_section_card.dart';
import '../widgets/settings/settings_toggle_tile.dart';
import '../widgets/settings/user_profile_card.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SettingsScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'Mateen';
  String _email = 'mateen@fintra.app';
  bool _notificationsEnabled = true;

  late bool _isDarkMode = ThemeController.isDark;

  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileBottomSheet(
        currentName: _userName,
        currentEmail: _email,
        onSave: (name, email) {
          setState(() {
            _userName = name;
            _email = email;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.primaryMint,
            ),
          );
        },
      ),
    );
  }

  void _onLogout() {
    FintraDialog.show(
      context,
      type: DialogType.danger,
      title: 'Log Out of Fintra',
      message: 'Are you sure you want to log out? Your synced records remain safe in Firebase.',
      confirmText: 'Log Out',
      cancelText: 'Stay',
      onConfirm: () async {
        final authRepo = AuthRepository();
        await authRepo.signOut();

        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Profile Hero Card
              StaggeredSlideFade(
                index: 0,
                child: UserProfileCard(
                  userName: widget.userName,
                  email: widget.userEmail,
                  onEdit: _openEditProfile,
                ),
              ),

              const SizedBox(height: 24),

              // 2. Preferences Section with Global Theme Toggle
              StaggeredSlideFade(
                index: 1,
                child: SettingsSectionCard(
                  title: 'App Preferences',
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: ThemeController.themeMode,
                      builder: (context, currentMode, _) {
                        final isDarkActive = currentMode == ThemeMode.dark;

                        return SettingsToggleTile(
                          icon: isDarkActive
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          title: 'Dark Theme',
                          subtitle: isDarkActive
                              ? 'Pitch Dark theme active'
                              : 'Clean Light theme active',
                          value: isDarkActive,
                          onChanged: (val) {
                            ThemeController.toggleTheme(val); // Triggers app-wide rebuild
                          },
                        );
                      },
                    ),
                    Divider(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      height: 1,
                      indent: 60,
                    ),
                    SettingsToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Daily expense reminders & summary',
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Finance & Account Section
              StaggeredSlideFade(
                index: 2,
                child: SettingsSectionCard(
                  title: 'Finance & Security',
                  children: [

                    SettingsActionTile(
                      icon: Icons.cloud_sync_outlined,
                      title: 'Firebase Cloud Backup',
                      valueText: 'Synced',
                      onTap: () {},
                    ),
                    SettingsActionTile(
                      icon: Icons.security_rounded,
                      title: 'Security & Privacy',
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Log Out Button
              StaggeredSlideFade(
                index: 3,
                child: InkWell(
                  onTap: _onLogout,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Log Out of Fintra',
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
              ),

              const SizedBox(height: 18),

              // 5. Version Info
              StaggeredSlideFade(
                index: 4,
                child: Text(
                  'Fintra v1.0.0 • Built with Flutter & Firebase',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}