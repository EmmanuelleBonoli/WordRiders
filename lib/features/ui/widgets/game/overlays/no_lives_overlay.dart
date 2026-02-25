import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';
import 'package:word_riders/features/ui/widgets/common/button/premium_round_button.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/ad_loading_overlay.dart';

import 'package:go_router/go_router.dart';
import 'package:word_riders/features/ui/widgets/common/life_indicator.dart';
import 'package:word_riders/features/ui/widgets/common/coin_indicator.dart';

class NoLivesOverlay extends StatefulWidget {
  final VoidCallback onLivesReplenished;
  final bool fromGame;

  const NoLivesOverlay({
    super.key,
    required this.onLivesReplenished,
    this.fromGame = false,
  });

  @override
  State<NoLivesOverlay> createState() => _NoLivesOverlayState();
}

class _NoLivesOverlayState extends State<NoLivesOverlay> with SingleTickerProviderStateMixin {
  // int _coins = 0;
  bool _isManualReplenish = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final GlobalKey<CoinIndicatorState> _coinIndicatorKey = GlobalKey<CoinIndicatorState>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _buyLives() async {
    _isManualReplenish = true;
    final success = await PlayerPreferences.spendCoins(500);
    if (success) {
      _coinIndicatorKey.currentState?.reload(); // Mise à jour coin display
      final current = await PlayerPreferences.getLives();
      await PlayerPreferences.setLives(current + 1); // +1 vie
      widget.onLivesReplenished();
      if (mounted) Navigator.of(context).pop();
    } else {
      _isManualReplenish = false;
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

  Future<void> _watchAd() async {
    _isManualReplenish = true;
    // Afficher le loader de pub
    await AdLoadingOverlay.show(context, isRewarded: true);
    
    if (mounted) {
      final current = await PlayerPreferences.getLives();
      await PlayerPreferences.setLives(current + 1);
      widget.onLivesReplenished();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _checkLives() async {
    if (!mounted) return;
    try {
      final int lives = await PlayerPreferences.getLives();
      final bool isManual = _isManualReplenish;
      
      if (lives > 0 && !isManual) {
        // Fermer l'overlay si les vies sont récupérées naturellement
        if (mounted) {
           Navigator.of(context).pop();
           if (widget.fromGame) {
             context.go('/campaign');
           } else {
              widget.onLivesReplenished();
           }
        }
      }
    } catch (e, stack) {
      debugPrint("Error checking lives: $e\n$stack");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // LIFE INDICATOR (TOP LEFT)
        Positioned(
          top: 30,
          left: 30,
          child: SafeArea(
            child: LifeIndicator(
              onLivesChanged: _checkLives,
            ),
          ),
        ),

        // COIN INDICATOR (TOP RIGHT)
        Positioned(
          top: 30,
          right: 30,
          child: SafeArea(
            child: CoinIndicator(key: _coinIndicatorKey),
          ),
        ),

        Material(
          type: MaterialType.transparency,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // MAIN BOARD
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.coinBorderDark,
                          borderRadius: BorderRadius.zero,
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
                            borderRadius: BorderRadius.zero,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                            decoration: const BoxDecoration(
                              color: AppTheme.levelSignFace,
                              borderRadius: BorderRadius.zero,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Heart Container
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
                                    decoration: BoxDecoration(
                                      color: AppTheme.coinFaceTop.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.coinBorderDark.withValues(alpha: 0.1),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Broken Heart Icon
                                        Image.asset(
                                          'assets/images/indicators/heart_broken.png',
                                          width: 80,
                                          height: 80,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          context.tr('campaign.noLives').toUpperCase(),
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: AppTheme.coinBorderDark,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Round',
                                            fontSize: 24,
                                            letterSpacing: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
  
                                  const SizedBox(height: 32),
  
                                  // Horizontal Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                       // Buy 1 Life (500 Coins)
                                       Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          PremiumRoundButton(
                                            icon: Icons.favorite_rounded,
                                            size: 88,
                                            onTap: _buyLives,
                                            faceGradient: const [AppTheme.coinFaceTop, AppTheme.coinFaceBottom],
                                            iconGradient: const [AppTheme.red, AppTheme.red],
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
                                      
                                      // Watch Ad
                                       Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                      PremiumRoundButton(
                                        icon: Icons.videocam_rounded,
                                        size: 88,
                                        onTap: _watchAd,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                    // CLOSE BUTTON
                    Positioned(
                      top: 14,
                      right: 16,
                      child: BouncingScaleButton(
                        onTap: () {
                          Navigator.of(context).pop();
                          if (widget.fromGame) {
                             context.go('/campaign');
                          }
                        },
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
        ),
      ],
    );
  }
}
