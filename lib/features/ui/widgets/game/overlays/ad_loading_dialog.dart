import 'package:flutter/material.dart';
import 'package:word_riders/features/gameplay/services/ad_service.dart';

// Affiche un loader pendant la simulation d'une publicité
class AdLoadingDialog {

  static Future<void> show(BuildContext context, {bool isRewarded = false}) async {
    // Afficher le loader/pub simulée
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    // Simuler la pub
    if (isRewarded) {
      await AdService.simulateRewardedAdWatch();
    } else {
      await AdService.simulateAdWatch();
    }

    // Fermer le loader
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
