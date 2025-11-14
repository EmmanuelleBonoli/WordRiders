import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/game/word_train_game.dart';
import '../../../utils/dictionary.dart';
import '../../gameplay/services/game_state.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/letter_input_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Dictionary dictionary;
  late final GameState gameState;
  late final WordTrainGame game;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    dictionary = context.read<Dictionary>();
    game = WordTrainGame(dictionary: dictionary, gameState: gameState);
  }

  @override
  void dispose() {
    gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'letterUI': (context, _) =>
              LetterInputWidget(game: game, gameState: gameState),
          'GameOver': (context, _) =>
              GameOverOverlay(game: game, gameState: gameState),
        },
        initialActiveOverlays: const ['letterUI'],
      ),
    );
  }
}
