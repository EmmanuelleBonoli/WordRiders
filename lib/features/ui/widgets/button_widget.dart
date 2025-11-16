import 'package:flutter/material.dart';

/// widget réutilisable pour les boutons du menu
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF303030),
          fixedSize: const Size(280, 55),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
