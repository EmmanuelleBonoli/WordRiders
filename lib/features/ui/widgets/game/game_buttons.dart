import 'package:flutter/material.dart';

import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class LetterButton extends StatelessWidget {
  final String letter;
  final VoidCallback onTap;

  const LetterButton({super.key, required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingScaleButton(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cream, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.brown, width: 2),
        ),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: AppTheme.darkBrown
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingScaleButton(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
