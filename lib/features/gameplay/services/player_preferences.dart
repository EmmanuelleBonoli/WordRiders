import 'package:shared_preferences/shared_preferences.dart';

class PlayerProgress {
  static const _keyStage = 'currentStage';

  static Future<int> getCurrentStage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStage) ?? 20; // 1 = stage de départ
    //todo: remettre à 1 quand l'animation de progression sera prête
  }

  static Future<void> setCurrentStage(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStage, stage);
  }
}
