import 'package:flutter/services.dart';

import 'game_controller.dart';

/// Sous-ensemble de [GameController] nécessaire au mapping clavier.
abstract class GameKeyboardTarget {
  /// Statut courant de la partie.
  GameStatus get status;

  /// Lettres actuellement affichées dans le mélange.
  List<String> get shuffledLetters;

  /// `true` pendant l'animation de flash de succès, qui gèle les actions.
  bool get isSuccessFlash;

  /// Ajoute [letter] à la saisie en cours, comme un tap sur la tuile.
  void onLetterTap(String letter);

  /// Efface la dernière lettre de la saisie en cours.
  void onBackspace();

  /// Valide le mot en cours. Retourne `true` s'il est accepté.
  bool validate();

  /// Mélange les lettres affichées.
  void onShuffle();
}

/// Traduit les événements clavier physiques en actions de jeu existantes
class GameKeyboardHandler {
  final GameKeyboardTarget target;
  final VoidCallback onPauseRequested;

  GameKeyboardHandler({required this.target, required this.onPauseRequested});

  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    if (target.status != GameStatus.playing || target.isSuccessFlash) {
      return false;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      target.validate();
      return true;
    }
    if (key == LogicalKeyboardKey.backspace) {
      target.onBackspace();
      return true;
    }
    if (key == LogicalKeyboardKey.escape) {
      onPauseRequested();
      return true;
    }
    if (key == LogicalKeyboardKey.space) {
      target.onShuffle();
      return true;
    }

    final letter = event.character?.toUpperCase();
    if (letter != null &&
        letter.length == 1 &&
        target.shuffledLetters.contains(letter)) {
      target.onLetterTap(letter);
      return true;
    }

    return false;
  }
}
