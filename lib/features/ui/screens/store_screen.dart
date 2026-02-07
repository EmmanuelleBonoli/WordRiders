
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';
import 'package:word_train/features/ui/widgets/store/store_product_card.dart';
import 'package:word_train/features/gameplay/services/ad_service.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final isFr = context.locale.languageCode == 'fr';
    final imagePath = isFr 
        ? 'assets/images/indicators/no_ads_fr2.png' 
        : 'assets/images/indicators/no_ads_en2.png';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [


          // --- SPECIAL OFFERS ---
          FutureBuilder<bool>(
            future: AdService.hasNoAds(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                   const SizedBox(height: 12),
                   _buildSpecialOfferCard(context, imagePath),
                   const SizedBox(height: 30),
                ],
              );
            },
          ),

   // --- CONSUMABLES ---
          _buildSectionHeader(tr('campaign.store.essentials')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StoreProductCard(
                  title: tr('campaign.store.refill_lives'),
                  amount: "FULL",
                  icon: Icons.favorite,
                  price: "200 Coins",
                  color: AppTheme.redBad,
                  height: 180,
                  isCurrencyPrice: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StoreProductCard(
                  title: tr('campaign.store.hint_pack'),
                  amount: "x5",
                  icon: Icons.lightbulb,
                  price: "150 Coins",
                  color: Colors.blueAccent,
                  height: 180,
                  isCurrencyPrice: true,
                ),
              ),
            ],
          ),


          const SizedBox(height: 30),

// --- COIN PACKS ---
          _buildSectionHeader(tr('campaign.store.coin_packs')),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                StoreProductCard(
                  title: tr('campaign.store.handful'),
                  amount: "100",
                  icon: Icons.monetization_on,
                  price: "0.99 €",
                  color: AppTheme.coinRimTop,
                ),
                const SizedBox(width: 16),
                StoreProductCard(
                  title: tr('campaign.store.pouch'),
                  amount: "500",
                  icon: Icons.savings,
                  price: "3.99 €",
                  color: AppTheme.coinRimTop,
                  isPopular: true,
                  badgeText: tr('campaign.store.best_badge'),
                ),
                const SizedBox(width: 16),
                StoreProductCard(
                  title: tr('campaign.store.chest'),
                  amount: "1500",
                  icon: Icons.account_balance,
                  price: "9.99 €",
                  color: AppTheme.coinRimTop,
                ),
              ],
            ),
          ),  
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.stars, color: AppTheme.orangeBurnt, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Round',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.white,
             shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialOfferCard(BuildContext context, String imagePath) {
    return Container(
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
                  tr('campaign.store.no_ads_title'),
                  style: const TextStyle(
                    fontFamily: 'Round',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                    shadows: [Shadow(color: Colors.black26, offset: Offset(1,1))],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('campaign.store.no_ads_desc'),
                  style: TextStyle(
                    fontFamily: 'Round',
                    fontSize: 12,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 12),
                BouncingScaleButton(
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Purchase simulation: No Ads Bundle")),
                    );
                  },
                  child: Container(
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
                    child: const Text(
                      "4.99 €",
                      style: TextStyle(
                        fontFamily: 'Round',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
