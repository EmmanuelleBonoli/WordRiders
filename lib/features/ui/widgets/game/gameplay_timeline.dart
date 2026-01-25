import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class GameplayTimeline extends StatelessWidget {
  final double rabbitProgress;
  final double foxProgress;
  final bool showFox;

  const GameplayTimeline({
    super.key, 
    required this.rabbitProgress,
    required this.foxProgress,
    this.showFox = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          
          // Sécurité absolue : si width est invalide ou trop petite, on render un vide pour éviter le crash
          if (!width.isFinite || width <= 40) {
             return const SizedBox();
          }

          // Calcule la position horizontale des joueurs en fonction de la progression
          // On garde une marge pour l'icône (40px)
          final maxPos = (width - 40).clamp(0.0, double.infinity);
          
          double rabbitPos = (maxPos * rabbitProgress);
          if (rabbitPos.isNaN || rabbitPos.isInfinite) rabbitPos = 0.0;
          rabbitPos = rabbitPos.clamp(0.0, maxPos);

          double foxPos = (maxPos * foxProgress);
          if (foxPos.isNaN || foxPos.isInfinite) foxPos = 0.0;
          foxPos = foxPos.clamp(0.0, maxPos);
          
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // La barre de progression (route)
              Container(
                height: 48,
                alignment: Alignment.center,
                child: Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.brown, width: 2),
                  ),
                ),
              ),
              
              Positioned(
                right: 0,
                top: 0, bottom: 0, 
                child: Center(
                    child: Image.asset(
                      'assets/images/characters/finish_flag2.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                ), 
              ),

              // RENARD (Visible seulement si showFox est true)
              if (showFox)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear,
                  left: foxPos, 
                  top: 0, bottom: 0, 
                  child: Center(
                      child: Image.asset(
                        'assets/images/characters/fox_head2.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                  ),
                ),
              
              // LAPIN
               AnimatedPositioned(
                duration: const Duration(milliseconds: 500), // Glissement pour le lapin
                curve: Curves.easeOutCubic,
                left: rabbitPos, 
                top: 0, bottom: 0, 
                child: Center(
                    child: Image.asset(
                      'assets/images/characters/rabbit_head2.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
