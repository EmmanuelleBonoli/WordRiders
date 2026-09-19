import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_riders/features/gameplay/controllers/game_controller.dart';
import 'package:word_riders/features/gameplay/controllers/game_keyboard_handler.dart';

/// Double de test léger, sans dépendance au dictionnaire asynchrone
/// de [GameController].
class _FakeGameKeyboardTarget implements GameKeyboardTarget {
  @override
  GameStatus status = GameStatus.playing;

  @override
  List<String> shuffledLetters = ['A', 'B', 'C'];

  @override
  bool isSuccessFlash = false;

  final List<String> tappedLetters = [];
  int backspaceCount = 0;
  int validateCount = 0;
  int shuffleCount = 0;

  @override
  void onLetterTap(String letter) => tappedLetters.add(letter);

  @override
  void onBackspace() => backspaceCount++;

  @override
  bool validate() {
    validateCount++;
    return true;
  }

  @override
  void onShuffle() => shuffleCount++;
}

KeyEvent _keyDown(LogicalKeyboardKey key, {String? character}) {
  return KeyDownEvent(
    physicalKey: PhysicalKeyboardKey.keyA,
    logicalKey: key,
    character: character,
    timeStamp: Duration.zero,
  );
}

KeyEvent _keyUp(LogicalKeyboardKey key) {
  return KeyUpEvent(
    physicalKey: PhysicalKeyboardKey.keyA,
    logicalKey: key,
    timeStamp: Duration.zero,
  );
}

void main() {
  group('GameKeyboardHandler', () {
    late _FakeGameKeyboardTarget target;
    late bool pauseRequested;
    late GameKeyboardHandler handler;

    setUp(() {
      target = _FakeGameKeyboardTarget();
      pauseRequested = false;
      handler = GameKeyboardHandler(
        target: target,
        onPauseRequested: () => pauseRequested = true,
      );
    });

    test('une lettre présente dans le mélange est transmise au tap', () {
      final consumed = handler.handleKeyEvent(
        _keyDown(LogicalKeyboardKey.keyA, character: 'a'),
      );

      expect(consumed, isTrue);
      expect(target.tappedLetters, equals(['A']));
    });

    test(
      'une touche ne correspondant à aucune lettre du mélange est ignorée',
      () {
        final consumed = handler.handleKeyEvent(
          _keyDown(LogicalKeyboardKey.keyZ, character: 'z'),
        );

        expect(consumed, isFalse);
        expect(target.tappedLetters, isEmpty);
      },
    );

    test(
      'une lettre dupliquée dans le mélange peut être tapée plusieurs fois',
      () {
        target.shuffledLetters = ['E', 'R', 'R', 'E'];

        handler.handleKeyEvent(
          _keyDown(LogicalKeyboardKey.keyR, character: 'r'),
        );
        handler.handleKeyEvent(
          _keyDown(LogicalKeyboardKey.keyR, character: 'r'),
        );

        expect(target.tappedLetters, equals(['R', 'R']));
      },
    );

    test('Entrée valide le mot en cours', () {
      final consumed = handler.handleKeyEvent(
        _keyDown(LogicalKeyboardKey.enter),
      );

      expect(consumed, isTrue);
      expect(target.validateCount, equals(1));
    });

    test('Retour arrière efface la dernière lettre saisie', () {
      final consumed = handler.handleKeyEvent(
        _keyDown(LogicalKeyboardKey.backspace),
      );

      expect(consumed, isTrue);
      expect(target.backspaceCount, equals(1));
    });

    test('Échap met la partie en pause quand le statut est "playing"', () {
      final consumed = handler.handleKeyEvent(
        _keyDown(LogicalKeyboardKey.escape),
      );

      expect(consumed, isTrue);
      expect(pauseRequested, isTrue);
    });

    test(
      'Échap n\'a aucun effet si la partie n\'est pas en statut "playing"',
      () {
        target.status = GameStatus.paused;

        final consumed = handler.handleKeyEvent(
          _keyDown(LogicalKeyboardKey.escape),
        );

        expect(consumed, isFalse);
        expect(pauseRequested, isFalse);
      },
    );

    test(
      'Espace déclenche un mélange et est consommé (pas de défilement page)',
      () {
        final consumed = handler.handleKeyEvent(
          _keyDown(LogicalKeyboardKey.space),
        );

        expect(consumed, isTrue);
        expect(target.shuffleCount, equals(1));
      },
    );

    test('aucune touche n\'a d\'effet hors du statut "playing"', () {
      target.status = GameStatus.paused;

      final consumed = handler.handleKeyEvent(
        _keyDown(LogicalKeyboardKey.keyA, character: 'a'),
      );

      expect(consumed, isFalse);
      expect(target.tappedLetters, isEmpty);
    });

    test('seuls les KeyDownEvent sont traités, pas les KeyUpEvent', () {
      final consumed = handler.handleKeyEvent(_keyUp(LogicalKeyboardKey.keyA));

      expect(consumed, isFalse);
      expect(target.tappedLetters, isEmpty);
    });

    test(
      'aucune touche n\'a d\'effet pendant le flash de succès, même en statut "playing"',
      () {
        target.isSuccessFlash = true;

        final consumed = handler.handleKeyEvent(
          _keyDown(LogicalKeyboardKey.escape),
        );

        expect(consumed, isFalse);
        expect(pauseRequested, isFalse);
      },
    );
  });
}
