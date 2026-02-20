import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';

void main() {
  setUp(() async {
    // Simule une base SharedPreferences vide avant chaque test
    SharedPreferences.setMockInitialValues({});
    
    // Pour forcer la réinitialisation du singleton/cache de PlayerPreferences
    // on utilise un reset 'manuel' complet
    await PlayerPreferences.resetCampaign();
    await PlayerPreferences.setCoins(0);
    await PlayerPreferences.setLives(5);
  });

  group('PlayerPreferences Tests - Économie & Progression', () {
    test('getProfile initialise bien les valeurs par défaut', () async {
      final stage = await PlayerPreferences.getCurrentStage();
      final coins = await PlayerPreferences.getCoins();
      
      expect(stage, equals(1));
      expect(coins, equals(0));
    });

    test('addCoins, setCoins et spendCoins modifient l\'économie correctement', () async {
      await PlayerPreferences.setCoins(100);
      expect(await PlayerPreferences.getCoins(), equals(100));

      await PlayerPreferences.addCoins(50);
      expect(await PlayerPreferences.getCoins(), equals(150));

      final successFalse = await PlayerPreferences.spendCoins(200);
      expect(successFalse, isFalse, reason: 'Ne devrait pas pouvoir dépenser plus de pièces que possédées');
      expect(await PlayerPreferences.getCoins(), equals(150)); // Solde inchangé

      final successTrue = await PlayerPreferences.spendCoins(100);
      expect(successTrue, isTrue, reason: 'Devrait pouvoir dépenser les pièces possédées');
      expect(await PlayerPreferences.getCoins(), equals(50)); // Solde débité
    });

    test('loseLife et setLives gèrent bien le compteur de vies', () async {
      await PlayerPreferences.setLives(5);
      expect(await PlayerPreferences.getLives(), equals(5));

      final success = await PlayerPreferences.loseLife();
      expect(success, isTrue);
      expect(await PlayerPreferences.getLives(), equals(4));
      
      // On vide les vies
      await PlayerPreferences.setLives(0);
      final lostAgain = await PlayerPreferences.loseLife();
      expect(lostAgain, isFalse, reason: 'Ne devrait pas pouvoir perdre de vie si le solde est à 0');
    });
    
    test('La mémoire des mots utilisés fonctionne', () async {
      await PlayerPreferences.addUsedWord('TEST');
      await PlayerPreferences.addUsedWord('POULET');
      
      final usedWords = await PlayerPreferences.getUsedWords();
      expect(usedWords.contains('TEST'), isTrue);
      expect(usedWords.contains('POULET'), isTrue);
      expect(usedWords.contains('CHAT'), isFalse);
    });

    test('Les paramètres audio sont sauvegardées (Settings)', () async {
      await PlayerPreferences.setMusicEnabled(false);
      expect(await PlayerPreferences.isMusicEnabled(), isFalse);

      await PlayerPreferences.setSfxEnabled(false);
      expect(await PlayerPreferences.isSfxEnabled(), isFalse);
    });
  });
}
