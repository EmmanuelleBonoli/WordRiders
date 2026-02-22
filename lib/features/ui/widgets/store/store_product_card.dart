import 'package:flutter/material.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';

class StoreProductCard extends StatelessWidget {
  final String description;
  final String title;
  final IconData? icon;
  final Widget? customIcon;
  final String price;
  final Color color;
  final double height;
  final bool isPopular;
  final bool isCurrencyPrice;
  final bool isGold;
  final String? badgeText;
  final VoidCallback? onTap;

  const StoreProductCard({
    super.key,
    required this.description,
    required this.title,
    this.icon,
    this.customIcon,
    required this.price,
    required this.color,
    this.height = 180,
    this.isPopular = false,
    this.isCurrencyPrice = false,
    this.isGold = false,
    this.badgeText,
    this.onTap,
  }) : assert(icon != null || customIcon != null, 'Either icon or customIcon must be provided');

  @override
  Widget build(BuildContext context) {
    // 1. Couleurs du thème basées sur isGold ou la couleur locale
    final Color bgStart = isGold ? AppTheme.coinRimTop : color.withValues(alpha: 0.9);
    final Color bgEnd = isGold ? AppTheme.coinFaceBottom : color;
    
    final Color contentColor = isGold ? AppTheme.brown : Colors.white;
    final Color buttonBg = isGold ? AppTheme.white : Colors.white;
    final Color buttonText = isGold ? AppTheme.brown : color;

    // 2. Widget Icône
    final Widget iconWidget = customIcon ?? Icon(
      icon,
      size: 42,
      color: contentColor,
    );

    return BouncingScaleButton(
      onTap: onTap ?? () {},
      showShadow: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Conteneur principal de la carte
          Container(
            width: 145,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgStart, bgEnd],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4), 
                width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 6),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 12),
                
                // HEADER AMOUNT
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Round',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: contentColor,
                    shadows: [
                      Shadow(
                        color: isGold ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      )
                    ],
                  ),
                ),
                
                // CENTER ICON
                Expanded(
                  child: Center(
                    child: iconWidget,
                  ),
                ),
                
                // DESCRIPTION (Optionnel)
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Round',
                        fontSize: 13,
                        color: contentColor.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else 
                   const SizedBox(height: 4),

                const SizedBox(height: 8),

                // PRICE PILL BUTTON
                Container(
                  margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: buttonBg,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 3),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontFamily: 'Round',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: buttonText,
                          ),
                        ),
                        if (isCurrencyPrice) ...[
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/images/indicators/coin.png',
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // POPULAR BADGE
          if (isPopular)
            Positioned(
              top: -8,
              right: -8,
              child: Transform.rotate(
                angle: 0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.redBad, AppTheme.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                       BoxShadow(
                         color: Colors.black26, 
                         offset: Offset(0, 2), 
                         blurRadius: 4
                       )
                    ]
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                         padding: const EdgeInsets.only(bottom: 1),
                         child: const Icon(Icons.star, color: Colors.yellow, size: 12)
                      ),
                      const SizedBox(width: 3),
                      Text(
                        badgeText ?? "BEST", 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
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
}
