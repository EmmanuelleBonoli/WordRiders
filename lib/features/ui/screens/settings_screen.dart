import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  bool sfxOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    musicOn = await PlayerProgress.isMusicEnabled();
    sfxOn = await PlayerProgress.isSfxEnabled();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
             child: Image.asset(
               'assets/images/background/menu_bg.png',
               fit: BoxFit.cover,
               alignment: Alignment.bottomCenter, // Focus on the bottom details
             ),
          ),
          
          // Overlay
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
                       // Custom Back Button
                       Container(
                         decoration: BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                           boxShadow: [
                             BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                           ],
                         ),
                         child: IconButton(
                           icon: const Icon(Icons.arrow_back),
                           color: theme.primaryColor,
                           onPressed: () => Navigator.pop(context),
                         ),
                       ),
                       Expanded(
                         child: Text(
                           tr('settings.title'),
                           textAlign: TextAlign.center,
                           style: theme.textTheme.headlineMedium?.copyWith(
                             color: theme.primaryColor,
                             fontWeight: FontWeight.bold,
                             shadows: [
                               Shadow(
                                 color: Colors.white,
                                 offset: Offset(0, 1),
                                 blurRadius: 2,
                               ),
                             ],
                           ),
                         ),
                       ),
                       const SizedBox(width: 48), // Balance for BackButton
                     ],
                   ),
                 ),
                 
                 Expanded(
                   child: Center(
                     child: Container(
                       constraints: const BoxConstraints(maxWidth: 600),
                       margin: const EdgeInsets.all(24),
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(
                         color: Colors.white.withValues(alpha: 0.85),
                         borderRadius: BorderRadius.circular(30),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withValues(alpha: 0.1),
                             blurRadius: 15,
                             spreadRadius: 2,
                           ),
                         ],
                       ),
                       child: ListView(
                        shrinkWrap: true,
                        children: [
                          _buildSectionTitle(theme, tr('settings.language')),
                          Container(
                            decoration: _itemDecoration(theme),
                            child: ListTile(
                              leading: Icon(Icons.language, color: theme.primaryColor),
                              title: Text(tr('settings.language'), style: theme.textTheme.bodyLarge),
                              trailing: DropdownButtonHideUnderline(
                                child: DropdownButton<Locale>(
                                  value: context.locale,
                                  dropdownColor: Colors.white,
                                  icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    DropdownMenuItem(
                                      value: const Locale('en'),
                                      child: Text('English', style: theme.textTheme.bodyMedium),
                                    ),
                                    DropdownMenuItem(
                                      value: const Locale('fr'),
                                      child: Text('Français', style: theme.textTheme.bodyMedium),
                                    ),
                                  ],
                                  onChanged: (newLocale) async {
                                    if (newLocale != null) {
                                      context.setLocale(newLocale);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle(theme, "Audio"),
                          Container(
                            decoration: _itemDecoration(theme),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  secondary: Icon(
                                    musicOn ? Icons.music_note : Icons.music_off,
                                    color: theme.primaryColor,
                                  ),
                                  title: Text(tr('settings.enableMusic'), style: theme.textTheme.bodyLarge),
                                  activeThumbColor: theme.colorScheme.secondary,
                                  value: musicOn,
                                  onChanged: (val) async {
                                    setState(() => musicOn = val);
                                    await PlayerProgress.setMusicEnabled(val);
                                  },
                                ),
                                Divider(height: 1, indent: 60, endIndent: 20, color: Colors.grey.withValues(alpha: 0.2)),
                                SwitchListTile(
                                  secondary: Icon(
                                    sfxOn ? Icons.volume_up : Icons.volume_off,
                                    color: theme.primaryColor,
                                  ),
                                  title: Text(tr('settings.enableSounds'), style: theme.textTheme.bodyLarge),
                                  activeThumbColor: theme.colorScheme.secondary,
                                  value: sfxOn,
                                  onChanged: (val) async {
                                    setState(() => sfxOn = val);
                                    await PlayerProgress.setSfxEnabled(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Reset Zone
                           Container(
                             decoration: _itemDecoration(theme).copyWith(
                               color: theme.colorScheme.error.withValues(alpha: 0.1),
                               border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                             ),
                             child: ListTile(
                               leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                               title: Text(
                                 tr('settings.resetCampaign'),
                                 style: theme.textTheme.bodyLarge?.copyWith(
                                   color: theme.colorScheme.error,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               onTap: () {
                                 // TODO: show confirmation
                               },
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

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  BoxDecoration _itemDecoration(ThemeData theme) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(
          color: theme.primaryColor.withValues(alpha: 0.05),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ],
    );
  }
}
