import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import '../common/shiny_corner_effect.dart';

class StageCircle extends StatelessWidget {
  final int number;
  final bool unlocked;
  final bool isCurrent;

  const StageCircle({
    required this.number,
    required this.unlocked,
    this.isCurrent = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final isBoss = number % 10 == 0;
    final isHard = !isBoss && (number % 5 == 0);

    // Stage actif
    const uFace = AppTheme.goldButtonFace;      
    const uSide = AppTheme.goldButtonShadow;      
    const uHigh = AppTheme.goldButtonHighlight;      
    
    // Stage complété
    const cFace = AppTheme.neutralBeige;
    const cSide = AppTheme.neutralBeigeShadow; 
    const cHigh = AppTheme.neutralBeigeLight;

    // Stage verrouillé
    final lFace = Colors.grey.shade400;
    final lSide = Colors.grey.shade600;
    final lHigh = Colors.grey.shade300;

    Color faceColor;
    Color sideColor;
    Color highColor;

    if (!unlocked) {
      faceColor = lFace;
      sideColor = lSide;
      highColor = lHigh;
    } else if (isCurrent) {
      faceColor = uFace;
      sideColor = uSide;
      highColor = uHigh;
    } else {
      // Stage complété mais pas actuel
      faceColor = cFace;
      sideColor = cSide;
      highColor = cHigh;
    }
    
    // Contraste pour le texte
    final textColor = unlocked ? AppTheme.brown : Colors.white.withValues(alpha: 0.6);

    double size = 60;
    if (isBoss) {
      size = 72;
    } else if (isHard) {
      size = 66;
    }

    const double depth = 6.0;

    return Container(
      width: size,
      height: size + depth,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Côté / Ombre (Fond)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: depth,
            child: Container(
              decoration: BoxDecoration(
                color: sideColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
            ),
          ),

          // 2. Face (Dessus)
          Positioned(
            left: 0,
            right: 0,
            bottom: depth,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: faceColor,
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    highColor,
                    faceColor,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Positioned.fill(
                     child: ShinyCornerEffect(
                       isCircle: true,
                       color: Colors.white.withValues(alpha: unlocked ? 0.6 : 0.4),
                       strokeWidth: 7.0,
                       blurSigma: 3.0,
                       cornerLength: 20.0, 
                       padding: 5.0, 
                     ),
                   ),

                   // Numéro (Uniquement si débloqué)
                   if (unlocked)
                     Padding(
                       padding: EdgeInsets.only(bottom: (isBoss || isHard) ? 10 : 0),
                       child: Text(
                        '$number',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Round',
                          fontSize: isBoss ? 26 : 22,
                          shadows: [
                            Shadow(color: Colors.white.withValues(alpha: 0.5), offset: const Offset(0,1), blurRadius: 0)
                          ],
                        ),
                      ),
                     ),
                  
                  // Etoiles (Indicateurs Boss/Hard)
                  if (isHard)
                    Positioned(
                      bottom: 10,
                      child: Icon(Icons.star_rounded, size: 16, color: AppTheme.brown.withValues(alpha: 0.6)),
                    ),

                  if (isBoss)
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: AppTheme.brown.withValues(alpha: 0.6)),
                          const SizedBox(width: 2),
                          Icon(Icons.star_rounded, size: 14, color: AppTheme.brown.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                    
                  // Cadenas si verrouillé
                  if (!unlocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      width: size,
                      height: size,
                      alignment: Alignment.center,
                      child: Icon(Icons.lock, color: Colors.white.withValues(alpha: 0.4), size: 24),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
