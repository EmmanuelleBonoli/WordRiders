import 'package:flutter/material.dart';

import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/pushable_button.dart';

class LetterButton extends StatelessWidget {
  final String letter;
  final VoidCallback onTap;

  const LetterButton({super.key, required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PushableButton(
      onPressed: onTap,
      color: AppTheme.cream,
      width: 50,
      height: 50,
      borderRadius: BorderRadius.circular(12),
      depth: 6,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: AppTheme.darkBrown
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
    return PushableButton(
      onPressed: onTap,
      color: color,
      width: 56,
      height: 56,
      borderRadius: BorderRadius.circular(16),
      depth: 6,
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }
}
