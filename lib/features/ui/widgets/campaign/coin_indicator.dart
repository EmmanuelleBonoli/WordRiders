import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/resource_badge.dart';

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
    return ResourceBadge(
      imageAsset: 'assets/images/indicators/coin.png',
      content: Text(
        '$_currentCoins',
        style: const TextStyle(
          fontFamily: 'Round',
          fontSize: 18,
          height: 1.2, 
          color: AppTheme.darkBrown,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
