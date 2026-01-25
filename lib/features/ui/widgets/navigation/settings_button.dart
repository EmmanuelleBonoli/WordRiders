import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SettingsButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingScaleButton(
      onTap: onTap ?? () => context.push('/settings'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.cream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.brown, width: 2),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.settings_rounded,
          color: AppTheme.brown,
          size: 28,
        ),
      ),
    );
  }
}
