import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';
import 'package:word_riders/data/store_data.dart';
import 'package:word_riders/features/gameplay/services/iap_service.dart';

class StoreSpecialOfferCard extends StatelessWidget {
  final StoreItemData item;
  final String imagePath;
  final VoidCallback? onTap;

  const StoreSpecialOfferCard({
    super.key,
    required this.item,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Résolution du prix réel (IAP)
    String displayPrice = item.price;
    if (item.productId != null) {
      final product = IapService.getProductById(item.productId!);
      if (product != null) {
        displayPrice = product.price;
      }
    }

    return BouncingScaleButton(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.orangeBurnt, AppTheme.coinRimBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.coinBorderDark, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Image / Icon
            Image.asset(
              imagePath,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(item.descriptionKey),
                    style: const TextStyle(
                      fontFamily: 'Round',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(1,1))],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.extendedDescriptionKey != null)
                    Text(
                      context.tr(item.extendedDescriptionKey!),
                      style: TextStyle(
                        fontFamily: 'Round',
                        fontSize: 12,
                        color: AppTheme.white,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.green,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white54, width: 2),
                      boxShadow: const [
                         BoxShadow(
                           color: Colors.black26,
                           offset: Offset(0, 2),
                           blurRadius: 2,
                         )
                      ]
                    ),
                    child: Text(
                      displayPrice,
                      style: const TextStyle(
                        fontFamily: 'Round',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
