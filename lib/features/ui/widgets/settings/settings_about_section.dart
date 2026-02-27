import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_container.dart';
import 'package:word_riders/features/ui/widgets/settings/settings_section_title.dart';
import 'package:word_riders/features/ui/widgets/common/app_snackbar.dart';

class SettingsAboutSection extends StatelessWidget {
  final String appVersion;

  const SettingsAboutSection({
    super.key,
    required this.appVersion,
  });

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@majormanuprod.com',
      query: 'subject=Word Riders - Contact',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: context.tr('settings.emailError'),
          isError: true,
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://majormanuprod.com/privacy-policy');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: context.tr('settings.linkError'),
          isError: true,
        );
      }
    }
  }

  Future<void> _launchTermsOfService(BuildContext context) async {
    final Uri url = Uri.parse('https://majormanuprod.com/terms-of-service');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: context.tr('settings.linkError'),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(title: context.tr('settings.aboutTitle'), color: AppTheme.darkBrown),
        SettingsContainer(
          backgroundColor: AppTheme.tileFace,
          borderColor: AppTheme.tileShadow,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppTheme.tileShadow, size: 28),
                title: Text(
                  context.tr('settings.version'),
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
                leading: const Icon(Icons.email_outlined, color: AppTheme.tileShadow, size: 28),
                title: Text(
                  context.tr('settings.contact'),
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
                onTap: () => _launchEmail(context),
              ),
              Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: AppTheme.tileShadow, size: 28),
                title: Text(
                  context.tr('settings.privacyPolicy'),
                  style: const TextStyle(
                    fontFamily: 'Round',
                    color: AppTheme.darkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.open_in_new, color: AppTheme.brown, size: 20),
                onTap: () => _launchPrivacyPolicy(context),
              ),
              Divider(height: 2, thickness: 2, color: AppTheme.brown.withValues(alpha: 0.2)),
              ListTile(
                leading: const Icon(Icons.gavel_outlined, color: AppTheme.tileShadow, size: 28),
                title: Text(
                  context.tr('settings.termsOfService'),
                  style: const TextStyle(
                    fontFamily: 'Round',
                    color: AppTheme.darkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.open_in_new, color: AppTheme.brown, size: 20),
                onTap: () => _launchTermsOfService(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
