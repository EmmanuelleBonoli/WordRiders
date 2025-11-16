import 'package:flutter/services.dart' show rootBundle;

class Dictionary {
  late Set<String> _words;
  final String languageCode = 'fr';
  // contexte.locale.languageCode; // todo: à décommenter quand le multi-langue sera prêt

  // Dictionary({required this.languageCode}); // todo: à décommenter quand le multi-langue sera prêt
  Dictionary();

  /// Charge le fichier de mots correspondant à la langue
  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/words/$languageCode.txt');
    _words = raw
        .split('\n')
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    print('Loaded ${_words.length} words for language $languageCode');
  }

  /// Vérifie si un mot est valide
  bool isValid(String word) {
    return _words.contains(word);
  }
}
