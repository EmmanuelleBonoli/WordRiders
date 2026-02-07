import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class StoreProductCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final String price;
  final Color color;
  final double height;
  final bool isPopular;
  final bool isCurrencyPrice;
  final String? badgeText;
  final VoidCallback? onTap;

  const StoreProductCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.price,
    required this.color,
    this.height = 180,
    this.isPopular = false,
    this.isCurrencyPrice = false,
    this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingScaleButton(
      onTap: onTap ?? () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 140,
            height: height,
            decoration: BoxDecoration(
              color: AppTheme.tileFace.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.brown, width: 2),
              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withValues(alpha: 0.3),
                   offset: const Offset(0, 4),
                   blurRadius: 6,
                 )
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Text(
                    amount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Round',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color == AppTheme.coinRimTop ? AppTheme.orangeBurnt : color,
                    ),
                  ),
                ),
                
                // Icon
                Icon(icon, size: 48, color: color == AppTheme.coinRimTop ? AppTheme.orangeBurnt : color),
                
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Round',
                    fontSize: 14,
                    color: AppTheme.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      
                const SizedBox(height: 4),
      
                // Button
                Container(
                  margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrencyPrice ? AppTheme.white : AppTheme.green,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrencyPrice ? AppTheme.brown : Colors.white,
                      width: isCurrencyPrice ? 2 : 1
                    ),
                  ),
                  child: Center(
                    child: Text(
                      price,
                      style: TextStyle(
                        fontFamily: 'Round',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCurrencyPrice ? AppTheme.brown : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              left: 35,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.redBad,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2)
                  ]
                ),
                child: Text(
                  badgeText ?? "BEST!", 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
