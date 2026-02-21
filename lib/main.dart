import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:word_riders/router.dart';
import 'package:word_riders/features/gameplay/services/word_service.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/gameplay/services/iap_service.dart';
import 'package:word_riders/features/gameplay/services/goal_service.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

void main() async {
  // Nécessaire pour l'initialisation des bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await IapService.initialize();
  await GoalService().init();

  // Initialisation du service de mots
  final wordService = WordService(); 

  // Charger la langue du joueur
  final savedLocaleCode = await PlayerPreferences.getLocale();
  Locale? startLocale;
  if (savedLocaleCode != null) {
    startLocale = Locale(savedLocaleCode);
  } else {
    // Pour un nouveau joueur, on détecte la langue du système
    final deviceLanguage = ui.PlatformDispatcher.instance.locale.languageCode;
    const supportedLocales = ['en', 'fr', 'es', 'it', 'de'];
    
    if (supportedLocales.contains(deviceLanguage)) {
      startLocale = Locale(deviceLanguage);
    } else {
      startLocale = const Locale('en');
    }
    
    // On l'enregistre dans les préférences pour figer le choix initial
    await PlayerPreferences.setLocale(startLocale.languageCode);
  }

  // Forcer l'orientation en mode portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Lancement de l'application
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
        Locale('it'),
        Locale('de')
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
      saveLocale: false, // Utilise PlayerPreferences à la place
      child: Provider<WordService>.value(
        value: wordService,
        child: const WordRidersApp(),
      ),
    ),
  );
}

class WordRidersApp extends StatelessWidget {
  const WordRidersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Word Riders',
      theme: AppTheme.lightTheme,

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      routerConfig: router,
    );
  }
}
