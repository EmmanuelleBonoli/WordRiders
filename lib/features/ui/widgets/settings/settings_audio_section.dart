import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/settings/settings_container.dart';
import 'package:word_train/features/ui/widgets/settings/settings_section_title.dart';

class SettingsAudioSection extends StatelessWidget {
  final bool musicOn;
  final bool sfxOn;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<bool> onSfxChanged;

  const SettingsAudioSection({
    super.key,
    required this.musicOn,
    required this.sfxOn,
    required this.onMusicChanged,
    required this.onSfxChanged,
  });

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
          return AppTheme.tileShadow;
        }
        return color.withValues(alpha: 0.3);
      }),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionTitle(title: "AUDIO", color: AppTheme.darkBrown),
        SettingsContainer(
          backgroundColor: AppTheme.tileFace,
          borderColor: AppTheme.tileShadow,
          child: Column(
            children: [
              _buildSwitchTile(
                title: tr('settings.enableMusic'),
                value: musicOn,
                icon: musicOn ? Icons.music_note_rounded : Icons.music_off_rounded,
                color: AppTheme.tileShadow,
                textColor: AppTheme.darkBrown,
                onChanged: (val) async {
                  onMusicChanged(val);
                  await PlayerPreferences.setMusicEnabled(val);
                },
              ),
              Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
              _buildSwitchTile(
                title: tr('settings.enableSounds'),
                value: sfxOn,
                icon: sfxOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: AppTheme.tileShadow,
                textColor: AppTheme.darkBrown,
                onChanged: (newValue) async {
                  onSfxChanged(newValue);
                  await PlayerPreferences.setSfxEnabled(newValue);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
