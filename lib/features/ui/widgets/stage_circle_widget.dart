import 'package:flutter/material.dart';

class StageCircle extends StatelessWidget {
  final int number;
  final bool unlocked;

  const StageCircle({required this.number, required this.unlocked, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = unlocked ? theme.primaryColor : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 44, // Slightly larger
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
