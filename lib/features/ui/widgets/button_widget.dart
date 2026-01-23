import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

/// widget réutilisable pour les boutons du menu
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent, 
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            width: 300,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.brown, 
                width: 3,
              ),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 0, 
                  spreadRadius: 0,
                ),
              ],
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
      ),
    );
  }
}
