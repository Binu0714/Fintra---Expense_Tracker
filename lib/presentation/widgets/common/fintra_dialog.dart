import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum DialogType { info, warning, danger, success }

class FintraDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final DialogType type;

  const FintraDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.type = DialogType.info,
  });

  // Helper method to trigger the dialog with smooth animation
  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
        required VoidCallback onConfirm,
        VoidCallback? onCancel,
        DialogType type = DialogType.info,
      }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: AppColors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: FintraDialog(
              title: title,
              message: message,
              confirmText: confirmText,
              cancelText: cancelText,
              onConfirm: onConfirm,
              onCancel: onCancel,
              type: type,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final config = _getDialogConfig();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.6 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Icon Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: config.color.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: config.color.withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(config.icon, color: config.color, size: 32),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: InkWell(
                    onTap: onCancel ?? () => Navigator.pop(context, false),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm Action Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onConfirm();
                      Navigator.pop(context, true);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: config.gradient,
                        color: config.gradient == null ? config.color : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: config.color.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            color: config.confirmTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _DialogConfig _getDialogConfig() {
    switch (type) {
      case DialogType.danger:
        return _DialogConfig(
          icon: Icons.delete_outline_rounded,
          color: AppColors.error,
          confirmTextColor: AppColors.white,
        );
      case DialogType.warning:
        return _DialogConfig(
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFFF9F43),
          confirmTextColor: AppColors.black,
        );
      case DialogType.success:
        return _DialogConfig(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.primaryMint,
          gradient: AppColors.primaryGradient,
          confirmTextColor: AppColors.black,
        );
      case DialogType.info:
      default:
        return _DialogConfig(
          icon: Icons.info_outline_rounded,
          color: AppColors.accentBlue,
          confirmTextColor: AppColors.white,
        );
    }
  }
}

class _DialogConfig {
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;
  final Color confirmTextColor;

  _DialogConfig({
    required this.icon,
    required this.color,
    this.gradient,
    required this.confirmTextColor,
  });
}