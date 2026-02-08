import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';
import 'package:word_train/features/ui/widgets/common/premium_menu_button.dart';

class TrainingConfigOverlay extends StatelessWidget {
  final Function(int) onSelectLength;
  final VoidCallback onBack;

  const TrainingConfigOverlay({
    super.key,
    required this.onSelectLength,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/game_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 340,
                maxHeight: MediaQuery.of(context).size.height - 48,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // 1. The MAIN PANEL
                  Container(
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
                        padding: const EdgeInsets.fromLTRB(24, 50, 24, 32),
                        decoration: BoxDecoration(
                          color: AppTheme.levelSignFace,
                          borderRadius: BorderRadius.circular(26.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                             context.tr('training.choose_difficulty'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.coinBorderDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            _buildPremiumOption(context.tr('training.easy'), 6),
                            const SizedBox(height: 12),
                            _buildPremiumOption(context.tr('training.medium'), 7),
                            const SizedBox(height: 12),
                            _buildPremiumOption(context.tr('training.hard'), 8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. The HEADER (Title)
                  Positioned(
                    top: -24,
                    child: _buildHeaderRibbon(context),
                  ),

                  // 3. Close Button
                  Positioned(
                    top: -16,
                    right: -14,
                    child: BouncingScaleButton(
                      onTap: onBack,
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
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
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
            context.tr('menu.training').toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.coinBorderDark,
              fontWeight: FontWeight.w900,
              fontFamily: 'Round',
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOption(String text, int length) {
    return SizedBox(
      height: 70,
      child: Center(
        child: PremiumMenuButton(
          text: text,
          forceUpperCase: false,
          onTap: () => onSelectLength(length),
          width: 220,
          faceGradient: [
            AppTheme.levelSignFace,
            AppTheme.levelSignFace,
          ],
          rimGradient: const [
             AppTheme.coinRimTop,
             AppTheme.coinRimBottom,
          ],
        ),
      ),
    );
  }
}
