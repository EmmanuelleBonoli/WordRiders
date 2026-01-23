import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class StageCircle extends StatelessWidget {
  final int number;
  final bool unlocked;

  const StageCircle({required this.number, required this.unlocked, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final Color baseColor = unlocked ? AppTheme.cream : AppTheme.brown;
    final Color borderColor = unlocked ? AppTheme.brown : AppTheme.cream.withValues(alpha: 0.5);
    final Color textColor = unlocked ? AppTheme.brown : AppTheme.cream.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: baseColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: [
          if (unlocked)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), 
              offset: const Offset(0, 4),
              blurRadius: 2,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: theme.textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontFamily: 'Round',
        ),
      ),
    );
  }
}
