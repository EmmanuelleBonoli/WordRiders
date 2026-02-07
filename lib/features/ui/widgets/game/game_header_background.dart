import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/graphics/leaf_background.dart';

class GameHeaderBackground extends StatelessWidget {
  const GameHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LeafBackground(
      backgroundColor: AppTheme.headerWood,
      leafColor: Colors.white.withValues(alpha: 0.12),
      leafCount: 15,
      child: Stack(
        children: [

           // Ligne de bordure inférieure (Style anneau de bouton)
           Align(
             alignment: Alignment.bottomCenter,
             child: Container(
               height: 7,
               decoration: const BoxDecoration(
                 border: Border.symmetric(
                    horizontal: BorderSide(color: AppTheme.coinBorderDark, width: 1.5),
                 ),
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom], 
                 ),
                 boxShadow: [
                   BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                 ]
               ),
             ),
           ),
        ],
      ),
    );
  }
}
