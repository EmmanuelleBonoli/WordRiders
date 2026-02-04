import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_train/features/gameplay/services/ad_service.dart';

class PlayerPreferences {
  static const _keyStage = 'currentStage';
  static const _keyMusic = 'musicEnabled';
  static const _keySfx = 'sfxEnabled';

  static Future<int> getCurrentStage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStage) ?? 1;
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

  // Récupère le mot pour le stage donné
  static Future<String?> getWordForStage(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    final words = prefs.getStringList(_keyCampaignWords);
    if (words == null || words.isEmpty) return null;
    
    final index = stage - 1;
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    return null; // Fin de campagne ou erreur
  }

  // Sauvegarde ou met à jour le mot pour un stage donné
  static Future<void> setWordForStage(int stage, String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> words = prefs.getStringList(_keyCampaignWords) ?? [];
    
    final index = stage - 1;
    
    // Si la liste est trop petite, on la remplit avec des placeholders
    while (words.length <= index) {
      words.add(""); 
    }
    
    words[index] = word;
    await prefs.setStringList(_keyCampaignWords, words);
  }

  static const _keyLives = 'playerLives';
  static const _keyLastRegenTime = 'lastLifeRegenTime';
  static const int _maxLives = 5;
  static const int _regenMinutes = 20;

  // Récupère le nombre de vies, en calculant la régénération
  static Future<int> getLives() async {
    final prefs = await SharedPreferences.getInstance();
    int currentLives = prefs.getInt(_keyLives) ?? _maxLives;
    
    // Si on est déjà au max, pas de calcul
    if (currentLives >= _maxLives) {
      return _maxLives;
    }

    // Calcul de la régénération
    final lastRegenStr = prefs.getString(_keyLastRegenTime);
    if (lastRegenStr == null) {
      // Cas bizarre: pas au max mais pas de date ? On remet au max par sécurité
      await setLives(_maxLives);
      return _maxLives;
    }

    final lastRegenTime = DateTime.parse(lastRegenStr);
    final now = DateTime.now();
    final difference = now.difference(lastRegenTime);
    
    final livesToRestore = difference.inMinutes ~/ _regenMinutes;
    
    if (livesToRestore > 0) {
      currentLives += livesToRestore;
      if (currentLives > _maxLives) currentLives = _maxLives;
      
      await setLives(currentLives);
      
      // Si on n'est toujours pas au max, on avance le timer d'autant de périodes de 20min complétées
      // pour garder le "crédit" des minutes restantes
      if (currentLives < _maxLives) {
        final newLastRegenTime = lastRegenTime.add(Duration(minutes: livesToRestore * _regenMinutes));
        await prefs.setString(_keyLastRegenTime, newLastRegenTime.toIso8601String());
      } else {
        // Si on est au max, on nettoie le timer
        await prefs.remove(_keyLastRegenTime);
      }
    }

    return currentLives;
  }

  static Future<void> setLives(int lives) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLives, lives);
  }

  // Consomme une vie. Retourne true si succès, false si pas assez de vies.
  static Future<bool> loseLife() async {
    int current = await getLives();
    if (current > 0) {
      current--;
      await setLives(current);
      
      // Si on vient de passer en dessous du max (donc on était à 5, on passe à 4),
      // on doit initialiser le timer pour la prochaine regen
      if (current == _maxLives - 1) {
         final prefs = await SharedPreferences.getInstance();
         // On vérifie s'il y a déjà un timer (par précaution) mais en théorie non
         if (!prefs.containsKey(_keyLastRegenTime)) {
            await prefs.setString(_keyLastRegenTime, DateTime.now().toIso8601String());
         }
      }
      return true;
    }
    return false;
  }

  // Temps restant avant la prochaine vie (null si full)
  static Future<Duration?> getTimeToNextLife() async {
    final prefs = await SharedPreferences.getInstance();
    int currentLives = await getLives(); // Déclenche le calcul de regen si besoin
    
    if (currentLives >= _maxLives) return null;
    
    final lastRegenStr = prefs.getString(_keyLastRegenTime);
    if (lastRegenStr == null) return null;
    
    final lastRegenTime = DateTime.parse(lastRegenStr);
    final now = DateTime.now();
    final diff = now.difference(lastRegenTime);
    
    final timeLeft = Duration(minutes: _regenMinutes) - diff;
    return timeLeft.isNegative ? Duration.zero : timeLeft;
  }

  static const _keyCoins = 'playerCoins';

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCoins) ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCoins();
    await prefs.setInt(_keyCoins, current + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCoins();
    if (current >= amount) {
      await prefs.setInt(_keyCoins, current - amount);
      return true;
    }
    return false;
  }

  static Future<void> resetCampaign() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStage, 1);
    await prefs.remove(_keyUsedWords);
    await prefs.remove(_keyActiveWord);
    await prefs.remove(_keyCampaignWords);
    await AdService.resetAdTracking();
    // On ne reset pas les vies ni les pièces, c'est indépendant
  }
}
