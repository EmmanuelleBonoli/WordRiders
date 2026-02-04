import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';
import 'shiny_corner_effect.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class PremiumMenuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final List<Color>? rimGradient;
  final List<Color>? faceGradient;

  const PremiumMenuButton({
    super.key,
    required this.text,
    this.onTap,
    this.width = 250.0,
    this.height = 64.0,
    this.rimGradient,
    this.faceGradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRim = rimGradient ?? [AppTheme.coinRimTop, AppTheme.coinRimBottom];
    final effectiveFace = faceGradient ?? [AppTheme.coinFaceTop,AppTheme.coinFaceBottom];
    final effectiveBorder = AppTheme.coinBorderDark;
    
    final borderRadius = BorderRadius.circular(height / 2);
    
    final innerRadius = (height / 2) - 7.0;
    final shineBorderRadius = BorderRadius.circular(innerRadius);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: BouncingScaleButton(
        onTap: onTap ?? () {},
        scaleTarget: 0.95,
        showShadow: false,
        child: Container(
          width: width,
          height: height,
          // 1. Ombre globale
          decoration: BoxDecoration(
            borderRadius: borderRadius,
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
              borderRadius: borderRadius,
              color: effectiveBorder,
            ),
            child: Container(
              // 3. Cerclage Doré (Golden Rim Gradient)
              decoration: BoxDecoration(
                borderRadius: borderRadius,
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
                  borderRadius: borderRadius,
                  color: effectiveBorder,
                ),
                child: Container(
                  // 5. Face Intérieure (Fond Bois Gradient)
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: effectiveFace,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        text.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Round',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.darkBrown,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 0,
                            )
                          ]
                        ),
                      ),
                      
                      Positioned.fill(
                        child: ShinyCornerEffect(
                          isCircle: false,
                          borderRadius: shineBorderRadius,
                          color: Colors.white.withValues(alpha: 0.6),
                          strokeWidth: 2.0,
                          padding: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
