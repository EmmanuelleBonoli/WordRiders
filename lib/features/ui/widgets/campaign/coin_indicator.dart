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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brown, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
