
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

  /// Charge le dictionnaire, filtre les mots de 8 lettres et en retourne un qui n'a pas été utilisé.
  Future<String> getNextCampaignWord(String locale) async {
    // 1. Charger le dictionnaire si pas chargé ou si on veut juste piocher
    // Ici on refait le chargement local pour la pioche spécifique (filtrage length=8)
    // C'est dupliqué mais ça évite de stocker en mémoire RAM tous les mots de 8 lettres séparément en permanence
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
        throw Exception("Aucun mot de longueur $wordLength trouvé dans le dictionnaire.");
      }

      // 2. Récupérer les mots déjà joués
      final List<String> usedWords = await PlayerProgress.getUsedWords();
      debugPrint("WordService: ${usedWords.length} mots déjà utilisés et exclus.");

      // 3. Trouver les candidats inutilisés
      final List<String> candidates = allWords.where((w) => !usedWords.contains(w)).toList();

      if (candidates.isEmpty) {
        // Si le joueur a tout épuisé, on reprend dans la liste complète
        return allWords[Random().nextInt(allWords.length)];
      }

      // 4. Piocher au hasard
      final String picked = candidates[Random().nextInt(candidates.length)];
      
      return picked;

    } catch (e) {
      debugPrint("Erreur chargement dictionnaire pour pick: $e");
      // Mot de secours
      return "AVENTURE"; 
    }
  } 
  /// Génère une liste de [count] mots uniques pour une nouvelle campagne
  Future<List<String>> generateCampaignWords(String locale, int count) async {
    String path = 'assets/words/$locale.txt';
    
    try {
      final String content = await rootBundle.loadString(path);
      // Découpage et filtre (8 lettres uniquement pour l'instant)
      final List<String> allWords = content
          .split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == wordLength)
          .toList();

      if (allWords.length < count) {
        debugPrint("Attention: pas assez de mots dans le dico ($allWords.length) pour la demande ($count).");
        return allWords;
      }

      // Mélanger et prendre les N premiers
      allWords.shuffle();
      return allWords.take(count).toList();

    } catch (e) {
      debugPrint("Erreur génération campagne: $e");
      // Fallback
      return List.generate(count, (index) => "AVENTURE"); 
    }
  }
}

Set<String> _parseWords(String raw) {
  return raw
      .split('\n')
      .map((e) => e.trim().toUpperCase())
      .where((e) => e.isNotEmpty)
      .toSet();
}
