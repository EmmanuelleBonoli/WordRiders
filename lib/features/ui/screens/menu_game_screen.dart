import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/common/premium_menu_button.dart';
import '../../gameplay/services/player_preferences.dart';
import '../../gameplay/services/word_service.dart';

import 'package:word_train/features/ui/widgets/common/pulsing_widget.dart';

class MenuGameScreen extends StatelessWidget {
  const MenuGameScreen({super.key});

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background/menu_bg2.png'),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.3),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.white.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Image
                    Image.asset(
                      'assets/images/logo_title.png',
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 60),
              
                    // Menu Buttons
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PulsingWidget(
                            child: PremiumMenuButton(
                              text: context.tr('menu.campaign'),
                              onTap: () => _handleCampaignTap(context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PremiumMenuButton(
                            text: context.tr('menu.training'),
                            onTap: () => context.push('/game'),
                          ),
                          const SizedBox(height: 20),
                          PremiumMenuButton(
                            text: context.tr('menu.settings'),
                            onTap: () => context.push('/settings'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCampaignTap(BuildContext context) async {
    // Capturer la locale immédiatement avant toute opération async
    final locale = context.locale.languageCode;
    
    final initialized = await PlayerPreferences.isCampaignInitialized();
    
    if (!initialized) {
      // Auto-initialiser la campagne silencieusement
      try {
        final service = WordService();
        final words = [await service.getNextCampaignWord(locale, stage: 1)];
        
        await PlayerPreferences.resetCampaign();
        await PlayerPreferences.setCampaignWords(words);

        debugPrint("Campagne auto-initialisée avec ${words.length} mots");
      } catch (e) {
        debugPrint("Erreur auto-init campagne : $e");
        // En cas d'erreur, on continue quand même vers l'écran
      }
    }
    
    // Vérifier que le widget est toujours monté avant de naviguer
    if (!context.mounted) return;
    context.go('/campaign');
  }
}
