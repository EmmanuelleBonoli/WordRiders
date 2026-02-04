import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class CoinIndicator extends StatefulWidget {
  const CoinIndicator({super.key});

  @override
  State<CoinIndicator> createState() => CoinIndicatorState();
}

class CoinIndicatorState extends State<CoinIndicator> {
  int _currentCoins = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coins = await PlayerPreferences.getCoins();
    if (mounted) {
      setState(() => _currentCoins = coins);
    }
  }

  Future<void> reload() async {
    await _loadCoins();
  }

  @override
  Widget build(BuildContext context) {
    const double depth = 4.0;
    const Color faceColor = AppTheme.goldButtonFace;
    const Color sideColor = AppTheme.goldButtonShadow;
    const Color highlightColor = AppTheme.goldButtonHighlight;

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Ombre/Side
          Positioned(
            top: depth,
            left: 0,
            right: 0,
            bottom: -depth,
            child: Container(
              decoration: BoxDecoration(
                color: sideColor,
                borderRadius: BorderRadius.circular(24),
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 2,
                  )
                ],
              ),
            ),
          ),
          // Face
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: faceColor,
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [highlightColor, faceColor],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                const SizedBox(width: 6),
                Text(
                  '$_currentCoins',
                  style: const TextStyle(
                    fontFamily: 'Round',
                    fontSize: 20,
                    color: AppTheme.brown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

           // Petit reflet glossy sur le haut
          Positioned(
            top: 4,
            left: 12,
            right: 12,
            height: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        ],
      ),
    );
  }
}
