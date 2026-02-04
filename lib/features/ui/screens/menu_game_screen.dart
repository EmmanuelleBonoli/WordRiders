import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/button_widget.dart';
import '../../gameplay/services/player_preferences.dart';
import '../../gameplay/services/word_service.dart';

import 'package:word_train/features/ui/widgets/common/pulsing_widget.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PulsingWidget(
                            child: MenuButton(
                              text: tr('menu.campaign'),
                              onPressed: () => _handleCampaignTap(context),
                              backgroundColor: AppTheme.goldButtonFace,
                              highlightColor: AppTheme.goldButtonHighlight,
                              shadowColor: AppTheme.goldButtonShadow,
                            ),
                          ),
                          const SizedBox(height: 20),
                          MenuButton(
                            text: tr('menu.training'),
                            onPressed: () => context.push('/game'),
                            backgroundColor: AppTheme.goldButtonFace,
                            highlightColor: AppTheme.goldButtonHighlight,
                            shadowColor: AppTheme.goldButtonShadow,
                          ),
                          const SizedBox(height: 20),
                          MenuButton(
                            text: tr('menu.settings'),
                            onPressed: () => context.push('/settings'),
                            backgroundColor: AppTheme.goldButtonFace,
                            highlightColor: AppTheme.goldButtonHighlight,
                            shadowColor: AppTheme.goldButtonShadow,
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
    context.push('/campaign');
  }
}
