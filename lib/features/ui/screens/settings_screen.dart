import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:word_train/features/ui/widgets/navigation/app_back_button.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/settings/settings_about_section.dart';
import 'package:word_train/features/ui/widgets/settings/settings_audio_section.dart';
import 'package:word_train/features/ui/widgets/settings/settings_language_section.dart';
import 'package:word_train/features/ui/widgets/settings/settings_reset_section.dart';
import 'package:word_train/features/ui/widgets/settings/settings_restore_section.dart';
import 'package:word_train/config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  bool sfxOn = true;
  final String appVersion = AppConfig.version;
  int _currentStage = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final music = await PlayerPreferences.isMusicEnabled();
    final sfx = await PlayerPreferences.isSfxEnabled();
    final stage = await PlayerPreferences.getCurrentStage();
    setState(() {
      musicOn = music;
      sfxOn = sfx;
      _currentStage = stage;
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
             child: Image.asset(
               'assets/images/background/menu_bg.png',
               fit: BoxFit.cover,
               alignment: Alignment.bottomCenter,
             ),
          ),
          
          Positioned.fill(
             child: Container(
               color: Colors.white.withValues(alpha: 0.3),
             ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   child: Row(
                     children: [
                       AppBackButton(onPressed: () => context.pop()),
                       
                       Expanded(
                         child: Text(
                           context.tr('settings.title').toUpperCase(),
                           textAlign: TextAlign.center,
                           style: const TextStyle(
                             fontFamily: 'Round',
                             fontSize: 32,
                             color: AppTheme.brown,
                             fontWeight: FontWeight.w900,
                             letterSpacing: 1.5,
                             shadows: [
                               Shadow(
                                 color: Colors.white60,
                                 offset: Offset(2, 2),
                                 blurRadius: 0,
                               ),
                             ],
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
                 
                 Expanded(
                   child: Center(
                     child: Container(
                       constraints: const BoxConstraints(maxWidth: 600),
                       margin: const EdgeInsets.all(24),
                       child: SingleChildScrollView(
                         child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SettingsLanguageSection(
                              key: ValueKey('lang-${context.locale}'),
                              currentStage: _currentStage,
                              onSettingsChanged: _loadSettings,
                            ),
                            const SizedBox(height: 24),
                            
                            SettingsAudioSection(
                              key: ValueKey('audio-${context.locale}'),
                              musicOn: musicOn,
                              sfxOn: sfxOn,
                              onMusicChanged: (val) => setState(() => musicOn = val),
                              onSfxChanged: (val) => setState(() => sfxOn = val),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            SettingsAboutSection(
                              key: ValueKey('about-${context.locale}'),
                              appVersion: appVersion
                            ),
                                                
                            const SizedBox(height: 40),
                            const SettingsRestoreSection(),
                            const SizedBox(height: 12),
                            SettingsResetSection(
                              key: ValueKey('reset-${context.locale}'),
                              currentStage: _currentStage,
                              onResetComplete: _loadSettings,
                            ),

                            const SizedBox(height: 40),
                            
                            // Copyright
                            Center(
                              child: Text(
                                context.tr('settings.copyright'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Round',
                                  color: AppTheme.brown.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                         ),
                       ),
                     ),
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
