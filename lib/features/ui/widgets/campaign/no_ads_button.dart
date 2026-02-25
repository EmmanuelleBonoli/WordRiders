import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/gameplay/services/ad_service.dart';
import 'package:word_riders/features/gameplay/services/iap_service.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';

class NoAdsButton extends StatefulWidget {
  final VoidCallback? onPurchased;

  const NoAdsButton({super.key, this.onPurchased});

  @override
  State<NoAdsButton> createState() => _NoAdsButtonState();
}

class _NoAdsButtonState extends State<NoAdsButton> {
  bool _hasNoAds = false;

  StreamSubscription<String>? _purchaseSub;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    
    // Écouter les succès d'achat en temps réel via le Stream IapService
    _purchaseSub = IapService.purchaseSuccessStream.listen((productId) {
      if (productId == IapService.noAdsProductId) {
        if (mounted) {
          setState(() => _hasNoAds = true);
          widget.onPurchased?.call();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('campaign.noAdsPurchased')),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final hasNoAds = await AdService.hasNoAds();
    if (mounted) {
      setState(() {
        _hasNoAds = hasNoAds;
      });
    }
  }

  Future<void> _purchaseNoAds() async {
    final product = IapService.getProductById(IapService.noAdsProductId);
    
    if (product == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('campaign.store.unavailable')),
            backgroundColor: AppTheme.brown,
          ),
        );
      }
      return;
    }

    // Le résultat sera capté par le listener dans initState
    await IapService.buy(product);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasNoAds) {
      return const SizedBox.shrink();
    }

    final isFr = context.locale.languageCode == 'fr';
    final imagePath = isFr 
        ? 'assets/images/indicators/no_ads_fr.png' 
        : 'assets/images/indicators/no_ads_en.png';

    return BouncingScaleButton(
      onTap: _purchaseNoAds,
      showShadow: false,
      child: Image.asset(
        imagePath,
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }
}
