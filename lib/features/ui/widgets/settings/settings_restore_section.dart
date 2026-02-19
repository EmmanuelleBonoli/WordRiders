import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_riders/features/gameplay/services/iap_service.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/bouncing_scale_button.dart';

class SettingsRestoreSection extends StatefulWidget {
  const SettingsRestoreSection({super.key});

  @override
  State<SettingsRestoreSection> createState() => _SettingsRestoreSectionState();
}

class _SettingsRestoreSectionState extends State<SettingsRestoreSection> {
  bool _isLoading = false;

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    
    try {
      await IapService.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('settings.restoreStarted')),
            backgroundColor: AppTheme.brown,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BouncingScaleButton(
      onTap: () { if (!_isLoading) _handleRestore(); },
      child: Container(
        decoration: BoxDecoration(
           color: AppTheme.tileFace,
           borderRadius: BorderRadius.circular(16),
           border: Border.all(
             color: AppTheme.brown, 
             width: 3
           ),
        ), 
        child: ListTile(
          leading: _isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.brown))
              : const Icon(
                  Icons.restore_rounded, 
                  color: AppTheme.brown,
                  size: 28,
                ),
          title: Text(
            context.tr('settings.restorePurchases').toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Round',
              color: AppTheme.brown,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
