import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

/// widget réutilisable pour les boutons du menu
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const MenuButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: BouncingScaleButton(
        onTap: onPressed,
        scaleTarget: 0.96, 
        child: Container(
          width: 250,
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.brown, 
              width: 3,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Round',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.brown,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
