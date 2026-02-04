import 'package:flutter/material.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/bouncing_scale_button.dart';

class GameLetterGrid extends StatelessWidget {
  final List<String> shuffledLetters;
  final Function(String) onLetterTap;

  const GameLetterGrid({
    super.key,
    required this.shuffledLetters,
    required this.onLetterTap,
  });

  @override
  Widget build(BuildContext context) {
    final int count = shuffledLetters.length;
    final double letterSize = 64.0; 
    final double totalWidth = MediaQuery.of(context).size.width;
    final double center = totalWidth / 2;
    
    final int cols = (count / 2.0).ceil(); 
    
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(count, (index) {
           final bool isTop = index < cols;
           final int colIndex = index % cols; 
           
           final int rowCount = isTop ? cols : (count - cols);
           final double midIndex = (rowCount - 1) / 2.0;
           final double diff = colIndex - midIndex; 
           
           // Étalement horizontal
           final double xOffset = diff * (letterSize + 16); 
           
           // Calcul Y
           // Rangée du haut : 0. Rangée du bas : 74.
           final double yBase = isTop ? 0.0 : 74.0;
           
           // Courbure
           final double curveFactor = 1.5; 
           
           final double yCurve = isTop 
               ? (diff * diff) * curveFactor   
               : - (diff * diff) * curveFactor; 
           
           final letter = shuffledLetters[index];
           
           // Alternance des anneaux sur la 2ème rangée si le nombre de colonnes est pair (ex: 8 lettres) 
           bool hasRing = index % 2 == 0;
           if (!isTop && cols % 2 == 0) {
             hasRing = !hasRing;
           }
           
           return Positioned(
             left: center + xOffset - (letterSize / 2),
             top: yBase + yCurve, 
             child: BouncingScaleButton(
               onTap: () => onLetterTap(letter),
               showShadow: false,
               child: hasRing 
                  ? _buildRingLetter(letter, letterSize)
                  : _buildPlainLetter(letter, letterSize),
             ),
           );
        }),
      ),
    );
  }

  Widget _buildRingLetter(String letter, double size) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
         alignment: Alignment.center,
         children: [
            // 1. Bordure Extérieure Sombre
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.coinBorderDark,
                boxShadow: [
                   // Fort Halo blanc
                   BoxShadow(color: Colors.white.withValues(alpha: 0.75), blurRadius: 16, spreadRadius: 4), 
                   const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))
                ],
              ),
              padding: const EdgeInsets.all(1.5),
              child: Container(
                 // 2. Bord (Dégradé)
                 decoration: const BoxDecoration(
                   shape: BoxShape.circle,
                   gradient: LinearGradient(colors: [AppTheme.coinRimTop, AppTheme.coinRimBottom]),
                 ),
                 padding: const EdgeInsets.all(3.0),
                 child: Container(
                    // 3. Bordure Intérieure Sombre
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.coinBorderDark),
                    padding: const EdgeInsets.all(1.2),
                    child: Container(
                      // 4. Face
                       decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.levelSignFace),
                       alignment: Alignment.center,
                       child: Text(
                         letter,
                         style: TextStyle(
                           fontFamily: AppTheme.fontFamily,
                           fontSize: size * 0.45,
                           fontWeight: FontWeight.w900,
                           color: AppTheme.coinBorderDark,
                         ),
                       ),
                    ),
                 ),
              ),
            ),
         ],
      ),
    );
  }

  Widget _buildPlainLetter(String letter, double size) {
     return Container(
       width: size, height: size,
       alignment: Alignment.center,
       child: Text(
         letter,
         style: TextStyle(
           fontFamily: AppTheme.fontFamily,
           fontSize: size * 0.65, 
           fontWeight: FontWeight.w900,
           color: AppTheme.coinBorderDark,
         ),
       ),
     );
  }
}
