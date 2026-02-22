import 'package:flutter/material.dart';
import 'package:word_riders/features/gameplay/controllers/game_controller.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/ui/widgets/common/button/premium_round_button.dart';
import 'package:word_riders/features/ui/widgets/common/leaf_background.dart';

class GameBonusPanel extends StatelessWidget {
  final GameController controller;

  const GameBonusPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.isCampaign) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 35,
          left: -50,
          right: -50,
          height: 3000,
          child: Container(
            color: AppTheme.headerWood,
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 200, 
              width: double.infinity,
              child: LeafBackground(
                backgroundColor: Colors.transparent,
                leafColor: Colors.white.withValues(alpha: 0.12),
                leafCount: 30,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),

        // Background line
        Positioned(
          top: 32,
          left: 0,
          right: 0,
          height: 6,
          child: Container(
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: AppTheme.coinBorderDark, width: 1.5)),
              gradient: LinearGradient(
                colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
                begin: Alignment.topCenter, end: Alignment.bottomCenter
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
          ),
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBonusButton(
              context: context,
              icon: Icons.text_increase_rounded, // Lettre en plus
              count: controller.bonusExtraLetterCount,
              isUsed: controller.extraLetterUsed,
              onTap: controller.useBonusExtraLetter,
              colorOptions: const [Colors.orange, Colors.deepOrange],
            ),
            _buildBonusButton(
              context: context,
              icon: Icons.double_arrow_rounded, // Distance x2
              count: controller.bonusDoubleDistanceCount,
              isUsed: controller.isNextWordDistanceDoubled,
              onTap: controller.useBonusDoubleDistance,
              colorOptions: const [Colors.blue, Colors.indigo],
            ),
            _buildBonusButton(
              context: context,
              icon: Icons.ac_unit_rounded, // Gel du rival
              count: controller.bonusFreezeRivalCount,
              isUsed: controller.isRivalFrozen,
              onTap: controller.useBonusFreezeRival,
              colorOptions: const [Colors.cyan, Colors.blueAccent],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBonusButton({
    required BuildContext context,
    required IconData icon,
    required int count,
    required bool isUsed,
    required VoidCallback onTap,
    required List<Color> colorOptions,
  }) {
    final isDisabled = count <= 0 || isUsed;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        PremiumRoundButton(
          icon: icon,
          onTap: isDisabled ? () {} : onTap,
          size: 64,
          showHole: false,
          faceGradient: isDisabled ? const [Colors.grey, Colors.blueGrey] : colorOptions,
          iconGradient: const [Colors.white, Colors.white70],
        ),
        if (count > 0 && !isUsed)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Round',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
