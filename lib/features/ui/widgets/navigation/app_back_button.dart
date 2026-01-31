import 'package:flutter/material.dart';

import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/pushable_button.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PushableButton(
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      color: const Color(0xFFFCE1AE),
      shadowColor: const Color(0xFFDCA750),
      highlightColor: const Color(0xFFFFF5D6),
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(12),
      depth: 6,
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AppTheme.brown,
        size: 28,
      ),
    );
  }
}
