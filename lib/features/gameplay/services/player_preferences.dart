import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_riders/features/gameplay/models/player_profile.dart';
import 'package:word_riders/secrets.dart';

class PlayerPreferences {
  static const _keyProfile = 'wordRiders_playerProfile';
  
  // Instance singleton du Profil pour éviter les rechargements constants
  static PlayerProfile? _cachedProfile;

  // --- Aides à la Sécurité ---
  static String _computeSignature(String jsonString) {
    // Vérification d'intégrité simple : Base64(json + salt)
    // Pas robuste, mais suffisant pour empêcher l'édition de texte simple.
    final bytes = utf8.encode(jsonString + Secrets.profileSalt);
    return base64.encode(bytes);
  }

  // --- Core Access ---
  static Future<PlayerProfile> getProfile() async {
    if (_cachedProfile != null) return _cachedProfile!;

    final prefs = await SharedPreferences.getInstance();
    final storedString = prefs.getString(_keyProfile);
    
    if (storedString != null) {
      try {
        // Essayer de décoder comme objet sécurisé enveloppé
        final Map<String, dynamic> wrapper = jsonDecode(storedString);
        String data = wrapper['data'];
        final String signature = wrapper['signature'];
        
        // Tentative de décodage Base64 (Obfuscation)
        // Si ça échoue, c'est que c'est encore en texte clair (format précédent)
        try {
           final decodedBytes = base64.decode(data);
           data = utf8.decode(decodedBytes);
        } catch (_) {
           // C'est du texte clair, on continue avec 'data' tel quel
        }

        // Vérifier l'intégrité
        final computedSig = _computeSignature(data);
        if (computedSig != signature) {
           debugPrint("ALERTE SÉCURITÉ : Fichier de sauvegarde corrompu ou modifié. Réinitialisation.");
           _cachedProfile = PlayerProfile.initial();
        } else {
           _cachedProfile = PlayerProfile.fromJson(jsonDecode(data));
        }

      } catch (e) {
        // Solution de repli : peut-être un ancien format (avant la sécurité) ?
        // Essayer de charger comme JSON direct
         try {
            _cachedProfile = PlayerProfile.fromJson(jsonDecode(storedString));
            // Si réussi, on devrait le sauvegarder de manière sécurisée immédiatement la prochaine fois
         } catch (_) {
            _cachedProfile = PlayerProfile.initial();
         }
      }
    } else {
      _cachedProfile = PlayerProfile.initial();
    }
    return _cachedProfile!;
  }

  static Future<void> saveProfile(PlayerProfile profile) async {
    _cachedProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    
    final jsonString = jsonEncode(profile.toJson());
    // 1. Signature du contenu original (JSON)
    final signature = _computeSignature(jsonString);
    
    // 2. Obfuscation du contenu (Base64)
    final obfuscatedData = base64.encode(utf8.encode(jsonString));
    
    final wrapper = {
      'data': obfuscatedData,
      'signature': signature,
    };
    
    await prefs.setString(_keyProfile, jsonEncode(wrapper));
  }

  static Future<int> getCurrentStage() async => (await getProfile()).stage;
  
  static Future<void> setCurrentStage(int stage) async {
    final profile = await getProfile();
    profile.stage = stage;
    await saveProfile(profile);
  }

  static Future<int> getCoins() async => (await getProfile()).coins;

  static Future<void> addCoins(int amount) async {
    final profile = await getProfile();
    profile.coins += amount;
    await saveProfile(profile);
  }

  static Future<void> setCoins(int amount) async {
    final profile = await getProfile();
    profile.coins = amount;
    await saveProfile(profile);
  }
  
  static Future<bool> spendCoins(int amount) async {
    final profile = await getProfile();
    if (profile.coins >= amount) {
      profile.coins -= amount;
      await saveProfile(profile);
      return true;
    }
    return false;
  }

  static const int _maxLives = 5;
  static const int _regenMinutes = 20;

