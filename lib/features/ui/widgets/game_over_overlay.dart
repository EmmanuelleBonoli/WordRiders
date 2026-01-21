import 'package:flutter/material.dart';
import '../../gameplay/services/game_state.dart';
import '../../../core/game/word_train_game.dart';

class GameOverOverlay extends StatelessWidget {
  final WordTrainGame game;
  final GameState gameState;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gameState.playerWon ? '🏆 Victoire !' : '💀 Défaite !',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: gameState.playerWon ? theme.primaryColor : theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: game.resetGame,
                child: const Text('Rejouer'), // Style inherited from theme
              ),
            ],
          ),
        ),
      ),
    );
  }
}
