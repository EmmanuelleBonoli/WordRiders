import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:word_train/router.dart';
import 'package:word_train/utils/dictionary.dart';

void main() async {
  /// nécessaire pour charger les assets
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  /// charger le dictionnaire
  final dictionary = Dictionary();
  await dictionary.load();

  /// forcer le mode paysage
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  /// lancer le jeu
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: Provider<Dictionary>.value(
        value: dictionary,
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
      theme: ThemeData.dark(),

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      routerConfig: router,
    );
  }
}
