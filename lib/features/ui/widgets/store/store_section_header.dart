import 'package:flutter/material.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';

class StoreSectionHeader extends StatelessWidget {
  final String title;

  const StoreSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.stars, color: AppTheme.orangeBurnt, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Round',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.white,
             shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
  }
}
