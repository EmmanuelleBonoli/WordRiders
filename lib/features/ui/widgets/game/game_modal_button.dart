import 'package:flutter/material.dart';
import 'package:word_train/features/ui/widgets/common/pushable_button.dart';

class GameModalButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? subLabel;

  const GameModalButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return PushableButton(
      onPressed: onPressed,
      color: color,
      width: double.infinity,
      height: 100,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: Colors.white, 
            size: 30,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
                blurRadius: 2,
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Round',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 1.5),
                  blurRadius: 2,
                )
              ],
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
