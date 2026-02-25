import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';

import 'package:word_riders/features/ui/widgets/store/store_item_card.dart';
import 'package:word_riders/features/ui/widgets/store/store_section_header.dart';
import 'package:word_riders/features/ui/widgets/store/store_special_offer_card.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/gameplay/services/iap_service.dart';
import 'package:word_riders/features/ui/animations/resource_transfer_animation.dart';
import 'package:word_riders/features/ui/widgets/common/main_layout.dart';
import 'package:word_riders/data/store_data.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final GlobalKey _refillLivesKey = GlobalKey();
  final GlobalKey _unlimitedLivesKey = GlobalKey();
  final GlobalKey _bonusPack1Key = GlobalKey();
  final GlobalKey _bonusPackUnlimitedKey = GlobalKey();

  final ScrollController _coinPacksScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Écoute les retours de l'IAP Service pour afficher des feedbacks
    IapService.onErrorOrSuccess = (messageKey, isError, {namedArgs}) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(messageKey, namedArgs: namedArgs)),
          backgroundColor: isError ? AppTheme.red : AppTheme.green,
        ),
      );
      // Recharger l'UI pour mettre à jour les crédits/vies
      setState(() {});
    };
  }

  @override
  void dispose() {
    IapService.onErrorOrSuccess = null;
    _coinPacksScrollController.dispose();
    super.dispose();
  }

  GlobalKey? _getKeyForId(String id) {
    if (id == 'refill_lives') return _refillLivesKey;
    if (id == 'unlimited_lives') return _unlimitedLivesKey;
    if (id == 'bonus_pack_1') return _bonusPack1Key;
    if (id == 'bonus_pack_unlimited') return _bonusPackUnlimitedKey;
    return null;
  }
  
  VoidCallback? _getOnTapForItem(StoreItemData item) {
    if (item.id == 'refill_lives') return () => _buyRefillLives(context, item);
    if (item.id == 'unlimited_lives') return () => _buyUnlimitedLives(context, item);
    if (item.id == 'bonus_pack_1') return () => _buyBonusPack1(context, item);
    if (item.id == 'bonus_pack_unlimited') return () => _buyBonusPackUnlimited(context, item);
    
    // 2. Achats Réels (IAP)
    if (item.productId != null) {
       return () async {
         final product = IapService.getProductById(item.productId!);
         if (product != null) {
           await IapService.buy(product);
         } else {
           // Fallback si le produit n'est pas chargé (ex: offline ou web)
           // On pourrait tenter IapService.buy() avec un faux produit ou afficher une erreur
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(context.tr('campaign.store.unavailable'))),
           );
         }
       };
    }
    return null;
  }


  Future<void> _buyRefillLives(BuildContext context, StoreItemData item) async {
    final int cost = int.tryParse(item.price) ?? 900;
    
    // 1. Vérifier si déjà full (sauf si illimité)
    final isUnlimited = await PlayerPreferences.isUnlimitedLivesActive();
    if (!context.mounted) return;

    if (isUnlimited) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('campaign.store.already_unlimited'))));
       return;
    }
    
    final currentLives = await PlayerPreferences.getLives();
    if (!context.mounted) return;

    if (currentLives >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('campaign.store.already_full'))));
      return;
    }

    // 2. Vérifier les fonds
    final currentCoins = await PlayerPreferences.getCoins();
    if (!context.mounted) return;

    if (currentCoins < cost) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('campaign.notEnoughCoins'))));
       return;
    }

    // 3. Effectuer l'achat
    await PlayerPreferences.spendCoins(cost);
    await PlayerPreferences.setLives(5);

    // 4. Animation & Feedback
    if (context.mounted) {
       ResourceTransferAnimation.start(
         context, 
         startKey: _refillLivesKey, 
         assetPath: 'assets/images/indicators/heart.png',
       );
       
       // Mettre à jour l'UI
       context.findAncestorStateOfType<MainLayoutState>()?.reloadIndicators();
    }
  }

  Future<void> _buyUnlimitedLives(BuildContext context, StoreItemData item) async {
    final int cost = int.tryParse(item.price) ?? 1500;
    
    // 1. Vérifier les fonds
    final currentCoins = await PlayerPreferences.getCoins();
    if (!context.mounted) return;
    
    if (currentCoins < cost) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('campaign.notEnoughCoins'))));
       return;
    }

    // 2. Effectuer l'achat
    await PlayerPreferences.spendCoins(cost);
    await PlayerPreferences.addUnlimitedLivesTime(const Duration(minutes: 90)); // 1h30

    // 3. Animation & Feedback
    if (context.mounted) {
       ResourceTransferAnimation.start(
         context, 
         startKey: _unlimitedLivesKey, 
         assetPath: 'assets/images/indicators/heart.png',
       );
       // Mettre à jour l'UI
       context.findAncestorStateOfType<MainLayoutState>()?.reloadIndicators();
    }
  }

  Future<void> _buyBonusPack1(BuildContext context, StoreItemData item) async {
    final int cost = int.tryParse(item.price) ?? 800;
    
    final currentCoins = await PlayerPreferences.getCoins();
    if (!context.mounted) return;
    
    if (currentCoins < cost) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('campaign.notEnoughCoins'))));
       return;
    }

    await PlayerPreferences.spendCoins(cost);
    await PlayerPreferences.addBonusItems(extraLetter: 1, doubleDistance: 1, freezeRival: 1);

    if (context.mounted) {
       ResourceTransferAnimation.start(
         context, 
         startKey: _bonusPack1Key, 
         assetPath: 'assets/images/indicators/coin.png',
       );
       context.findAncestorStateOfType<MainLayoutState>()?.reloadIndicators();
    }
  }

  Future<void> _buyBonusPackUnlimited(BuildContext context, StoreItemData item) async {
    final int cost = int.tryParse(item.price) ?? 2500;
    
    final currentCoins = await PlayerPreferences.getCoins();
    if (!context.mounted) return;
    
    if (currentCoins < cost) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('campaign.notEnoughCoins'))));
       return;
    }

    await PlayerPreferences.spendCoins(cost);
    await PlayerPreferences.addBonusItems(extraLetter: 1, doubleDistance: 1, freezeRival: 1);
    await PlayerPreferences.addUnlimitedLivesTime(const Duration(minutes: 60)); // 1h

    if (context.mounted) {
       ResourceTransferAnimation.start(
         context, 
         startKey: _bonusPackUnlimitedKey, 
         assetPath: 'assets/images/indicators/heart.png',
       );
       context.findAncestorStateOfType<MainLayoutState>()?.reloadIndicators();
    }
  }

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


          // --- OFFRES SPÉCIALES ---
          FutureBuilder<bool>(
            future: IapService.isNoAdsPurchased(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return const SizedBox.shrink();
              }
              // Si vide, ne pas afficher la colonne
              if (specialOfferItems.isEmpty) return const SizedBox.shrink();
              
              return Column(
                children: [
                   const SizedBox(height: 12),
                   ...specialOfferItems.map((item) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: StoreSpecialOfferCard(
                          item: item, 
                          imagePath: imagePath,
                          onTap: _getOnTapForItem(item),
                        ),
                      )
                   ),
                ],
              );
            },
          ),

           StoreSectionHeader(title: context.tr('campaign.store.essentials')),
           const SizedBox(height: 12),
           LayoutBuilder(
             builder: (context, constraints) {
               // On calcule la largeur pour placer 2 items par ligne en conservant un espace de 16
               final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
               final spacing = 16.0;
               final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
               
               return Wrap(
                 spacing: spacing,
                 runSpacing: spacing,
                 children: consumableItems.map((item) {
                   return SizedBox(
                     width: itemWidth,
                     child: StoreItemCard(
                       key: _getKeyForId(item.id) ?? ValueKey(item.id),
                       item: item,
                       onTap: _getOnTapForItem(item),
                     ),
                   );
                 }).toList(),
               );
             },
           ),

          const SizedBox(height: 30),

           // --- PACKS DE PIÈCES ---
          StoreSectionHeader(title: context.tr('campaign.store.coin_packs')),
          const SizedBox(height: 12),
          SizedBox(
            height: (coinPackItems.isNotEmpty ? coinPackItems.first.height : 220) + 24,
            child: Scrollbar(
              controller: _coinPacksScrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: _coinPacksScrollController,
                padding: const EdgeInsets.only(bottom: 24),
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: coinPackItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (ctx, index) {
                  final item = coinPackItems[index];
                  return StoreItemCard(
                    key: _getKeyForId(item.id) ?? ValueKey(item.id),
                    item: item,
                    onTap: _getOnTapForItem(item),
                  );
                },
              ),
            ),
          ),  
        ],
      ),
    );
  }
}

