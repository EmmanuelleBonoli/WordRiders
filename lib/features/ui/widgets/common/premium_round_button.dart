import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';
import 'shiny_corner_effect.dart';

import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class PremiumRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool showHole;
  final List<Color>? rimGradient;
  final List<Color>? faceGradient;
  final List<Color>? iconGradient;
  final Color? borderColor;

  const PremiumRoundButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 60.0,
    this.showHole = false,
    this.rimGradient,
    this.faceGradient,
    this.iconGradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.45;
    
    final effectiveBorder = borderColor ?? AppTheme.coinBorderDark;
    final effectiveRim = rimGradient ?? [AppTheme.coinRimTop, AppTheme.coinRimBottom];
    final effectiveFace = faceGradient ?? [AppTheme.coinFaceTop, AppTheme.coinFaceBottom];
    final effectiveIcon = iconGradient ?? effectiveRim;

    return BouncingScaleButton(
      onTap: onTap ?? () {},
      scaleTarget: 0.95,
      showShadow: false,
      child: Container(
        width: size,
        height: size,
        // 1. Ombre globale
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 4,
            )
          ],
        ),
        child: Container(
          // 2. Bordure Extérieure (Dark)
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveBorder,
          ),
          child: Container(
            // 3. Cerclage Doré (Golden Rim Gradient)
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: effectiveRim,
              ),
            ),
            padding: const EdgeInsets.all(4.0),
            child: Container(
              // 4. Bordure Intérieure (Dark)
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: effectiveBorder,
              ),
              child: Container(
                // 5. Face Intérieure (Fond Bois Gradient)
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: effectiveFace,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 6. Icon (Solid Color)
                    Icon(
                      icon,
                      size: iconSize,
                      color: effectiveIcon.first,
                      shadows: [
                        Shadow(color: effectiveIcon.first, offset: const Offset(0.5, 0), blurRadius: 0),
                        Shadow(color: effectiveIcon.first, offset: const Offset(-0.5, 0), blurRadius: 0),
                        Shadow(color: effectiveIcon.first, offset: const Offset(0, 0.5), blurRadius: 0),
                        Shadow(color: effectiveIcon.first, offset: const Offset(0, -0.5), blurRadius: 0),
                      ],
                    ),
                    
                    // Highlight Effect
                    Positioned.fill(
                      child: ShinyCornerEffect(
                        isCircle: true,
                        color: Colors.white.withValues(alpha: 0.6),
                        strokeWidth: 2.0,
                      ),
                    ),

                    // 7. Hole (Optional)
                    if (showHole)
                      Container(
                        width: size * 0.13,
                        height: size * 0.13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: effectiveFace.first,
                          border: Border.all(color: effectiveFace.last, width: 1.5),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
