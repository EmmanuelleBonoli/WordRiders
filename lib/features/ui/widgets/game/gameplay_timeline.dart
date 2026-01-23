import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class GameplayTimeline extends StatelessWidget {
  final double progress;

  const GameplayTimeline({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Calcule la position horizontale du joueur en fonction de la progression
          final playerPos = width * progress;
          
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 48,
                alignment: Alignment.center,
                child: Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.brown, width: 2),
                  ),
                ),
              ),
              
              Positioned(
                right: 0,
                top: 0, bottom: 0, 
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/characters/finish_flag.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ), 
              ),

              Positioned(
                left: width * 0.5, 
                top: 0, bottom: 0, 
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/characters/fox_head.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
               Positioned(
                left: playerPos.clamp(0, width - 40), 
                top: 0, bottom: 0, 
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/characters/rabbit_head.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
