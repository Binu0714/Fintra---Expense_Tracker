import 'package:flutter/material.dart';
import '../../../core/animations/staggered_slide_fade.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../common/fintra_dialog.dart';

class ForgotPasswordBottomSheet extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordBottomSheet({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordBottomSheet> createState() => _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      await _authRepository.sendPasswordResetEmail(email);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pop(context); // Close bottom sheet

      // Show Custom Success Alert
      FintraDialog.show(
        context,
        type: DialogType.success,
        title: 'Reset Link Sent!',
        message: 'A password reset link has been sent to $email. Please check your inbox and spam folder.',
        confirmText: 'Back to Login',
        onConfirm: () {},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      FintraDialog.show(
        context,
        type: DialogType.danger,
        title: 'Reset Failed',
        message: e.toString(),
        confirmText: 'Try Again',
        onConfirm: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
    child:  Container(
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Handle
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

              // Title Row
              StaggeredSlideFade(
                index: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
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
              const SizedBox(height: 16),

              // Icon & Subtitle
              StaggeredSlideFade(
                index: 1,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMint.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 38,
                          color: AppColors.primaryMint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter your registered email address and we will send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Email Input Field
              StaggeredSlideFade(
                index: 2,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Registered Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryMint),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              StaggeredSlideFade(
                index: 3,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                        : const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        color: Colors.white,
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
    ));
  }
}