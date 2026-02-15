import 'package:flutter/material.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/premium_round_button.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PremiumRoundButton(
      icon: Icons.arrow_back_ios_new_rounded,
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      size: 64,
      showHole: false,
      iconGradient: const [AppTheme.coinRimTop, AppTheme.coinRimBottom],
    );
  }
}
