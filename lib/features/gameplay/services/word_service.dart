
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'player_preferences.dart';

class WordService {
  static const int wordLength = 8;
  late Set<String> _words;
  String? _loadedLocale;
  
  WordService();

  /// Charge le dictionnaire complet pour validation
  Future<void> loadDictionary(String locale) async {
    if (_loadedLocale == locale) return; // Déjà chargé
    
    try {
      final String content = await rootBundle.loadString('assets/words/$locale.txt');
      _words = await compute(_parseWords, content);
      _loadedLocale = locale;
      debugPrint("WordService: Dictionnaire chargé pour $locale (${_words.length} mots)");
    } catch (e) {
      debugPrint("WordService: Erreur chargement dictionnaire ($locale): $e");
      _words = {};
    }
  }

  /// Vérifie si un mot est valide
  bool isValid(String word) {
    if (_words.isEmpty) {
       debugPrint("WordService: Attention, validation demandée avec dictionnaire vide !");
       return false;
    }
    return _words.contains(word.toUpperCase());
  }

  /// Charge le dictionnaire, filtre les mots selon le niveau et en retourne un qui n'a pas été utilisé.
  /// Stage 1-50 : 6 lettres
  /// Stage 51-500 : 7 lettres
  /// Stage 500+ : 8 lettres
  Future<String> getNextCampaignWord(String locale, {int stage = 1}) async {
    int wordLength = 6;
    if (stage > 500) {
      wordLength = 8;
    } else if (stage > 50) {
      wordLength = 7;
    }

    String path = 'assets/words/$locale.txt';
    
    try {
      final String content = await rootBundle.loadString(path);
      // Découpage et filtre
      final List<String> allWords = content
          .split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == wordLength)
          .toList();

      if (allWords.isEmpty) {
        // Fallback si pas de mots de cette taille (ex: dico incomplet)
        debugPrint("Attention: aucun mot de $wordLength lettres. On cherche 8 lettres par défaut.");
         final List<String> fallbackWords = content
          .split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 8)
          .toList();
          if (fallbackWords.isNotEmpty) return fallbackWords[Random().nextInt(fallbackWords.length)];
          throw Exception("Dictionnaire vide ou incompatible.");
      }

      // Exclure les mots déjà utilisés
    List<String> used = await PlayerPreferences.getUsedWords();
    if (stage > 1) {
       // Si on est à un stage avancé, on s'assure de ne pas ressortir un mot facile
       // (Logique simplifiée ici)
    }
      // 3. Trouver les candidats inutilisés
      final List<String> candidates = allWords.where((w) => !used.contains(w)).toList();

      if (candidates.isEmpty) {
        // Si le joueur a tout épuisé pour ce niveau de difficulté, on repioche au hasard
        return allWords[Random().nextInt(allWords.length)];
      }

      // 4. Piocher au hasard
      final String picked = candidates[Random().nextInt(candidates.length)];
      
      return picked;

    } catch (e) {
      debugPrint("Erreur chargement dictionnaire pour pick: $e");
      // Mot de secours adapté à la difficulté
      if (wordLength == 6) return "NATURE";
      if (wordLength == 7) return "BONJOUR";
      return "AVENTURE"; 
    }
  } 

  /// Génère une liste de mots pour une nouvelle campagne (utilisé pour peupler en masse si besoin)
  Future<List<String>> generateCampaignWords(String locale, int count) async {
    // Note: Cette méthode semble peu utilisée maintenant qu'on pioche au fur et à mesure, 
    // mais on la garde compatible (défaut 6 lettres pour le début)
    return [await getNextCampaignWord(locale, stage: 1)];
  }
}

Set<String> _parseWords(String raw) {
  return raw
      .split('\n')
      .map((e) => e.trim().toUpperCase())
      .where((e) => e.isNotEmpty)
      .toSet();
}
