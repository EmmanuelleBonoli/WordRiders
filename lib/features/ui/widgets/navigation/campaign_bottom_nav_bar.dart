import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class CampaignBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CampaignBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.tileFace,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBrown.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
    
          final selectedWidth = totalWidth * 0.44;
          final unselectedWidth = totalWidth * 0.28;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNavItem(0, Icons.store, selectedWidth, unselectedWidth),
              _buildNavItem(1, Icons.videogame_asset, selectedWidth, unselectedWidth),
              _buildNavItem(2, Icons.emoji_events, selectedWidth, unselectedWidth),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    double selectedWidth,
    double unselectedWidth,
  ) {
    final isSelected = index == selectedIndex;
    final width = isSelected ? selectedWidth : unselectedWidth;
    
    final double height = isSelected ? 90.0 : 70.0;
    

    final double iconSize = isSelected ? 60.0 : 40.0;
    
    final Decoration decoration = isSelected 
        ? BoxDecoration(
             gradient: const LinearGradient(
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
               colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom],
             ),
             borderRadius: BorderRadius.circular(20),
             border: Border.all(color: AppTheme.coinBorderDark, width: 2),
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withValues(alpha: 0.3),
                 offset: const Offset(0, 4),
                 blurRadius: 4,
               ),
             ],
           ) 
        : BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
               colors: [
                 AppTheme.coinRimTop.withValues(alpha: 0),
                 AppTheme.coinRimBottom.withValues(alpha: 0)
               ],
             ),
             borderRadius: BorderRadius.circular(20),
             border: Border.all(
               color: AppTheme.coinBorderDark.withValues(alpha: 0),
               width: 2
             ),
             boxShadow: [
               BoxShadow(
                 color: Colors.transparent,
                 offset: const Offset(0, 4),
                 blurRadius: 4,
               ),
             ],
           );

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: width,
        height: 80,
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
           duration: const Duration(milliseconds: 300),
           curve: Curves.easeOutBack,
           height: height,
           width: width - 4,
           margin: const EdgeInsets.only(bottom: 5),
           decoration: decoration,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(
                 icon,
                 size: iconSize,
                 color: AppTheme.darkBrown,
               )
             ],
           ),
      ),
      ),
    );
  }
}
