import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/premium_round_button.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SettingsButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PremiumRoundButton(
      icon: Icons.settings_rounded,
      onTap: onTap ?? () => context.push('/settings'),
      showHole: true,
      size: 64,
      iconGradient: const [AppTheme.coinRimTop, AppTheme.coinRimBottom],
    );
  }
}
