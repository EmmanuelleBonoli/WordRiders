import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/gameplay/services/ad_service.dart';
import 'package:word_train/features/gameplay/services/iap_service.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class NoAdsButton extends StatefulWidget {
  final VoidCallback? onPurchased;

  const NoAdsButton({super.key, this.onPurchased});

  @override
  State<NoAdsButton> createState() => _NoAdsButtonState();
}

class _NoAdsButtonState extends State<NoAdsButton> {
  bool _hasNoAds = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
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
    // Confirmer l'achat (Simulation du dialogue système native)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          tr('campaign.noAdsConfirmTitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Round',
            color: AppTheme.green,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        content: Text(
          tr('campaign.noAdsConfirmMessageRealMoney'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              tr('settings.cancel'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Round',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              tr('campaign.noAdsPurchase'),
              style: const TextStyle(fontFamily: 'Round', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await IapService.buyNoAds();
      if (success && mounted) {
        setState(() => _hasNoAds = true);
        widget.onPurchased?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('campaign.noAdsPurchased')),
            backgroundColor: AppTheme.green,
          ),
        );
      }
    }
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
