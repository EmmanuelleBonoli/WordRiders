import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_train/features/gameplay/services/iap_service.dart';

// Service pour gérer les publicités et le statut "No Ads"
class AdService {
  static const String _keyLastAdStage = 'last_ad_stage';
  static const int _adFrequency = 3; // Pub tous les 3 stages

  // Vérifie si le joueur a acheté "No Ads" via IAP
  static Future<bool> hasNoAds() async {
    return await IapService.isNoAdsPurchased();
  }

  // Vérifie si une pub doit être affichée pour ce stage
  static Future<bool> shouldShowAdForStage(int currentStage) async {
    if (await hasNoAds()) return false;
    if (currentStage <= 1) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastAdStage = prefs.getInt(_keyLastAdStage) ?? 0;

    return (currentStage - lastAdStage) >= _adFrequency;
  }

  // Marque qu'une pub a été vue pour ce stage
  static Future<void> markAdShownForStage(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastAdStage, stage);
  }

  // Simule le visionnage d'une publicité (2 secondes)
  static Future<void> simulateAdWatch() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  // Réinitialise le tracker de pubs (pour reset campagne)
  static Future<void> resetAdTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastAdStage, 0);
  }
}
