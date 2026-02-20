import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_riders/features/gameplay/services/word_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WordService Tests', () {
    test('loadDictionary charge bien le dictionnaire en mémoire', () async {
      final service = WordService();
      
      // En test unitaire simple, Flutter arrive à charger l'asset si défini dans pubspec !
      await service.loadDictionary('fr');
      
      // On teste qu'un mot connu du dico français est valide
      final isValid = service.isValid('BONJOUR');
      expect(isValid, isTrue, reason: 'Le mot BONJOUR devrait être validé');
      
      // On teste qu'un mot complètement faux est refusé
      final isInvalid = service.isValid('ZZXZXZX');
      expect(isInvalid, isFalse);
    });

    test('getNextCampaignWord renvoie bien un mot de la taille demandée', () async {
      final service = WordService();
      
      // Stage 1 sans modificateur devrait donner 6 lettres
      final word6 = await service.getNextCampaignWord('fr', stage: 1, forceLength: 6);
      expect(word6.length, equals(6));

      // Stage 100 sans modificateur devrait donner 7 lettres
      final word7 = await service.getNextCampaignWord('fr', stage: 100, forceLength: 7);
      expect(word7.length, equals(7));
    });
  });
}
