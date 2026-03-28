import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:word_riders/features/ui/widgets/common/navigation/app_back_button.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_about_section.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_audio_section.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_language_section.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_container.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_reset_section.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_restore_section.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/tutorial_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/bonus_tutorial_overlay.dart';
import 'package:word_riders/config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  bool sfxOn = true;
  double musicVolume = 0.8;
  double sfxVolume = 0.8;
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
    final mVolume = await PlayerPreferences.getMusicVolume();
    final sVolume = await PlayerPreferences.getSfxVolume();
    final stage = await PlayerPreferences.getCurrentStage();
    if (mounted) {
      setState(() {
        musicOn = music;
        sfxOn = sfx;
        musicVolume = mVolume;
        sfxVolume = sVolume;
        _currentStage = stage;
      });
    }
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
                              musicVolume: musicVolume,
                              sfxVolume: sfxVolume,
                              onMusicChanged: (val) => setState(() => musicOn = val),
                              onSfxChanged: (val) => setState(() => sfxOn = val),
                              onMusicVolumeChanged: (val) => setState(() => musicVolume = val),
                              onSfxVolumeChanged: (val) => setState(() => sfxVolume = val),
                            ),
                            
                            const SizedBox(height: 24),

                            // Section tutoriels
                            SettingsContainer(
                              backgroundColor: AppTheme.tileFace,
                              borderColor: AppTheme.tileShadow,
                              child: Column(
                                children: [
                                  // En-tête de section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.school_rounded, color: AppTheme.brown, size: 22),
                                        const SizedBox(width: 10),
                                        Text(
                                          context.tr('tutorial.list_title').toUpperCase(),
                                          style: const TextStyle(
                                            fontFamily: 'Round',
                                            color: AppTheme.brown,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1, color: AppTheme.tileShadow),

                                  // Tutoriel du jeu
                                  ListTile(
                                    leading: const Icon(Icons.play_circle_outline_rounded, color: AppTheme.tileShadow, size: 28),
                                    title: Text(
                                      context.tr('tutorial.game_tutorial'),
                                      style: const TextStyle(
                                        fontFamily: 'Round',
                                        color: AppTheme.darkBrown,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.brown),
                                    onTap: () async {
                                      await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) => TutorialOverlay(
                                          onComplete: () async {
                                            await PlayerPreferences.setTutorialCompleted(true);
                                            if (ctx.mounted) Navigator.of(ctx).pop();
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.tileShadow),

                                  // Tutoriel : Lettre supplémentaire
                                  ListTile(
                                    leading: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.orange, Colors.deepOrange],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Icon(Icons.text_increase_rounded, color: Colors.white, size: 16),
                                    ),
                                    title: Text(
                                      context.tr('tutorial.bonus_extra_letter_name'),
                                      style: const TextStyle(
                                        fontFamily: 'Round',
                                        color: AppTheme.darkBrown,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.brown),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) => BonusTutorialOverlay(
                                          bonusType: BonusType.extraLetter,
                                          onComplete: () => Navigator.of(ctx).pop(),
                                        ),
                                      );
                                    },
                                  ),

                                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.tileShadow),

                                  // Tutoriel : Distance × 2
                                  ListTile(
                                    leading: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.blue, Colors.indigo],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Icon(Icons.double_arrow_rounded, color: Colors.white, size: 16),
                                    ),
                                    title: Text(
                                      context.tr('tutorial.bonus_double_distance_name'),
                                      style: const TextStyle(
                                        fontFamily: 'Round',
                                        color: AppTheme.darkBrown,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.brown),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) => BonusTutorialOverlay(
                                          bonusType: BonusType.doubleDistance,
                                          onComplete: () => Navigator.of(ctx).pop(),
                                        ),
                                      );
                                    },
                                  ),

                                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.tileShadow),

                                  // Tutoriel : Gel du rival
                                  ListTile(
                                    leading: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.cyan.shade300, Colors.blueAccent],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Icon(Icons.ac_unit_rounded, color: Colors.white, size: 16),
                                    ),
                                    title: Text(
                                      context.tr('tutorial.bonus_freeze_rival_name'),
                                      style: const TextStyle(
                                        fontFamily: 'Round',
                                        color: AppTheme.darkBrown,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.brown),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) => BonusTutorialOverlay(
                                          bonusType: BonusType.freezeRival,
                                          onComplete: () => Navigator.of(ctx).pop(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
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
