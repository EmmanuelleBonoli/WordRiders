import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/gameplay/services/ad_service.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/ad_loading_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/no_lives_overlay.dart';
import 'package:word_riders/features/ui/widgets/common/coin_indicator.dart';
import 'package:word_riders/features/ui/widgets/common/life_indicator.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';
import 'package:word_riders/features/ui/widgets/common/button/premium_round_button.dart';
import 'package:word_riders/features/ui/animations/resource_transfer_animation.dart';

class GameEndOverlay extends StatefulWidget {
  final bool isWon;
  final bool isCampaign;
  final VoidCallback onQuit;
  final VoidCallback? onRestart; 
  final VoidCallback? onContinue;
  final VoidCallback? onRevive;

  const GameEndOverlay({
    super.key,
    required this.isWon,
    required this.isCampaign,
    required this.onQuit,
    this.onRestart,
    this.onContinue,
    this.onRevive,
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
  
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    if (widget.isCampaign) {
      final lvl = await PlayerPreferences.getCurrentStage();
       // Si on a gagné, le niveau a DEJA été incrémenté dans le controller avant l'affichage de l'overlay
       // Donc pour afficher "Niveau X terminé", il faut prendre niveau actuel - 1
      if (mounted) {
        setState(() {
          _currentLevel = widget.isWon ? (lvl - 1) : lvl;
        });
      }
    }
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
            fromGame: true,
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

  Future<void> _handleBuyRevive() async {
    final success = await PlayerPreferences.spendCoins(500);
    if (success) {
      widget.onRevive?.call();
    } else {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('campaign.notEnoughCoins')),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _handleWatchAdRevive() async {
    if (!mounted) return;
    await AdLoadingOverlay.show(context, isRewarded: true);
    if (mounted) {
      widget.onRevive?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si c'est gagné, couleur verte, sinon rouge (pour certains elements)
    final isWon = widget.isWon;

    // Assets
    final imageAsset = isWon 
        ? 'assets/images/rewards/victory_cup.png' 
        : 'assets/images/rewards/defeat_cross.png';

    // Titres
    final title = isWon ?  context.tr('game.victory') :  context.tr('game.defeat');

    return Positioned.fill(
      child: Stack(
        children: [
          // Blur Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          
          // Indicators
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: LifeIndicator(),
            ),
          ),
          
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: CoinIndicator(key: _coinIndicatorKey),
            ),
          ),

          // Main Content
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 340,
                  maxHeight: MediaQuery.of(context).size.height - 100,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // BOARD
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.coinBorderDark,
                          borderRadius: BorderRadius.circular(32),
                           boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30.5)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
                            ),
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                            decoration: BoxDecoration(
                              color: AppTheme.levelSignFace,
                              borderRadius: BorderRadius.circular(26.5),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // HEADER SPACER
                                  const SizedBox(height: 24),
  
                                  // IMAGE
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Image.asset(imageAsset, fit: BoxFit.contain),
                                  ),
  
                                  const SizedBox(height: 16),
                                  
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 32, 
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.brown,
                                      fontFamily: 'Round', 
                                      letterSpacing: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 8),
  
                                   // REWARD INFO (Only if won and campaign)
                                  if (widget.isCampaign && isWon) ...[
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                       decoration: BoxDecoration(
                                         color: AppTheme.rewardBadgeBg.withValues(alpha: 0.2),
                                         borderRadius: BorderRadius.circular(20),
                                         border: Border.all(color: AppTheme.rewardBadgeBg),
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           const Text("+30", style: TextStyle(color: AppTheme.brown, fontWeight: FontWeight.bold, fontSize: 20)),
                                           const SizedBox(width: 8),
                                           Image.asset('assets/images/indicators/coin.png', width: 28),
                                         ],
                                       ),
                                     ),
                                     const SizedBox(height: 24),
                                  ] else ...[
                                     const SizedBox(height: 24),
                                  ],
  
                                  // BUTTONS
                                  isWon ? _buildVictoryButtons(context) : _buildDefeatButtons(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // HEADER RIBBON (If Campaign)
                    if (widget.isCampaign)
                      Positioned(
                        top: 6,
                        child: _buildHeaderRibbon(context),
                      ),

                    // CLOSE BUTTON (If Defeat)
                    if (!isWon)
                      Positioned(
                        top: 14,
                        right: 16,
                        child: BouncingScaleButton(
                          onTap: widget.onQuit,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.brown,
                              border: Border.all(color: AppTheme.coinRimBottom, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppTheme.tileFace,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRibbon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: AppTheme.coinBorderDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, 
            offset: Offset(0, 4), 
            blurRadius: 4
          )
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14.5)),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
          ),
        ),
        padding: const EdgeInsets.all(3.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.levelSignFace, 
            borderRadius: BorderRadius.circular(11.5),
          ),
          child: Text(
            "${context.tr('game.level')} $_currentLevel",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.coinBorderDark,
              fontWeight: FontWeight.w900,
              fontFamily: 'Round',
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryButtons(BuildContext context) {
    if (widget.isCampaign) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton Publicité (Bonus)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
               PremiumRoundButton(
                 key: _watchAdButtonKey,
                 icon: Icons.ondemand_video_rounded,
                 size: 88,
                 onTap: () async {
                    if (!context.mounted) return;
                    await AdLoadingOverlay.show(context, isRewarded: true);
                    
                    await PlayerPreferences.addCoins(60); 
                    _coinIndicatorKey.currentState?.reload();
                    
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
                 faceGradient: const [AppTheme.btnPurpleTop, AppTheme.btnPurpleBottom],
                 iconGradient: const [AppTheme.white, AppTheme.white],
               ),
               Positioned(
                 bottom: -18,
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(
                     color: AppTheme.coinBorderDark,
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: AppTheme.coinRimBottom, width: 2),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.3),
                         blurRadius: 4,
                         offset: const Offset(0, 2),
                       )
                     ],
                   ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Text(
                         "x2",
                         style: TextStyle(
                           color: AppTheme.tileFace,
                           fontWeight: FontWeight.w900,
                           fontSize: 16,
                           fontFamily: 'Round',
                         ),
                       ),
                       const SizedBox(width: 4),
                       Image.asset(
                         'assets/images/indicators/coin.png',
                         width: 18,
                         height: 18,
                       ),
                     ],
                   ),
                 ),
               ),
            ],
          ),
          
          // Bouton Continuer (Classique)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
               PremiumRoundButton(
                 key: _continueButtonKey,
                 icon: Icons.arrow_forward_rounded,
                 size: 88,
                 onTap: () async {
                    await PlayerPreferences.addCoins(30);
                    _coinIndicatorKey.currentState?.reload();

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
                              await AdLoadingOverlay.show(context);
                              await AdService.markAdShownForStage(currentStage);
                            }
                            widget.onContinue?.call();
                        },
                      );
                    }
                 },
                 faceGradient: const [AppTheme.btnGreenTop, AppTheme.btnGreenBottom],
                 iconGradient: const [AppTheme.white, AppTheme.white],
               ),
               Positioned(
                 bottom: -18,
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(
                     color: AppTheme.coinBorderDark,
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: AppTheme.coinRimBottom, width: 2),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.3),
                         blurRadius: 4,
                         offset: const Offset(0, 2),
                       )
                     ],
                   ),
                   child: Text(
                     context.tr('game.continue').toUpperCase(),
                     style: const TextStyle(
                       color: AppTheme.tileFace,
                       fontWeight: FontWeight.w900,
                       fontSize: 14,
                       fontFamily: 'Round',
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ],
      );
    } else {
        // Training Mode Victory - Replay or Quit
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    PremiumRoundButton(
                        size: 88,
                        icon: Icons.close_rounded,
                        onTap: widget.onQuit,
                        faceGradient: const [AppTheme.btnRedTop, AppTheme.btnRedBottom],
                        iconGradient: const [AppTheme.white, AppTheme.white],
                    ),
                    Positioned(
                      bottom: -18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.coinBorderDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.coinRimBottom, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          context.tr('game.quit').toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.tileFace,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            fontFamily: 'Round',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    PremiumRoundButton(
                        size: 88,
                        icon: Icons.refresh_rounded,
                        onTap: () => _handleReplay(context),
                        faceGradient: const [AppTheme.btnGreenTop, AppTheme.btnGreenBottom],
                        iconGradient: const [AppTheme.white, AppTheme.white],
                    ),
                    Positioned(
                      bottom: -18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.coinBorderDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.coinRimBottom, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          context.tr('game.replay').toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.tileFace,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            fontFamily: 'Round',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
        );
    }
  }

  Widget _buildDefeatButtons(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
            // Buy Revive (500 Coins)
            Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
                PremiumRoundButton(
                icon: Icons.refresh_rounded, 
                size: 80,
                onTap: _handleBuyRevive,
                faceGradient: const [AppTheme.coinFaceTop, AppTheme.coinFaceBottom],
                iconGradient: const [AppTheme.brown, AppTheme.brown], 
                ),
                Positioned(
                bottom: -12,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                    color: AppTheme.coinBorderDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.coinRimBottom, width: 2),
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        )
                    ],
                    ),
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const Text(
                        "500",
                        style: TextStyle(
                            color: AppTheme.tileFace,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            fontFamily: 'Round',
                        ),
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                        'assets/images/indicators/coin.png',
                        width: 16,
                        height: 16,
                        ),
                    ],
                    ),
                ),
                ),
            ],
            ),
            
            // Watch Ad Revive
            Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
            PremiumRoundButton(
                icon: Icons.videocam_rounded,
                size: 80,
                onTap: _handleWatchAdRevive,
                faceGradient: const [AppTheme.btnBlueTop, AppTheme.btnBlueBottom],
                iconGradient: const [AppTheme.white, AppTheme.white],
            ),
            Positioned(
                bottom: -12,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                    color: AppTheme.coinBorderDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.coinRimBottom, width: 2),
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        )
                    ],
                    ),
                    child: const Text(
                        "FREE",
                        style: TextStyle(
                            color: AppTheme.tileFace,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            fontFamily: 'Round',
                        ),
                        ),
                ),
                ),
            ],
            ),
        ],
    );
  }
}
