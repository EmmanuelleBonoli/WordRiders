import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/gameplay/services/ad_service.dart';
import 'package:word_train/features/gameplay/services/iap_service.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/pushable_button.dart';

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
      // Version "Acheté" (Pas un bouton, juste un indicateur 3D)
      const double depth = 4.0;
      const Color faceColor = AppTheme.green;
      const Color sideColor = AppTheme.greenButtonShadow;
      const Color highlightColor = AppTheme.greenButtonHighlight;

      return Container(
        height: 48,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              top: depth,
              left: 0,
              right: 0,
              bottom: -depth,
              child: Container(
                decoration: BoxDecoration(
                  color: sideColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                     BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 2,
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: faceColor,
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [highlightColor, faceColor],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    tr('campaign.noAds'),
                    style: const TextStyle(
                      fontFamily: 'Round',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Version Bouton "Acheter"
    return SizedBox(
      height: 60,
      child: PushableButton(
        onPressed: _purchaseNoAds,
        color: AppTheme.goldButtonFace,
        shadowColor: AppTheme.goldButtonShadow,
        highlightColor: AppTheme.goldButtonHighlight,
        height: 48,
        depth: 4,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icone composée : Caméra + Interdit
              SizedBox(
                width: 28,
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.videocam_rounded,
                      color: AppTheme.brown,
                      size: 24,
                    ),
                    Transform.scale(
                      scale: 1.2,
                      child: const Icon(
                        Icons.block,
                        color: AppTheme.red,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'NO ADS',
                style: TextStyle(
                  fontFamily: 'Round',
                  fontSize: 16,
                  color: AppTheme.brown,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
