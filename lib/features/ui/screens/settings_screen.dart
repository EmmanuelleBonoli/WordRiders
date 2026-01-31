import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:word_train/features/ui/widgets/navigation/app_back_button.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  bool sfxOn = true;
  String appVersion = '1.0.0';
  int _currentStage = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
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

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint("Erreur chargement version: $e");
    }
  }

  void _confirmChangeLanguage(BuildContext context, Locale newLocale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          tr('settings.changeLanguageConfirmTitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Round',
            color: AppTheme.red,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        content: Text(
          tr('settings.changeLanguageConfirmMessage'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
            onPressed: () async {
              Navigator.pop(ctx);
              await PlayerPreferences.resetCampaign();
              if (context.mounted) {
                 await context.setLocale(newLocale);
                 _loadSettings(); 
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              tr('settings.confirm'),
              style: const TextStyle(fontFamily: 'Round', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
                           tr('settings.title').toUpperCase(),
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
                       const SizedBox(width: 48),
                     ],
                   ),
                 ),
                 
                 Expanded(
                   child: Center(
                     child: Container(
                       constraints: const BoxConstraints(maxWidth: 600),
                       margin: const EdgeInsets.all(24),
                       child: ListView(
                        shrinkWrap: true,
                        children: [
                          _buildSectionTitle(tr('settings.language'), AppTheme.darkBrown),
                          Container(
                            decoration: _itemDecoration(AppTheme.gold, AppTheme.goldShadow),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.language, color: AppTheme.brown, size: 28),
                              title: Text(
                                tr('settings.language'), 
                                style: const TextStyle(
                                  fontFamily: 'Round', 
                                  color: AppTheme.darkBrown, 
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              trailing: DropdownButtonHideUnderline(
                                child: DropdownButton<Locale>(
                                  value: context.locale,
                                  dropdownColor: AppTheme.gold,
                                  icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.brown, size: 32),
                                  borderRadius: BorderRadius.circular(12),
                                  style: const TextStyle(fontFamily: 'Round', color: AppTheme.darkBrown, fontSize: 18),
                                  items: [
                                    const DropdownMenuItem(
                                      value: Locale('en'),
                                      child: Text('ENGLISH'),
                                    ),
                                    const DropdownMenuItem(
                                      value: Locale('fr'),
                                      child: Text('FRANÇAIS'),
                                    ),
                                  ],
                                  onChanged: (newLocale) async {
                                    if (newLocale != null && newLocale != context.locale) {
                                      if (_currentStage > 1) {
                                        _confirmChangeLanguage(context, newLocale);
                                      } else {
                                        context.setLocale(newLocale);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle("AUDIO", AppTheme.darkBrown),
                          Container(
                            decoration: _itemDecoration(AppTheme.gold, AppTheme.goldShadow),
                            child: Column(
                              children: [
                                _buildSwitchTile(
                                  title: tr('settings.enableMusic'),
                                  value: musicOn,
                                  icon: musicOn ? Icons.music_note_rounded : Icons.music_off_rounded,
                                  color: AppTheme.goldShadow,
                                  textColor: AppTheme.darkBrown,
                                  onChanged: (val) async {
                                    setState(() => musicOn = val);
                                    await PlayerPreferences.setMusicEnabled(val);
                                  },
                                ),
                                Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
                                _buildSwitchTile(
                                  title: tr('settings.enableSounds'),
                                  value: sfxOn,
                                  icon: sfxOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                  color: AppTheme.goldShadow,
                                  textColor: AppTheme.darkBrown,
                                  onChanged: (newValue) async {
                                    setState(() => sfxOn = newValue);
                                    await PlayerPreferences.setSfxEnabled(newValue);
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          _buildSectionTitle(tr('settings.aboutTitle').toUpperCase(), AppTheme.darkBrown),
                          Container(
                            decoration: _itemDecoration(AppTheme.gold, AppTheme.goldShadow),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.info_outline_rounded, color: AppTheme.brown, size: 28),
                                  title: Text(
                                    tr('settings.version'),
                                    style: const TextStyle(
                                      fontFamily: 'Round',
                                      color: AppTheme.darkBrown,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Text(
                                    appVersion,
                                    style: const TextStyle(
                                      fontFamily: 'Round',
                                      color: AppTheme.brown,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
                                ListTile(
                                  leading: const Icon(Icons.email_outlined, color: AppTheme.brown, size: 28),
                                  title: Text(
                                    tr('settings.contact'),
                                    style: const TextStyle(
                                      fontFamily: 'Round',
                                      color: AppTheme.darkBrown,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'contact@majormanuprod.com',
                                    style: TextStyle(
                                      color: AppTheme.brown,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: _launchEmail,
                                ),
                                Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
                                ListTile(
                                  leading: const Icon(Icons.description_outlined, color: AppTheme.brown, size: 28),
                                  title: Text(
                                    tr('settings.privacyPolicy'),
                                    style: const TextStyle(
                                      fontFamily: 'Round',
                                      color: AppTheme.darkBrown,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.open_in_new, color: AppTheme.brown, size: 20),
                                  onTap: _launchPrivacyPolicy,
                                ),
                                Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
                                ListTile(
                                  leading: const Icon(Icons.gavel_outlined, color: AppTheme.brown, size: 28),
                                  title: Text(
                                    tr('settings.termsOfService'),
                                    style: const TextStyle(
                                      fontFamily: 'Round',
                                      color: AppTheme.darkBrown,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.open_in_new, color: AppTheme.brown, size: 20),
                                  onTap: _launchTermsOfService,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                           Opacity(
                             opacity: _currentStage > 1 ? 1.0 : 0.5,
                             child: IgnorePointer(
                               ignoring: _currentStage <= 1,
                               child: BouncingScaleButton(
                                 onTap: () => _confirmResetCampaign(context),
                                 child: Container(
                                   decoration: BoxDecoration(
                                      color: _currentStage > 1 ? const Color(0xFFFFEBEE) : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _currentStage > 1 ? AppTheme.red : Colors.grey.shade400, 
                                        width: 3
                                      ),
                                   ), 
                                   child: ListTile(
                                     leading: Icon(
                                       Icons.refresh_rounded, 
                                       color: _currentStage > 1 ? AppTheme.red : Colors.grey
                                     ),
                                     title: Text(
                                       tr('settings.resetCampaign').toUpperCase(),
                                       style: TextStyle(
                                         fontFamily: 'Round',
                                         color: _currentStage > 1 ? AppTheme.red : Colors.grey,
                                         fontWeight: FontWeight.bold,
                                         fontSize: 16,
                                       ),
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                           ),
                            const SizedBox(height: 40),
                          
                          // Copyright
                          Center(
                            child: Text(
                              tr('settings.copyright'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title, 
    required bool value, 
    required IconData icon, 
    required Function(bool) onChanged,
    required Color color,
    required Color textColor,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: color, size: 28),
      title: Text(
        title, 
        style: TextStyle(
          fontFamily: 'Round', 
          color: textColor, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        )
      ),
      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppTheme.darkBrown;
        }
        return color;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppTheme.goldShadow;
        }
        return color.withValues(alpha: 0.3);
      }),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Round',
          fontSize: 20,
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          shadows: const [
             Shadow(color: Colors.white, offset: Offset(1,1), blurRadius: 0),
          ]
        ),
      ),
    );
  }

  BoxDecoration _itemDecoration(Color bgColor, Color borderColor) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 0,
        ),
      ],
    );
  }

  void _confirmResetCampaign(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          tr('settings.resetCampaignConfirmTitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Round',
            color: AppTheme.red,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        content: Text(
          tr('settings.resetCampaignConfirmMessage'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
            onPressed: () async {
              Navigator.pop(ctx);
              await PlayerPreferences.resetCampaign();
              if (context.mounted) {
                _loadSettings();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('settings.resetCampaignSuccess')),
                    backgroundColor: AppTheme.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              tr('settings.resetCampaignConfirm'),
              style: const TextStyle(fontFamily: 'Round', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@majormanuprod.com',
      query: 'subject=Word Train - Contact',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('settings.emailError')),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    // TODO: Remplacer par votre vraie URL
    final Uri url = Uri.parse('https://majormanuprod.com/privacy-policy');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('settings.linkError')),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _launchTermsOfService() async {
    // TODO: Remplacer par votre vraie URL
    final Uri url = Uri.parse('https://majormanuprod.com/terms-of-service');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('settings.linkError')),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }
}
