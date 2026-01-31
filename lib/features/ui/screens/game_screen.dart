import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:word_train/features/gameplay/controllers/game_controller.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/widgets/game/game_header.dart';
import 'package:word_train/features/ui/widgets/game/game_input_area.dart';
import 'package:word_train/features/ui/widgets/game/game_race_area.dart';
import 'package:word_train/features/ui/widgets/game/overlays/game_end_overlay.dart';
import 'package:word_train/features/ui/widgets/game/overlays/game_pause_overlay.dart';
import 'package:word_train/features/ui/widgets/game/overlays/game_pause_dialog.dart';
import 'package:word_train/features/ui/widgets/game/overlays/no_lives_overlay.dart';

import 'package:word_train/features/ui/widgets/game/overlays/training_config_overlay.dart';

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
      controller.resumeGame();
    }

    void onBackTap() {
      controller.pauseGame();
      
      final String subtitle = controller.isCampaign 
          ? tr('game.quit_confirm_subtitle_campaign')
          : tr('game.quit_confirm_subtitle_training');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => GamePauseDialog(
          title: tr('game.pause_title'),
          message: subtitle,
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
                 // Plus de vie ! Afficher la modale pour recharger
                 if (context.mounted) {
                   await showDialog(
                     context: context,
                     barrierDismissible: true,
                     builder: (dialogCtx) => NoLivesOverlay(
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
          
          // 2. Contenu Principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GameHeader(
                  onBack: onBackTap,
                  onSettings: onSettingsTap,
                  showFox: controller.isCampaign,
                  rabbitProgress: controller.rabbitProgress,
                  foxProgress: controller.foxProgress,
                ),

                // Zone centrale (Animation Course)
                Expanded(
                  child: GameRaceArea(isCampaign: controller.isCampaign),
                ),

                // Zone de saisie
                GameInputArea(
                  feedbackMessage: controller.feedbackMessage,
                  currentInput: controller.currentInput,
                  shuffledLetters: controller.shuffledLetters,
                  onBackspace: controller.onBackspace,
                  onValidate: onValidate,
                  onShuffle: controller.onShuffle,
                  onLetterTap: controller.onLetterTap,
                ),
              ],
            ),
          ),

          // 3. Overlays (Pause & Fin)
          if (controller.isPaused)
            const GamePauseOverlay(),

          if (controller.status == GameStatus.won || controller.status == GameStatus.lost)
            GameEndOverlay(
              isWon: controller.status == GameStatus.won,
              isCampaign: controller.isCampaign,
              onQuit: () => Navigator.pop(context),
              onRestart: () => controller.restartGame(),
              onContinue: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}
