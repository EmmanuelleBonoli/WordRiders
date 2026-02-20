import 'package:flutter_test/flutter_test.dart';
import 'package:word_riders/features/gameplay/services/game_state.dart';

void main() {
  group('GameState Tests', () {
    test('L\'état initial doit être vide et en cours de jeu', () {
      final state = GameState();
      
      expect(state.currentWord, isEmpty);
      expect(state.isGameOver, isFalse);
      expect(state.playerWon, isFalse);
    });

    test('addLetter doit ajouter une lettre au currentWord', () {
      final state = GameState();
      
      state.addLetter('C');
      state.addLetter('H');
      state.addLetter('A');
      state.addLetter('T');
      
      expect(state.currentWord, equals('CHAT'));
    });

    test('clearWord doit vider le currentWord', () {
      final state = GameState();
      state.addLetter('C');
      state.addLetter('H');
      
      state.clearWord();
      expect(state.currentWord, isEmpty);
    });

    test('consumeWord doit retourner le mot actuel et vider le buffer', () {
      final state = GameState();
      state.addLetter('B');
      state.addLetter('O');
      state.addLetter('N');
      
      final word = state.consumeWord();
      
      expect(word, equals('BON'));
      expect(state.currentWord, isEmpty);
    });

    test('saveValidWord et isAlreadyProposedWord gèrent les mots déjà joués', () {
      final state = GameState();
      
      expect(state.isAlreadyProposedWord('TEST'), isFalse);
      
      state.saveValidWord('TEST');
      expect(state.isAlreadyProposedWord('TEST'), isTrue);
    });

    test('setGameOver doit mettre à jour les statuts isGameOver et playerWon', () {
      final state = GameState();
      
      state.setGameOver(playerWon: true);
      expect(state.isGameOver, isTrue);
      expect(state.playerWon, isTrue);
      
      final stateLost = GameState();
      stateLost.setGameOver(playerWon: false);
      expect(stateLost.isGameOver, isTrue);
      expect(stateLost.playerWon, isFalse);
    });

    test('reset doit remettre à zéro tous les paramètres', () {
      final state = GameState();
      
      state.addLetter('E');
      state.saveValidWord('TEST');
      state.setGameOver(playerWon: true);
      
      state.reset();
      
      expect(state.currentWord, isEmpty);
      expect(state.isGameOver, isFalse);
      expect(state.playerWon, isFalse);
      expect(state.isAlreadyProposedWord('TEST'), isFalse);
    });
  });
}
