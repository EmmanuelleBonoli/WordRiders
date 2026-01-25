import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/game/game_buttons.dart';

class GameInputArea extends StatelessWidget {
  final String? feedbackMessage;
  final String currentInput;
  final List<String> shuffledLetters;
  final VoidCallback onBackspace;
  final VoidCallback onValidate;
  final VoidCallback onShuffle;
  final Function(String) onLetterTap;

  const GameInputArea({
    super.key,
    required this.feedbackMessage,
    required this.currentInput,
    required this.shuffledLetters,
    required this.onBackspace,
    required this.onValidate,
    required this.onShuffle,
    required this.onLetterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feedback
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: feedbackMessage != null ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(24)),
              child: Text(
                feedbackMessage ?? "",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // Input Row
          Row(
            children: [
               ActionButton(icon: Icons.backspace_rounded, color: AppTheme.red, onTap: onBackspace),
               const SizedBox(width: 12),
               Expanded(
                 child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.brown, width: 2),
                    ),
                    child: Text(
                      currentInput,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.textDark),
                    ),
                 ),
               ),
               const SizedBox(width: 12),
               ActionButton(icon: Icons.check_circle_rounded, color: AppTheme.green, onTap: onValidate),
            ],
          ),
          
          const SizedBox(height: 12),

          // Lettres
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ...shuffledLetters.map((l) => LetterButton(letter: l, onTap: () => onLetterTap(l))),
              const SizedBox(width: 24),
              ActionButton(icon: Icons.shuffle_rounded, color: AppTheme.orange, onTap: onShuffle),
            ],
          ),
        ],
      ),
    );
  }
}
