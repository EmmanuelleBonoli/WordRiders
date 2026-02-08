
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/gameplay/services/ad_service.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/game/overlays/ad_loading_dialog.dart';
import 'package:word_train/features/ui/widgets/game/overlays/no_lives_overlay.dart';
import 'package:word_train/features/ui/widgets/game/game_modal_button.dart';
import 'package:word_train/features/ui/widgets/common/coin_indicator.dart';
import 'package:word_train/features/ui/widgets/animations/resource_transfer_animation.dart';

class GameEndOverlay extends StatefulWidget {
  final bool isWon;
  final bool isCampaign;
  final VoidCallback onQuit;
  final VoidCallback? onRestart; 
  final VoidCallback? onContinue;

  const GameEndOverlay({
    super.key,
    required this.isWon,
    required this.isCampaign,
    required this.onQuit,
    this.onRestart,
    this.onContinue,
  });

  @override
  State<GameEndOverlay> createState() => _GameEndOverlayState();
}

class _GameEndOverlayState extends State<GameEndOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  
  // Clés pour l'animation
  final GlobalKey<CoinIndicatorState> _coinIndicatorKey = GlobalKey<CoinIndicatorState>();
  final GlobalKey _watchAdButtonKey = GlobalKey();
  final GlobalKey _continueButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
  }

  @override
  void dispose() {
     _animController.dispose();
    super.dispose();
  }

  Future<void> _handleReplay(BuildContext context) async {
    if (widget.isCampaign) {
      final currentLives = await PlayerPreferences.getLives();
      if (currentLives <= 0) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => NoLivesOverlay(
            onLivesReplenished: () {
               // Si l'utilisateur a rechargé, on relance le jeu
               widget.onRestart?.call();
            },
          ),
        );
        return;
      }
    }
    widget.onRestart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isWon = widget.isWon;
    final mainColor = isWon ? AppTheme.green : AppTheme.red;
    final title = isWon ? context.tr('game.victory') : context.tr('game.defeat');
    final message = isWon 
        ? (widget.isCampaign ? context.tr('game.level_finished') : context.tr('game.training_won'))
        : context.tr('game.fox_won');

    final imageAsset = isWon 
        ? 'assets/images/characters/rabbit_head.jpg' 
        : 'assets/images/characters/fox_head.jpg';

    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
          
          // Coin Indicator (Top Left) - Visible seulement pour les victoires en campagne
          if (widget.isCampaign && isWon)
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: CoinIndicator(key: _coinIndicatorKey),
              ),
            ),

          // Contenu principal du modal
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 320,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: mainColor.withValues(alpha: 0.2), width: 3),
                        ),
                        child: ClipOval(
                          child: Image.asset(imageAsset, fit: BoxFit.cover),
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.w900,
                          color: mainColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16, color: AppTheme.textDark, height: 1.3),
                        textAlign: TextAlign.center,
                      ),

                      // Affichage récompense pièces si victoire campagne
                      if (widget.isCampaign && isWon) ...[
                         const SizedBox(height: 12),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                           decoration: BoxDecoration(
                             color: Colors.amber.withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(20),
                             border: Border.all(color: Colors.amber),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                              Text("+30", style: const TextStyle(color: AppTheme.brown, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Image.asset('assets/images/indicators/coin.png', width: 24),
                             ],
                           ),
                         ),
                      ],

                      const SizedBox(height: 24),

                      _buildButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (widget.isCampaign && widget.isWon) {
      return Row(
        children: [
          // Bouton Publicité (Bonus)
          Expanded(
            child: GameModalButton(
              key: _watchAdButtonKey,
              onPressed: () async {
                if (!context.mounted) return;
                
                // 1. Afficher la publicité
                await AdLoadingDialog.show(context, isRewarded: true);
                
                // 2. Ajouter des pièces
                await PlayerPreferences.addCoins(60); // 60 coins bonus (double)
                
                // 3. Mettre à jour l'indicateur
                _coinIndicatorKey.currentState?.reload();
                
                // 4. Animer et naviguer
                if (context.mounted) {
                  ResourceTransferAnimation.start(
                    context,
                    startKey: _watchAdButtonKey,
                    endKey: _coinIndicatorKey,
                    assetPath: 'assets/images/indicators/coin.png',
                    onComplete: () async {
                       final currentStage = await PlayerPreferences.getCurrentStage();
                       await AdService.markAdShownForStage(currentStage);
                       if (widget.onContinue != null) widget.onContinue!();
                    },
                  );
                }
              },
              color: Colors.deepPurple,
              icon: Icons.ondemand_video_rounded,
              label: "",
              labelWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "x2 ",
                    style: TextStyle(
                      fontFamily: 'Round',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(color: Colors.black26, offset: Offset(0, 1.5), blurRadius: 2)
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/indicators/coin.png',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 16),

          // Bouton Continuer (Classique)
          Expanded(
            child: GameModalButton(
              key: _continueButtonKey,
              onPressed: () async {
                 // 1. Ajouter des pièces
                await PlayerPreferences.addCoins(30);
                _coinIndicatorKey.currentState?.reload();

                // 2. Animer, puis vérifier la pub et naviguer
                if (context.mounted) {
                  ResourceTransferAnimation.start(
                    context,
                    startKey: _continueButtonKey,
                    endKey: _coinIndicatorKey,
                    assetPath: 'assets/images/indicators/coin.png',
                    onComplete: () async {
                        final currentStage = await PlayerPreferences.getCurrentStage();
                        final shouldShowAd = await AdService.shouldShowAdForStage(currentStage);
                        
                        if (shouldShowAd && context.mounted) {
                          await AdLoadingDialog.show(context);
                          await AdService.markAdShownForStage(currentStage);
                        }
                        widget.onContinue?.call();
                    },
                  );
                }
              }, 
              color: AppTheme.green,
              icon: Icons.arrow_forward_rounded,
              label: context.tr('game.continue'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: GameModalButton(
            onPressed: widget.onQuit,
            color: AppTheme.red,
            icon: Icons.close_rounded,
            label: context.tr('game.quit'),
          ),
        ),
        const SizedBox(width: 16),
          Expanded(
          child: GameModalButton(
            onPressed: () => _handleReplay(context),
            color: AppTheme.green,
            icon: Icons.refresh_rounded,
            label: context.tr('game.replay'),
          ),
        ),
      ],
    );
  }
} 

