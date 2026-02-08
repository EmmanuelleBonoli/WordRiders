import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';
import 'package:word_train/features/ui/widgets/store/store_product_card.dart';
import 'package:word_train/features/gameplay/services/ad_service.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/gameplay/services/iap_service.dart';
import 'package:word_train/features/ui/widgets/animations/resource_transfer_animation.dart';
import 'package:word_train/features/ui/screens/main_scaffold.dart';
import 'package:word_train/data/store_data.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final GlobalKey _refillLivesKey = GlobalKey();
  final GlobalKey _unlimitedLivesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Écoute les retours de l'IAP Service pour afficher des feedbacks
    IapService.onErrorOrSuccess = (message, isError) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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
    super.dispose();
  }

  GlobalKey? _getKeyForId(String id) {
    if (id == 'refill_lives') return _refillLivesKey;
    if (id == 'unlimited_lives') return _unlimitedLivesKey;
    return null;
  }
  
  VoidCallback? _getOnTapForItem(StoreItemData item) {
    // 1. Achats virtuels (Vies)
    if (item.id == 'refill_lives') return () => _buyRefillLives(context);
    if (item.id == 'unlimited_lives') return () => _buyUnlimitedLives(context);
    
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
             const SnackBar(content: Text("Produit indisponible (Store non connecté)")),
           );
         }
       };
    }
    return null;
  }

  Widget _buildProductCard(StoreItemData item) {
    // 1. Déterminer la couleur
    Color cardColor;
    bool isGold = false;
    
    switch (item.colorType) {
      case StoreItemColorType.blue:
        cardColor = Colors.blue;
        break;
      case StoreItemColorType.purple:
        cardColor = Colors.purpleAccent;
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
      key: _getKeyForId(item.id) ?? ValueKey(item.id),
      title: item.titleKey.isNotEmpty ? context.tr(item.titleKey) : "",
      amount: item.amount,
      customIcon: visualContent,
      price: displayPrice,
      color: cardColor,
      isGold: isGold,
      isPopular: item.isPopular,
      isCurrencyPrice: item.isCurrencyPrice,
      badgeText: item.badgeTextKey != null ? context.tr(item.badgeTextKey!) : null,
      height: item.height,
      onTap: _getOnTapForItem(item),
    );
  }

  Future<void> _buyRefillLives(BuildContext context) async {
    final int cost = 900;
    
    // 1. Vérifier si déjà full (sauf si illimité)
    final isUnlimited = await PlayerPreferences.isUnlimitedLivesActive();
    if (!context.mounted) return;

    if (isUnlimited) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vous avez déjà des vies illimitées !")));
       return;
    }
    
    final currentLives = await PlayerPreferences.getLives();
    if (!context.mounted) return;

    if (currentLives >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vos vies sont déjà pleines !")));
      return;
    }

    // 2. Vérifier les fonds
    final currentCoins = await PlayerPreferences.getCoins();
    if (!context.mounted) return;

    if (currentCoins < cost) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pas assez de pièces !")));
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
       context.findAncestorStateOfType<MainScaffoldState>()?.reloadIndicators();
    }
  }

  Future<void> _buyUnlimitedLives(BuildContext context) async {
    final int cost = 1500;
    
    // 1. Vérifier les fonds
    final currentCoins = await PlayerPreferences.getCoins();
    if (!context.mounted) return;
    
    if (currentCoins < cost) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pas assez de pièces !")));
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
       context.findAncestorStateOfType<MainScaffoldState>()?.reloadIndicators();
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
                        child: _buildSpecialOfferCard(context, item, imagePath),
                      )
                   ),
                ],
              );
            },
          ),

   // --- CONSOMMABLES ---
           _buildSectionHeader(context.tr('campaign.store.essentials')),
           const SizedBox(height: 12),
           Row(
             children: consumableItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final widget = Expanded(child: _buildProductCard(item));
                
                if (index < consumableItems.length - 1) {
                  return [widget, const SizedBox(width: 16)];
                }
                return [widget];
             }).expand((x) => x).toList(),
           ),


          const SizedBox(height: 30),

           // --- PACKS DE PIÈCES ---
          _buildSectionHeader(context.tr('campaign.store.coin_packs')),
          const SizedBox(height: 12),
          SizedBox(
            height: coinPackItems.isNotEmpty ? coinPackItems.first.height : 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: coinPackItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (ctx, index) => _buildProductCard(coinPackItems[index]),
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

  Widget _buildSpecialOfferCard(BuildContext context, StoreItemData item, String imagePath) {
    // Résolution du prix réel (IAP)
    String displayPrice = item.price;
    if (item.productId != null) {
      final product = IapService.getProductById(item.productId!);
      if (product != null) {
        displayPrice = product.price;
      }
    }

    return BouncingScaleButton(
      onTap: _getOnTapForItem(item) ?? () {},
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
                    context.tr(item.titleKey),
                    style: const TextStyle(
                      fontFamily: 'Round',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(1,1))],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.descriptionKey != null)
                    Text(
                      context.tr(item.descriptionKey!),
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
