import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_container.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_section_title.dart';

class SettingsAudioSection extends StatelessWidget {
  final bool musicOn;
  final bool sfxOn;
  final double musicVolume;
  final double sfxVolume;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<bool> onSfxChanged;
  final ValueChanged<double> onMusicVolumeChanged;
  final ValueChanged<double> onSfxVolumeChanged;

  const SettingsAudioSection({
    super.key,
    required this.musicOn,
    required this.sfxOn,
    required this.musicVolume,
    required this.sfxVolume,
    required this.onMusicChanged,
    required this.onSfxChanged,
    required this.onMusicVolumeChanged,
    required this.onSfxVolumeChanged,
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
          fontWeight: FontWeight.bold,
        ),
      ),
      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return AppTheme.darkBrown;
        return color;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return AppTheme.tileShadow;
        return color.withValues(alpha: 0.3);
      }),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildVolumeSlider({
    required double volume,
    required bool enabled,
    required ValueChanged<double> onChanged,
    required Future<void> Function(double) onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.volume_down_rounded,
            color: enabled ? AppTheme.tileShadow : AppTheme.tileShadow.withValues(alpha: 0.3),
            size: 20,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: enabled ? AppTheme.darkBrown : AppTheme.tileShadow.withValues(alpha: 0.3),
                inactiveTrackColor: AppTheme.tileShadow.withValues(alpha: 0.2),
                thumbColor: enabled ? AppTheme.darkBrown : AppTheme.tileShadow.withValues(alpha: 0.3),
                overlayColor: AppTheme.darkBrown.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: volume,
                min: 0.0,
                max: 1.0,
                onChanged: enabled ? onChanged : null,
                onChangeEnd: enabled ? onSave : null,
              ),
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            color: enabled ? AppTheme.tileShadow : AppTheme.tileShadow.withValues(alpha: 0.3),
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(title: context.tr('settings.audio'), color: AppTheme.darkBrown),
        SettingsContainer(
          backgroundColor: AppTheme.tileFace,
          borderColor: AppTheme.tileShadow,
          child: Column(
            children: [
              _buildSwitchTile(
                title: context.tr('settings.enableMusic'),
                value: musicOn,
                icon: musicOn ? Icons.music_note_rounded : Icons.music_off_rounded,
                color: AppTheme.tileShadow,
                textColor: AppTheme.darkBrown,
                onChanged: (val) async {
                  onMusicChanged(val);
                  await PlayerPreferences.setMusicEnabled(val);
                },
              ),
              _buildVolumeSlider(
                volume: musicVolume,
                enabled: musicOn,
                onChanged: onMusicVolumeChanged,
                onSave: PlayerPreferences.setMusicVolume,
              ),
              Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
              _buildSwitchTile(
                title: context.tr('settings.enableSounds'),
                value: sfxOn,
                icon: sfxOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: AppTheme.tileShadow,
                textColor: AppTheme.darkBrown,
                onChanged: (val) async {
                  onSfxChanged(val);
                  await PlayerPreferences.setSfxEnabled(val);
                },
              ),
              _buildVolumeSlider(
                volume: sfxVolume,
                enabled: sfxOn,
                onChanged: onSfxVolumeChanged,
                onSave: PlayerPreferences.setSfxVolume,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
