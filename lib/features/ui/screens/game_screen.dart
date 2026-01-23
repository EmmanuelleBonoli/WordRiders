import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';


import 'package:word_train/features/ui/widgets/game/game_buttons.dart';
import 'package:word_train/features/ui/widgets/game/gameplay_timeline.dart';
import 'package:word_train/features/ui/widgets/navigation/app_back_button.dart';
import 'package:word_train/features/ui/widgets/navigation/settings_button.dart';

import 'package:provider/provider.dart';
import 'package:word_train/features/gameplay/controllers/game_controller.dart';

class GameScreen extends StatelessWidget {
  final bool isCampaign;

  const GameScreen({super.key, this.isCampaign = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(
        isCampaign: isCampaign,
        locale: context.locale.languageCode,
      ),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  const _GameScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
  
    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    void onValidate() {
      if (controller.validate()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("VICTOIRE !"),
            content: Text("Vous avez trouvé : ${controller.targetWord}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Fermer le dialogue
                  Navigator.pop(context); // Retour au menu/campagne
                },
                child: const Text("Continuer"),
              )
            ],
          ),
        );
      } else {
        debugPrint("Mauvais mot !");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Essayez encore !")));
        controller.clearInput();
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/game_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                       const AppBackButton(),
                       const SizedBox(width: 12),
                       
                       Expanded(
                         child: GameplayTimeline(
                           progress: controller.progress, 
                         ),
                       ),
                       
                       const SizedBox(width: 12),
                       const SettingsButton(),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.brown, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.brown.withValues(alpha: 0.1),
                    ),
                    child: Center(
                       child: Text(
                         "VUE JEU FLAME\nCible : ${controller.targetWord}",
                         textAlign: TextAlign.center,
                         style: const TextStyle(color: AppTheme.darkBrown, fontWeight: FontWeight.bold),
                       ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                           ActionButton(
                             icon: Icons.backspace_rounded, 
                             color: AppTheme.red, 
                             onTap: controller.onBackspace,
                           ),
                           
                           const SizedBox(width: 12),

                           // Affichage de l'Input (Étendu)
                           Expanded(
                             child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.brown, width: 2),
                                ),
                                child: Text(
                                  controller.currentInput,
                                  style: const TextStyle(
                                    fontSize: 28, 
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 2,
                                    color: AppTheme.textDark
                                  ),
                                ),
                             ),
                           ),

                           const SizedBox(width: 12),

                           // Bouton VALIDATION
                           ActionButton(
                             icon: Icons.check_circle_rounded, 
                             color: AppTheme.green, 
                             onTap: onValidate,
                           ),

                        ],
                      ),
                      
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          ...controller.shuffledLetters.map((l) {
                          return LetterButton(
                            letter: l, 
                            onTap: () => controller.onLetterTap(l),
                          );
                        }),
                          const SizedBox(width: 24),

                           ActionButton(
                             icon: Icons.shuffle_rounded, 
                             color: AppTheme.orange, 
                             onTap: controller.onShuffle,
                           ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


