import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/pushable_button.dart';

// widget réutilisable pour les boutons du menu
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? highlightColor;

  const MenuButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.backgroundColor,
    this.shadowColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: PushableButton(
        onPressed: onPressed,
        color: backgroundColor ?? AppTheme.tileFace,
        shadowColor: shadowColor,
        highlightColor: highlightColor,
        width: 250,
        height: 64,
        borderRadius: BorderRadius.circular(20),
        depth: 6,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Round',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.brown,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: 0.5),
                offset: const Offset(0, 1),
                blurRadius: 0,
              )
            ]
          ),
        ),
      ),
    );
  }
}
