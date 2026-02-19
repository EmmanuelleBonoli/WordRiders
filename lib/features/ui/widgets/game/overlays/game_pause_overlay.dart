import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';
import 'package:word_riders/features/ui/widgets/common/button/premium_round_button.dart';
import 'package:word_riders/features/ui/widgets/common/life_indicator.dart';

class GamePauseOverlay extends StatefulWidget {
  final String title;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  final bool isCampaign;

  const GamePauseOverlay({
    super.key,
    required this.title,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
    this.isCampaign = false,
  });

  @override
  State<GamePauseOverlay> createState() => _GamePauseOverlayState();
}

class _GamePauseOverlayState extends State<GamePauseOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

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

  @override
  Widget build(BuildContext context) {
    return Stack(
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

        // LIFE INDICATOR (CAMPAIGN ONLY)
        if (widget.isCampaign)
          const Positioned(
            top: 30,
            left: 30,
            child: SafeArea(
              child: LifeIndicator(),
            ),
          ),

        Material(
          type: MaterialType.transparency,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 320,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // MAIN BOARD
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
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                            decoration: BoxDecoration(
                              color: AppTheme.levelSignFace,
                              borderRadius: BorderRadius.circular(26.5),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pause Title & Icon Container
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
                                        Text(
                                          widget.title.toUpperCase(),
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: AppTheme.coinBorderDark,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Round',
                                            fontSize: 28,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Large Pause Icon
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [AppTheme.coinFaceTop, AppTheme.coinFaceBottom],
                                            ),
                                            border: Border.all(
                                              color: AppTheme.coinBorderDark,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              )
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.pause_rounded,
                                              size: 48,
                                              color: AppTheme.coinBorderDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
  
                                  const SizedBox(height: 24),
  
                                  // Horizontal Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                       // Quitter (Red)
                                       Stack(
                                         clipBehavior: Clip.none,
                                         alignment: Alignment.center,
                                         children: [
                                           PremiumRoundButton(
                                             icon: Icons.close_rounded,
                                             size: 88,
                                             onTap: widget.onQuit,
                                             faceGradient: const [AppTheme.btnRedTop, AppTheme.btnRedBottom],
                                             iconGradient: const [AppTheme.white, AppTheme.white],
                                           ),
                                           if (widget.isCampaign)
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
                                                       "-1",
                                                       style: TextStyle(
                                                         color: AppTheme.tileFace,
                                                         fontWeight: FontWeight.w900,
                                                         fontSize: 16,
                                                         fontFamily: 'Round',
                                                       ),
                                                     ),
                                                     const SizedBox(width: 4),
                                                     Image.asset(
                                                       'assets/images/indicators/heart.png',
                                                       width: 18,
                                                       height: 18,
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                             ),
                                         ],
                                       ),
                                       
                                       // Rejouer (Green)
                                           Stack(
                                         clipBehavior: Clip.none,
                                         alignment: Alignment.center,
                                         children: [
                                       PremiumRoundButton(
                                         icon: Icons.refresh_rounded,
                                         size: 88,
                                         onTap: widget.onRestart,
                                         faceGradient: const [AppTheme.btnGreenTop, AppTheme.btnGreenBottom],
                                         iconGradient: const [AppTheme.white, AppTheme.white],
                                       ),
                                         if (widget.isCampaign)
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
                                                       "-1",
                                                       style: TextStyle(
                                                         color: AppTheme.tileFace,
                                                         fontWeight: FontWeight.w900,
                                                         fontSize: 16,
                                                         fontFamily: 'Round',
                                                       ),
                                                     ),
                                                     const SizedBox(width: 4),
                                                     Image.asset(
                                                       'assets/images/indicators/heart.png',
                                                       width: 18,
                                                       height: 18,
                                                     ),
                                                   ],
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
                        onTap: widget.onResume,
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
