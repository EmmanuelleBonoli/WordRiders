import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/store/store_product_card.dart';
import 'package:word_riders/data/store_data.dart';
import 'package:word_riders/features/gameplay/services/iap_service.dart';

class StoreItemCard extends StatelessWidget {
  final StoreItemData item;
  final VoidCallback? onTap;
  
  const StoreItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  Widget _buildBonusIcon(IconData icon, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Déterminer la couleur
    Color cardColor;
    bool isGold = false;
    
    switch (item.colorType) {
      case StoreItemColorType.blue:
        cardColor = Colors.blue;
        break;
      case StoreItemColorType.gold:
      case StoreItemColorType.goldDark:
        cardColor = AppTheme.coinRimTop;
        isGold = true;
        break;
    }

    // 2. Déterminer l'icône/visuel
    Widget visualContent;
    
    switch (item.visualType) {
      case StoreVisualType.unlimited:
        visualContent = SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
               Positioned(
                child: Image(
                  image: AssetImage(item.assetPath),
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              const Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.all_inclusive, color: Colors.white, size: 24),
              ),
            ],
          ),
        );
        break;
        
      case StoreVisualType.stackedCoins:
        visualContent = SizedBox(
          width: 95, 
          height: 95,
          child: Stack(
            alignment: Alignment.center,
            children: [
               Positioned(
                 left: 25, top: 0,
                 child: Image(image: AssetImage(item.assetPath), width: 45),
               ),
               Positioned(
                 left: 0, top: 35,
                 child: Image(image: AssetImage(item.assetPath), width: 45),
               ),
               Positioned(
                 left: 50, top: 35,
                 child: Image(image: AssetImage(item.assetPath), width: 45),
               ),
            ],
          ),
        );
        break;
        
      case StoreVisualType.chest:
        visualContent = Image(
          image: AssetImage(item.assetPath),
          width: 120, 
          height: 120,
          fit: BoxFit.contain,
        );
        break;

      case StoreVisualType.bonus:
        visualContent = SizedBox(
          width: 65, 
          height: 65,
          child: Stack(
            alignment: Alignment.center,
            children: [
               Positioned(
                 left: 18.5, top: 0,
                 child: _buildBonusIcon(Icons.text_increase_rounded, Colors.orange),
               ),
               Positioned(
                 left: 0, top: 25,
                 child: _buildBonusIcon(Icons.double_arrow_rounded, Colors.blue),
               ),
               Positioned(
                 left: 37, top: 25,
                 child: _buildBonusIcon(Icons.ac_unit_rounded, Colors.cyan),
               ),
            ],
          ),
        );
        break;

      case StoreVisualType.bonusUnlimited:
        visualContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 65, 
              height: 65,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Positioned(
                     left: 18.5, top: 0,
                     child: _buildBonusIcon(Icons.text_increase_rounded, Colors.orange),
                   ),
                   Positioned(
                     left: 0, top: 25,
                     child: _buildBonusIcon(Icons.double_arrow_rounded, Colors.blue),
                   ),
                   Positioned(
                     left: 37, top: 25,
                     child: _buildBonusIcon(Icons.ac_unit_rounded, Colors.cyan),
                   ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/images/indicators/heart.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const Positioned(
                      bottom: -2,
                      right: -2,
                      child: Icon(Icons.all_inclusive, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  "1h",
                  style: TextStyle(
                    fontFamily: 'Round',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
        break;

      default:
        visualContent = item.assetPath.isNotEmpty 
          ? Image(
              image: AssetImage(item.assetPath),
              width: item.colorType == StoreItemColorType.gold ? 42 : 50, 
              height: item.colorType == StoreItemColorType.gold ? 42 : 50,
              fit: BoxFit.contain,
            )
          : const SizedBox(); 
        break;
    }

    // 3. Résolution du prix réel (IAP)
    String displayPrice = item.price;
    if (item.productId != null) {
      final product = IapService.getProductById(item.productId!);
      if (product != null) {
        displayPrice = product.price; // Prix formaté localisé par le store (ex: "4,99 €")
      }
    }

    return StoreProductCard(
      description: item.descriptionKey.isNotEmpty ? context.tr(item.descriptionKey) : "",
      title: item.title,
      customIcon: visualContent,
      price: displayPrice,
      color: cardColor,
      isGold: isGold,
      isPopular: item.isPopular,
      isCurrencyPrice: item.isCurrencyPrice,
      badgeText: item.badgeTextKey != null ? context.tr(item.badgeTextKey!) : null,
      height: item.height,
      onTap: onTap,
    );
  }
}
