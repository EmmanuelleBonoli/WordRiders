import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/ad_loading_dialog.dart';

class NoLivesOverlay extends StatefulWidget {
  final VoidCallback onLivesReplenished;

  const NoLivesOverlay({super.key, required this.onLivesReplenished});

  @override
  State<NoLivesOverlay> createState() => _NoLivesOverlayState();
}

class _NoLivesOverlayState extends State<NoLivesOverlay> {
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final c = await PlayerPreferences.getCoins();
    if (mounted) setState(() => _coins = c);
  }

  Future<void> _buyLives() async {
    final success = await PlayerPreferences.spendCoins(700);
    if (success) {
      await PlayerPreferences.setLives(5);
      widget.onLivesReplenished();
      if (mounted) Navigator.of(context).pop();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('campaign.notEnoughCoins')),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _watchAd() async {
    // Afficher le loader de pub
    await AdLoadingDialog.show(context);
    
    if (mounted) {
      final current = await PlayerPreferences.getLives();
      await PlayerPreferences.setLives(current + 1);
      widget.onLivesReplenished();
      if (mounted) Navigator.of(context).pop(); // Close modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.brown, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border_rounded, size: 40, color: AppTheme.red),
              const SizedBox(height: 8),
              Text(
                tr('campaign.noLives'),
                style: const TextStyle(
                  fontFamily: 'Round',
                  fontSize: 18,
                  color: AppTheme.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                tr('campaign.noLivesMessage'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_coins',
                    style: const TextStyle(
                      fontFamily: 'Round',
                      fontSize: 16,
                      color: AppTheme.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCompactButton(
                text: tr('campaign.watchAd'),
                icon: Icons.play_circle_outline,
                color: AppTheme.green,
                onPressed: _watchAd,
                enabled: true,
              ),
              const SizedBox(height: 8),
              _buildCompactButton(
                text: '${tr('campaign.buyLives')} (700 🪙)',
                icon: Icons.shopping_cart_outlined,
                color: Colors.amber,
                onPressed: _buyLives,
                enabled: _coins >= 700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Round',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : Colors.grey.shade300,
          foregroundColor: enabled ? Colors.white : Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          elevation: enabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
