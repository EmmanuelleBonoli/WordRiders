import 'package:flutter/material.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';

class ResourceBadge extends StatelessWidget {
  final String imageAsset;
  final Widget content;
  final double imageSize;
  final double imageTopOffset;
  final Widget? overlayIcon;

  const ResourceBadge({
    super.key,
    required this.imageAsset,
    required this.content,
    this.imageSize = 56.0,
    this.imageTopOffset = -10.0,
    this.overlayIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.none,
      children: [
        // Encart (Badge)
        Container(
          height: 40,
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              )
            ],
          ),
          child: Container(
            // 1. Bordure Extérieure (Dark)
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: AppTheme.coinBorderDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              // 2. Cerclage Doré (Gold Rim)
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
                ),
                borderRadius: BorderRadius.circular(18.5),
              ),
              child: Container(
                // 3. Bordure Intérieure (Dark)
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: AppTheme.coinBorderDark,
                  borderRadius: BorderRadius.circular(15.5),
                ),
                child: Container(
                  // 4. Face (Contenu)
                  padding: const EdgeInsets.only(left: 28, right: 16),
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minWidth: 40),
                  decoration: BoxDecoration(
                    color: AppTheme.levelSignFace,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ),
        
        // Image Illustrative
        Positioned(
          left: -8,
          top: imageTopOffset, 
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Image.asset(
                imageAsset,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
              if (overlayIcon != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: overlayIcon!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
