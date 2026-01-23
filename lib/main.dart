import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:word_train/router.dart';
import 'package:word_train/features/gameplay/services/word_service.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:flutter/services.dart';

void main() async {
  /// Nécessaire pour l'initialisation des bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  /// Initialisation du service de mots et chargement du dictionnaire par défaut
  final wordService = WordService();
  await wordService.loadDictionary('fr'); 

  /// Forcer l'orientation en mode paysage
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  /// Lancement de l'application
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: Provider<WordService>.value(
        value: wordService,
        child: WordTrainApp(),
      ),
    ),
  );
}

class WordTrainApp extends StatelessWidget {
  const WordTrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Word Train',
      theme: AppTheme.lightTheme,

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      routerConfig: router,
    );
  }
}
