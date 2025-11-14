import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  late Locale _locale;

  Locale get locale => _locale;

  LanguageProvider(BuildContext context) {
    /// Détection automatique de la langue du système
    _locale = View.of(context).platformDispatcher.locale;
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  String get languageCode => _locale.languageCode;
}
