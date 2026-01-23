import 'package:flutter/material.dart';

import 'package:word_train/features/ui/styles/app_theme.dart';

class LetterButton extends StatelessWidget {
  final String letter;
  final VoidCallback onTap;

  const LetterButton({super.key, required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cream, 
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.brown, width: 2),
          boxShadow: [
             BoxShadow(color: Colors.black26, offset: Offset(0, 3)),
          ]
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
