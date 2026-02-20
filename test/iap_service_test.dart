import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_riders/features/gameplay/services/iap_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Nettoyage de la mémoire avant chaque test
    SharedPreferences.setMockInitialValues({});
  });

  group('IapService Tests - Core Logic', () {
    test('isNoAdsPurchased retourne false par défaut', () async {
      final isPurchased = await IapService.isNoAdsPurchased();
      expect(isPurchased, isFalse, reason: 'L\'utilisateur ne devrait pas avoir le mode No Ads par défaut');
    });

    test('isNoAdsPurchased retourne true après un achat simulé via SharedPreferences', () async {
      // Pour les tests sans plugin natif branché, on peut s'assurer au minimum 
      // que le flag SharedPreferences (qui est la vraie vérité locale) fonctionne.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('no_ads_purchased', true);

      final isPurchasedCheck = await IapService.isNoAdsPurchased();
      expect(isPurchasedCheck, isTrue, reason: 'Si le flag dans prefs est true, le service doit remonter l\'achat');
    });

    test('Initialisation passe automatiquement en mode inactif sans plantage (Environnement de test Desktop)', () async {
      // La dépendance InAppPurchase sur l'ordinateur qui exécute les tests 
      // devrait tomber dans les sécurités "Platforme non supportée" (isMobile = false),
      // ou en mode simulation.
      
      // On s'assure juste que le code s'exécute de bout en bout sans crasher.
      await IapService.initialize();
      expect(IapService.products, isNotEmpty); // En test (kDebugMode), le Fallback Simulation charge des faux produits
    });
  });
}
