import 'package:flutter/material.dart';

/// widget réutilisable pour les boutons du menu
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 300,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF53B8BB), // Secondary Blue (Lighter)
                Color(0xFF429295), // Secondary Blue (Darker)
              ],
            ),
            boxShadow: [
              // Bottom shadow for 3D effect
              BoxShadow(
                color: Color(0xFF2C6C6E),
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
              // Soft shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(0, 8),
                blurRadius: 10,
              ),
              // Inner highlight for gloss
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                offset: Offset(0, 2),
                blurRadius: 0,
                spreadRadius: -2,
                // blurStyle: BlurStyle.inner, // Not widely supported, simulating with gradient
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
