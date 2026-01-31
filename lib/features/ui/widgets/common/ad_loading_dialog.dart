import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/ad_service.dart';

/// Affiche un loader pendant la simulation d'une publicité
class AdLoadingDialog {
  /// Affiche le dialog de chargement de pub et attend la fin
  static Future<void> show(BuildContext context) async {
    // Afficher le loader
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
    await AdService.simulateAdWatch();

    // Fermer le loader
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