  static Future<int> getLives() async {
    final profile = await getProfile();
    

    if (profile.lives < _maxLives) {
      final now = DateTime.now();
      final diff = now.difference(profile.lastLifeRegen);
      final livesRestored = diff.inMinutes ~/ _regenMinutes;
      
      if (livesRestored > 0) {
        profile.lives += livesRestored;
        if (profile.lives >= _maxLives) {
          profile.lives = _maxLives;
        } else {
           // Avancer le timer par intervalles consommés
           profile.lastLifeRegen = profile.lastLifeRegen.add(Duration(minutes: livesRestored * _regenMinutes));
        }
        await saveProfile(profile);
      }
    }
    
    return profile.lives; 
  }

  static Future<bool> loseLife() async {
    final profile = await getProfile();
    
    // Vérifier si les vies illimitées sont actives
    if (await isUnlimitedLivesActive()) {
      return true; // Aucune vie perdue, mais l'action est autorisée
    }

    // S'assurer du comptage précis d'abord
    await getLives(); 
    
    if (profile.lives > 0) {
      // Si c'était au max, démarrer le timer maintenant
      if (profile.lives == _maxLives) {
        profile.lastLifeRegen = DateTime.now();
      }
      
      profile.lives--;
      await saveProfile(profile);
      return true;
    }
    return false;
  }

  static Future<void> setLives(int lives) async {
      final profile = await getProfile();
      profile.lives = lives;
      if (lives < _maxLives) {
          profile.lastLifeRegen = DateTime.now();
      }
      await saveProfile(profile);
  }

  // --- Vies Illimitées ---
  
  static Future<DateTime?> getUnlimitedLivesExpiration() async {
    return (await getProfile()).unlimitedLivesUntil;
  }

  static Future<void> setUnlimitedLivesExpiration(DateTime? expiration) async {
    final profile = await getProfile();
    profile.unlimitedLivesUntil = expiration;
    await saveProfile(profile);
  }

  static Future<void> addUnlimitedLivesTime(Duration duration) async {
    final profile = await getProfile();
    final now = DateTime.now();
    
    if (profile.unlimitedLivesUntil != null && profile.unlimitedLivesUntil!.isAfter(now)) {
      // Étendre le temps existant
      profile.unlimitedLivesUntil = profile.unlimitedLivesUntil!.add(duration);
    } else {
      // Démarrer un nouveau temps
      profile.unlimitedLivesUntil = now.add(duration);
    }
    
    // Remplir aussi les vies au maximum lors de l'obtention d'un accès illimité
    profile.lives = _maxLives;
    
    await saveProfile(profile);
  }

  static Future<bool> isUnlimitedLivesActive() async {
    final expiration = await getUnlimitedLivesExpiration();
    if (expiration == null) return false;
    return expiration.isAfter(DateTime.now());
  }

  static Future<Duration?> getTimeToNextLife() async {
    final profile = await getProfile();
    if (profile.lives >= _maxLives) return null;
    
    // Calcule relatif au dernier Regen
    // Puisque getLives() met à jour lastRegen quand on consomme du temps, 
    // on calcule juste la diff de MAINTENANT à lastRegen + 20min
    final nextRegenTime = profile.lastLifeRegen.add(const Duration(minutes: _regenMinutes));
    final now = DateTime.now();
    final diff = nextRegenTime.difference(now);
    
    return diff.isNegative ? Duration.zero : diff;
  }

  static Future<List<String>> getUsedWords() async => (await getProfile()).usedWords;
  
  static Future<void> addUsedWord(String word) async {
    final profile = await getProfile();
    if (!profile.usedWords.contains(word)) {
      profile.usedWords.add(word);
      await saveProfile(profile);
    }
  }

  static Future<String?> getActiveWord() async => (await getProfile()).activeWord;
  
  static Future<void> setActiveWord(String word) async {
    final profile = await getProfile();
    profile.activeWord = word;
    await saveProfile(profile);
  }

  static Future<void> clearActiveWord() async {
    final profile = await getProfile();
    profile.activeWord = null;
    await saveProfile(profile);
  }

  static Future<bool> isCampaignInitialized() async { 
      return (await getProfile()).campaignWords.isNotEmpty; 
  }
  
