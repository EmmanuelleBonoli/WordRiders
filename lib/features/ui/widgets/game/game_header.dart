import 'package:flutter/material.dart';
import 'package:word_train/features/ui/widgets/game/gameplay_timeline.dart';
import 'package:word_train/features/ui/widgets/navigation/app_back_button.dart';
import 'package:word_train/features/ui/widgets/navigation/settings_button.dart';

class GameHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final bool showFox;
  final double rabbitProgress;
  final double foxProgress;

  const GameHeader({
    super.key,
    required this.onBack,
    required this.onSettings,
    required this.showFox,
    required this.rabbitProgress,
    required this.foxProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
           AppBackButton(onPressed: onBack),
           const SizedBox(width: 12),
           
           Expanded(
             child: GameplayTimeline(
               showFox: showFox,
               rabbitProgress: rabbitProgress,
               foxProgress: foxProgress, 
             ),
           ),
           
           const SizedBox(width: 12),
           SettingsButton(onTap: onSettings),
        ],
      ),
    );
  }
}
