import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/pushable_button.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SettingsButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PushableButton(
      onPressed: onTap ?? () => context.push('/settings'),
      color: const Color(0xFFFCE1AE),
      shadowColor: const Color(0xFFDCA750),
      highlightColor: const Color(0xFFFFF5D6),
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(12),
      depth: 6,
      child: const Icon(
        Icons.settings_rounded,
        color: AppTheme.brown,
        size: 28,
      ),
    );
  }
}
