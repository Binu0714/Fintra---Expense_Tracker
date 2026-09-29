import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/biometric_service.dart';
import '../screens/login_screen.dart';
import 'main_shell_screen.dart';

class AppSessionGate extends StatefulWidget {
  const AppSessionGate({super.key});

  @override
  State<AppSessionGate> createState() => _AppSessionGateState();
}

class _AppSessionGateState extends State<AppSessionGate> {
  bool _isUnlocked = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkSessionAndBiometrics();
  }

  Future<void> _checkSessionAndBiometrics() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final authenticated = await BiometricService.authenticate();
      if (mounted) {
        setState(() {
          _isUnlocked = authenticated;
          _isChecking = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Session is checking
        if (_isChecking || snapshot.connectionState == ConnectionState.waiting) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryMint),
            ),
          );
        }

        // 2. User has a valid saved session & passed biometric check
        if (snapshot.hasData && snapshot.data != null) {
          if (_isUnlocked) {
            return const MainShellScreen();
          }

          // 3. User is logged in, but cancelled biometric prompt (Lock Screen)
          return _buildLockScreen(context);
        }

        // 4. No session found -> Show Login Screen
        return const LoginScreen();
      },
    );
  }

  Widget _buildLockScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMint.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fingerprint_rounded, size: 64, color: AppColors.primaryMint),
                ),
                const SizedBox(height: 24),
                Text(
                  'Fintra is Locked',
                  style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verify fingerprint to access your financial dashboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _checkSessionAndBiometrics,
                  icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
                  label: const Text('Unlock with Biometrics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}