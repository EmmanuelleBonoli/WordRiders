import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/settings/settings_container.dart';
import 'package:word_train/features/ui/widgets/settings/settings_section_title.dart';

class SettingsLanguageSection extends StatelessWidget {
  final int currentStage;
  final VoidCallback onSettingsChanged;

  const SettingsLanguageSection({
    super.key,
    required this.currentStage,
    required this.onSettingsChanged,
  });

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
                 onSettingsChanged(); 
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(title: tr('settings.language'), color: AppTheme.darkBrown),
        SettingsContainer(
          backgroundColor: AppTheme.tileFace,
          borderColor: AppTheme.tileShadow,
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
                dropdownColor: AppTheme.tileFace,
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
                    if (currentStage > 1) {
                      _confirmChangeLanguage(context, newLocale);
                    } else {
                      await context.setLocale(newLocale);
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
