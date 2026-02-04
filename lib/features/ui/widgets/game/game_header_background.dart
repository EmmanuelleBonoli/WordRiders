import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class GameHeaderBackground extends StatelessWidget {
  const GameHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.headerWood,
      child: Stack(
        children: [
           // Motifs nature
           // --- GAUCHE ---
           Positioned(top: MediaQuery.of(context).padding.top + 5, left: 10, child: Transform.rotate(angle: -0.5, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.15), size: 28))),
           Positioned(top: MediaQuery.of(context).padding.top + 28, left: 45, child: Transform.rotate(angle: 0.8, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.1), size: 18))),
           Positioned(top: MediaQuery.of(context).padding.top + 12, left: 80, child: Transform.rotate(angle: 2.1, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.12), size: 34))),
           Positioned(top: MediaQuery.of(context).padding.top + 35, left: 120, child: Transform.rotate(angle: -1.2, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.15), size: 22))),

           // --- DROITE ---
           Positioned(top: MediaQuery.of(context).padding.top + 8, right: 20, child: Transform.rotate(angle: 0.4, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.12), size: 30))),
           Positioned(top: MediaQuery.of(context).padding.top + 32, right: 60, child: Transform.rotate(angle: -2.0, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.1), size: 20))),
           Positioned(top: MediaQuery.of(context).padding.top + 5, right: 90, child: Transform.rotate(angle: 1.5, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.15), size: 26))),
           
           // --- CENTRE ---
           Positioned(top: MediaQuery.of(context).padding.top + 15, left: 160, child: Transform.rotate(angle: -0.2, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.08), size: 38))),
           Positioned(top: MediaQuery.of(context).padding.top + 25, right: 150, child: Transform.rotate(angle: 0.5, child: Icon(Icons.eco_rounded, color: Colors.white.withValues(alpha: 0.1), size: 24))),

           // Ligne de bordure inférieure (Style anneau de bouton)
           Align(
             alignment: Alignment.bottomCenter,
             child: Container(
               height: 7, // 1.5 bordure + 4.0 or + 1.5 bordure
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
