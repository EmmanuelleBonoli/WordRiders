import 'package:shared_preferences/shared_preferences.dart';

class PlayerProgress {
  static const _keyStage = 'currentStage';
  static const _keyMusic = 'musicEnabled';
  static const _keySfx = 'sfxEnabled';

  static Future<int> getCurrentStage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStage) ?? 1; // 1 = stage de départ
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
  static const _keyUsedWords = 'usedWords';

  static Future<List<String>> getUsedWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyUsedWords) ?? [];
  }

  static Future<void> addUsedWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final used = await getUsedWords();
    if (!used.contains(word)) {
      used.add(word);
      await prefs.setStringList(_keyUsedWords, used);
    }
  }

  static const _keyActiveWord = 'activeWord';
  
  static Future<String?> getActiveWord() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveWord);
  }

  static Future<void> setActiveWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveWord, word);
  }

  static Future<void> clearActiveWord() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveWord);
  }

  static const _keyCampaignWords = 'campaignWords';

  static Future<bool> isCampaignInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    // Campagne initialisée si on a une liste de mots
    return prefs.containsKey(_keyCampaignWords);
  }

  static Future<void> setCampaignWords(List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCampaignWords, words);
  }

  /// Récupère le mot pour le stage donné (1-based index)
  static Future<String?> getWordForStage(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    final words = prefs.getStringList(_keyCampaignWords);
    if (words == null || words.isEmpty) return null;
    
    // stage 1 -> index 0
    final index = stage - 1;
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    return null; // Fin de campagne ou erreur
  }

  static Future<void> resetCampaign() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStage, 1);
    await prefs.remove(_keyUsedWords);
    await prefs.remove(_keyActiveWord);
    await prefs.remove(_keyCampaignWords);
  }
}