  static Future<void> setCampaignWords(List<String> words) async {
      final profile = await getProfile();
      profile.campaignWords = words;
      await saveProfile(profile);
  }

  static Future<String?> getWordForStage(int stage, String currentLocale) async {
      final profile = await getProfile();
      if (profile.campaignLocale != currentLocale) {
          return null;
      }
      final index = stage - 1;
      if (index >= 0 && index < profile.campaignWords.length) {
          return profile.campaignWords[index];
      }
      return null;
  }

  static Future<void> setWordForStage(int stage, String word, String currentLocale) async {
      final profile = await getProfile();
      if (profile.campaignLocale != currentLocale) {
          profile.campaignWords.clear();
          profile.campaignLocale = currentLocale;
      }
      final index = stage - 1;
      while (profile.campaignWords.length <= index) {
          profile.campaignWords.add("");
      }
      profile.campaignWords[index] = word;
      await saveProfile(profile);
  }

  static Future<bool> isMusicEnabled() async => (await getProfile()).musicEnabled;

  static Future<void> setMusicEnabled(bool enabled) async {
      final profile = await getProfile();
      profile.musicEnabled = enabled;
      await saveProfile(profile);
  }

  static Future<bool> isSfxEnabled() async => (await getProfile()).sfxEnabled;

  static Future<void> setSfxEnabled(bool enabled) async {
      final profile = await getProfile();
      profile.sfxEnabled = enabled;
      await saveProfile(profile);
  }

  static Future<void> resetCampaign() async {
    final profile = await getProfile();
    profile.stage = 1;
    profile.usedWords.clear();
    profile.activeWord = null;
    profile.campaignWords.clear();
    profile.campaignLocale = null;
    await saveProfile(profile);
  }
  static Future<int> getLastAdStage() async => (await getProfile()).lastAdStage;
 
  static Future<void> setLastAdStage(int stage) async {
      final profile = await getProfile();
      profile.lastAdStage = stage;
      await saveProfile(profile);
  }
  static Future<int> getUnclaimedGoalsCount() async {
    final profile = await getProfile();
    int count = 0;
    
    for (final goal in profile.dailyGoals) {
      if (goal.isCompleted && !goal.isClaimed) count++;
    }
    
    for (final goal in profile.careerGoals) {
      if (goal.isCompleted && !goal.isClaimed) count++;
    }
    
    return count;
  }
  static Future<String?> getLocale() async => (await getProfile()).locale;

  static Future<void> setLocale(String locale) async {
      final profile = await getProfile();
      profile.locale = locale;
      await saveProfile(profile);
  }

  // --- Bonus ---
  static Future<int> getBonusExtraLetterCount() async => (await getProfile()).bonusExtraLetterCount;
  static Future<void> useBonusExtraLetter() async {
    final profile = await getProfile();
    if (profile.bonusExtraLetterCount > 0) {
      profile.bonusExtraLetterCount--;
      await saveProfile(profile);
    }
  }

  static Future<int> getBonusDoubleDistanceCount() async => (await getProfile()).bonusDoubleDistanceCount;
  static Future<void> useBonusDoubleDistance() async {
    final profile = await getProfile();
    if (profile.bonusDoubleDistanceCount > 0) {
      profile.bonusDoubleDistanceCount--;
      await saveProfile(profile);
    }
  }

  static Future<int> getBonusFreezeRivalCount() async => (await getProfile()).bonusFreezeRivalCount;
  static Future<void> useBonusFreezeRival() async {
    final profile = await getProfile();
    if (profile.bonusFreezeRivalCount > 0) {
      profile.bonusFreezeRivalCount--;
      await saveProfile(profile);
    }
  }

  static Future<void> addBonusItems({
    int extraLetter = 0,
    int doubleDistance = 0,
    int freezeRival = 0,
  }) async {
    final profile = await getProfile();
    profile.bonusExtraLetterCount += extraLetter;
    profile.bonusDoubleDistanceCount += doubleDistance;
    profile.bonusFreezeRivalCount += freezeRival;
    await saveProfile(profile);
  }
}
