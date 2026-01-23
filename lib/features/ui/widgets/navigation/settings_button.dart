import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/app_theme.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/settings'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.brown, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.settings_rounded,
            color: AppTheme.brown,
            size: 28,
          ),
        ),
      ),
    );
  }
}
