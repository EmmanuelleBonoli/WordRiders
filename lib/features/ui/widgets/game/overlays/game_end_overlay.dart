
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/game/overlays/no_lives_overlay.dart';

class GameEndOverlay extends StatefulWidget {
  final bool isWon;
  final bool isCampaign;
  final VoidCallback onQuit;
  final VoidCallback? onRestart; 
  final VoidCallback? onContinue;

  const GameEndOverlay({
    super.key,
    required this.isWon,
    required this.isCampaign,
    required this.onQuit,
    this.onRestart,
    this.onContinue,
  });

  @override
  State<GameEndOverlay> createState() => _GameEndOverlayState();
}

class _GameEndOverlayState extends State<GameEndOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleReplay(BuildContext context) async {
    if (widget.isCampaign) {
      final currentLives = await PlayerPreferences.getLives();
      if (currentLives <= 0) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => NoLivesOverlay(
            onLivesReplenished: () {
               // Si l'utilisateur a rechargé, on relance le jeu
               widget.onRestart?.call();
            },
          ),
        );
        return;
      }
    }
    widget.onRestart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isWon = widget.isWon;
    final mainColor = isWon ? AppTheme.green : AppTheme.red;
    final title = isWon ? tr('game.victory') : tr('game.defeat');
    final message = isWon 
        ? (widget.isCampaign ? tr('game.level_finished') : tr('game.training_won'))
        : tr('game.fox_won');

    // Images des personnages
    final imageAsset = isWon 
        ? 'assets/images/characters/rabbit_head.jpg' 
        : 'assets/images/characters/fox_head.jpg';

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        alignment: Alignment.center,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: mainColor.withValues(alpha: 0.2), width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(imageAsset, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w900,
                      color: mainColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16, color: AppTheme.textDark, height: 1.3),
                    textAlign: TextAlign.center,
                  ),

                  // Affichage récompense pièces si victoire campagne
                  if (widget.isCampaign && isWon) ...[
                     const SizedBox(height: 12),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       decoration: BoxDecoration(
                         color: Colors.amber.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: Colors.amber),
                       ),
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           const Icon(Icons.monetization_on, color: Colors.amber),
                           const SizedBox(width: 8),
                           Text("+60 ${tr('menu.coins')}", style: const TextStyle(color: AppTheme.brown, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                  ],

                  const SizedBox(height: 24),

                  _buildButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (widget.isCampaign && widget.isWon) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onContinue, 
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(tr('game.continue_adventure'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleReplay(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.refresh_rounded, color: Colors.white),
                 const SizedBox(width: 8),
                 Text(tr('game.replay'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
               ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: widget.onQuit,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textDark,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(tr('game.quit'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
} 
