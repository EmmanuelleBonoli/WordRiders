import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/settings/settings_button.dart';
import 'package:word_train/features/ui/widgets/navigation/app_back_button.dart';

class GameHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final bool isCampaign;
  final int currentStage;

  const GameHeader({
    super.key,
    required this.onBack,
    required this.onSettings,
    required this.isCampaign,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
           // 1. Bouton Gauche (Retour)
           Align(
             alignment: Alignment.centerLeft,
             child: AppBackButton(onPressed: onBack),
           ),
           
           // 2. Panneau Central (Seulement si Campagne)
           if (isCampaign)
             _buildCampaignBoard(context),

           // 3. Côté Droit (Vies + Paramètres)
           Align(
             alignment: Alignment.centerRight,
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 SettingsButton(onTap: onSettings),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildCampaignBoard(BuildContext context) {
    final double maxBoardWidth = MediaQuery.of(context).size.width - 160;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxBoardWidth),
      child: Container(
        // 1. Bordure Extérieure Sombre (avec Ombre)
        decoration: BoxDecoration(
          color: AppTheme.coinBorderDark, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          // 2. Anneau Dégradé Or
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(14.5)),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
            ),
          ),
          padding: const EdgeInsets.all(4.0),
          child: Container(
             // 3. Bordure Intérieure Sombre
             decoration: BoxDecoration(
              color: AppTheme.coinBorderDark, 
              borderRadius: BorderRadius.circular(10.5),
             ),
             padding: const EdgeInsets.all(1.5),
             child: Container(
               // 4. Face (Crème)
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
               decoration: BoxDecoration(
                 color: AppTheme.levelSignFace, 
                 borderRadius: BorderRadius.circular(9),
               ),
               child: FittedBox(
                 fit: BoxFit.scaleDown,
                 child: Text(
                    "LEVEL $currentStage",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.coinBorderDark, 
                      letterSpacing: 1.0,
                    ),
                 ),
               ),
             ),
          ),
        ),
      ),
    );
  }
}
