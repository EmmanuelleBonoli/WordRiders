import 'package:flutter/material.dart';

import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/pushable_button.dart';

class LetterButton extends StatelessWidget {
  final String letter;
  final VoidCallback onTap;

  const LetterButton({super.key, required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PushableButton(
      onPressed: onTap,
      color: AppTheme.tileFace,
      shadowColor: AppTheme.tileShadow,
      width: 54, 
      height: 54,
      borderRadius: BorderRadius.circular(27),
      depth: 5,
      child: Text(
        letter,
        style: const TextStyle(
          fontFamily: 'Round', 
          fontSize: 26, 
          fontWeight: FontWeight.w900, 
          color: AppTheme.tileText,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? shadowColor;
  final VoidCallback onTap;
  final String? label;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.shadowColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Bouton rond + Label en dessous
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PushableButton(
          onPressed: onTap,
          color: color,
          shadowColor: shadowColor,
          width: 64,
          height: 64,
          borderRadius: BorderRadius.circular(32),
          depth: 6,
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label!,
            style: const TextStyle(
              fontFamily: 'Round',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.tileText,
            ),
          )
        ]
      ],
    );
  }
}
