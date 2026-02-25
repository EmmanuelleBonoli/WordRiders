import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:word_riders/features/gameplay/controllers/game_controller.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/gameplay/services/word_service.dart';
import 'package:word_riders/features/ui/widgets/game/game_header.dart';
import 'package:word_riders/features/ui/widgets/game/game_header_background.dart';
import 'package:word_riders/features/ui/widgets/game/input/game_input_area.dart';
import 'package:word_riders/features/ui/widgets/game/game_race_area.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/game_end_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/game_pause_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/no_lives_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/game_timeline.dart';
import 'package:word_riders/features/ui/widgets/game/game_bonus_panel.dart';

import 'package:word_riders/features/ui/widgets/game/overlays/training_config_overlay.dart';

class GameScreen extends StatelessWidget {
  final bool isCampaign;

  const GameScreen({super.key, this.isCampaign = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey(context.locale.languageCode),
      create: (ctx) => GameController(
        isCampaign: isCampaign,
        locale: context.locale.languageCode,
        wordService: ctx.read<WordService>(),
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

    if (controller.status == GameStatus.waitingForConfig) {
      return TrainingConfigOverlay(
        onSelectLength: (length) => controller.startTraining(length),
        onBack: () => context.pop(), 
      );
    }

    void onValidate() {
      controller.validate();
    }

    void onSettingsTap() async {
      controller.pauseGame();
      await context.push('/settings');
      
      // Si on change de langue dans les réglages, cet écran est détruit (nouvelle ValueKey).
      // On s'assure donc que le contexte est toujours monté avant d'utiliser le controller.
      if (!context.mounted) return;
      
      controller.resumeGame();
    }

    void onBackTap() {
      controller.pauseGame();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => GamePauseOverlay(
          title: context.tr('game.pause_title'),
          isCampaign: controller.isCampaign,
          onResume: () {
            Navigator.pop(ctx); 
            controller.resumeGame();
          },
          onRestart: () async {
            Navigator.pop(ctx);
            
            // En campagne, recommencer en cours de jeu coûte une vie (abandon)
            if (controller.isCampaign) {
               final success = await controller.consumeLifeForRestart();
               if (!success) {
                 // Si plus de vie : afficher la modale pour recharger
                 if (context.mounted) {
                   await showDialog(
                     context: context,
                     barrierDismissible: true,
                     builder: (dialogCtx) => NoLivesOverlay(
                       fromGame: true,
                       onLivesReplenished: () {
                         // Après recharge, on peut restart
                         controller.restartGame();
                       },
                     ),
                   );
                   
                   // Si on arrive ici, la modale s'est fermée
                   // On vérifie si le joueur a rechargé ses vies
                   if (context.mounted) {
                     final currentLives = await PlayerPreferences.getLives();
                     if (currentLives <= 0) {
                       // Toujours pas de vie, retour à l'écran de campagne
                       if (context.mounted) {
                         context.go('/campaign');
                       }
                     }
                   }
                 }
                 return; // Ne pas restart si pas de vie
               }
            }
            
            controller.restartGame();
          },
          onQuit: () async {
            Navigator.pop(ctx); 
            await controller.quitGame(); // Déclenche potentiellement perte de vie
            if (context.mounted) {
               Navigator.pop(context); 
            }
          },
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fond
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/game_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. Header Background Decoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 55,
            child: const GameHeaderBackground(),
          ),

          // 3. Contenu Principal
          SafeArea(
            child: Column(
              children: [
                // En-tête
                GameHeader(
                  onBack: onBackTap,
                  onSettings: onSettingsTap,
                  isCampaign: controller.isCampaign,
                  currentStage: controller.currentStage
                ),

                // Timeline
                GameTimeline(
                  rabbitProgress: controller.rabbitProgress,
                  foxProgress: controller.foxProgress,
                  showFox: controller.isCampaign,
                ),

                // Zone de Course
                // On utilise un Expanded pour qu'il prenne tout l'espace restant en hauteur
                Expanded(
                  child: GameRaceArea(isCampaign: controller.isCampaign),
                ),

                // Zone de saisie
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GameInputArea(
                    feedbackMessage: controller.feedbackMessage,
                    currentInput: controller.currentInput,
                    shuffledLetters: controller.shuffledLetters,
                    onBackspace: controller.onBackspace,
                    onValidate: onValidate,
                    onShuffle: controller.onShuffle,
                    onLetterTap: controller.onLetterTap,
                  ),
                ),

                // Panneau des bonus (si en campagne)
                if (controller.isCampaign)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GameBonusPanel(controller: controller),
                  ),
              ],
            ),
          ),

          // 4. Overlays (Pause & Fin)
          if (controller.status == GameStatus.won || controller.status == GameStatus.lost)
            GameEndOverlay(
              currentLevel: controller.currentStage,
              isWon: controller.status == GameStatus.won,
              isCampaign: controller.isCampaign,
              onQuit: () async {
                  if (controller.isCampaign && controller.status == GameStatus.lost) {
                    await controller.concedeGame();
                  }
                  if (context.mounted) Navigator.pop(context);
              },
              onRestart: () => controller.restartGame(),
              onContinue: () => Navigator.pop(context),
              onRevive: () => controller.revive(),
            ),
        ],
      ),
    );
  }
}
