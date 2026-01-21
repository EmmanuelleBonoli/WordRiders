import 'package:flutter/material.dart';
import '../../gameplay/services/game_state.dart';
import '../../../core/game/word_train_game.dart';
import '../../../core/constants/game_constants.dart';

class LetterInputWidget extends StatelessWidget {
  final WordTrainGame game;
  final GameState gameState;

  // TODO: Générer dynamiquement ces lettres
  final List<String> letters = const ['A', 'R', 'T', 'O', 'N', 'E', 'S', 'I'];

  const LetterInputWidget({
    super.key,
    required this.game,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(GameConstants.uiPadding),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9), // Glassy effect
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrentWord(theme),
            const SizedBox(height: GameConstants.buttonSpacing),
            _buildLetterButtons(theme),
            const SizedBox(height: GameConstants.buttonSpacing),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWord(ThemeData theme) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            gameState.currentWord.isEmpty ? " " : gameState.currentWord,
            style: theme.textTheme.headlineMedium?.copyWith(
               color: theme.colorScheme.onSurface,
               letterSpacing: GameConstants.letterSpacing,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLetterButtons(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: letters.map((letter) {
        return GestureDetector(
          onTap: () => gameState.addLetter(letter),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Ivory
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                // 3D Depth
                BoxShadow(
                  color: const Color(0xFFD7CCC8), // Darker beige
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D4037), // Brown text
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: gameState.clearWord,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.error,
          ),
          child: const Text('Effacer'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: game.validateWord,
          // Uses default secondary color from theme but we can enforce it
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
