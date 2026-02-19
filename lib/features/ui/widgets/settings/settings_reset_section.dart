import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';

class SettingsResetSection extends StatelessWidget {
  final int currentStage;
  final VoidCallback onResetComplete;

  const SettingsResetSection({
    super.key,
    required this.currentStage,
    required this.onResetComplete,
  });

  void _confirmResetCampaign(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          context.tr('settings.resetCampaignConfirmTitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Round',
            color: AppTheme.red,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        content: Text(
          context.tr('settings.resetCampaignConfirmMessage'),
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
              context.tr('settings.cancel'),
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
                onResetComplete();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('settings.resetCampaignSuccess')),
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
              context.tr('settings.resetCampaignConfirm'),
              style: const TextStyle(fontFamily: 'Round', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: currentStage > 1 ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: currentStage <= 1,
        child: BouncingScaleButton(
          onTap: () => _confirmResetCampaign(context),
          child: Container(
            decoration: BoxDecoration(
               color: currentStage > 1 ? AppTheme.surfaceLightRed : Colors.grey.shade200,
               borderRadius: BorderRadius.circular(16),
               border: Border.all(
                 color: currentStage > 1 ? AppTheme.red : Colors.grey.shade400, 
                 width: 3
               ),
            ), 
            child: ListTile(
              leading: Icon(
                Icons.refresh_rounded, 
                color: currentStage > 1 ? AppTheme.red : Colors.grey
              ),
              title: Text(
                context.tr('settings.resetCampaign').toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Round',
                  color: currentStage > 1 ? AppTheme.red : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
