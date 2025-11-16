import 'package:shared_preferences/shared_preferences.dart';

class PlayerProgress {
  static const _keyStage = 'currentStage';
  static const _keyMusic = 'musicEnabled';
  static const _keySfx = 'sfxEnabled';

  static Future<int> getCurrentStage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStage) ?? 1; // 1 = stage de départ
    //todo: remettre à 1 quand l'animation de progression sera prête
  }

  static Future<void> setCurrentStage(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStage, stage);
  }

  static Future<bool> isMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMusic) ?? true;
  }

  static Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusic, enabled);
  }

  static Future<bool> isSfxEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySfx) ?? true;
  }

  static Future<void> setSfxEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySfx, enabled);
  }
}
