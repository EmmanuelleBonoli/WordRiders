import 'dart:async';
import 'package:flutter/material.dart';

import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';

class LifeIndicator extends StatefulWidget {
  final VoidCallback? onLivesChanged;

  const LifeIndicator({super.key, this.onLivesChanged});

  @override
  State<LifeIndicator> createState() => LifeIndicatorState();
}

class LifeIndicatorState extends State<LifeIndicator> {
  int? _currentLives;
  Duration? _timeToNextLife;
  DateTime? _nextLifeTime;
  Timer? _lifeTimer;

  // Accesseur public pour permettre aux parents de connaître l'état sans gérer la logique
  int get currentLives => _currentLives ?? 5;

  @override
  void initState() {
    super.initState();
    _startLifeTimer();
  }

  void _startLifeTimer() {
    _loadLives();
    _lifeTimer?.cancel();
    _lifeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextLifeTime != null) {
        final now = DateTime.now();
        if (now.isAfter(_nextLifeTime!)) {
          // Temps écoulé, on synchronise avec le backend
          _loadLives();
        } else {
          // Mise à jour fluide locale
          if (mounted) {
            setState(() {
              _timeToNextLife = _nextLifeTime!.difference(now);
            });
          }
        }
      } else {
        // Vérification périodique si pas full
        if ((_currentLives ?? 5) < 5) {
           _loadLives();
        }
      }
    });
  }

  Future<void> reload() async {
    await _loadLives();
  }

  Future<void> _loadLives() async {
    final lives = await PlayerPreferences.getLives();
    final time = await PlayerPreferences.getTimeToNextLife();
    
    if (mounted) {
      setState(() {
        final oldLives = _currentLives;
        _currentLives = lives;
        _timeToNextLife = time;
        
        if (time != null) {
          _nextLifeTime = DateTime.now().add(time);
        } else {
          _nextLifeTime = null;
        }

        // Notifier le parent si le nombre de vies a changé
        if (oldLives != null && oldLives != lives) {
          widget.onLivesChanged?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _lifeTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "00:00";
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
          const Icon(Icons.favorite_rounded, color: AppTheme.red, size: 24),
          const SizedBox(width: 6),
          Text(
            '${_currentLives ?? 5}',
            style: const TextStyle(
              fontFamily: 'Round',
              fontSize: 20,
              color: AppTheme.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          if ((_currentLives ?? 5) < 5 && _timeToNextLife != null) ...[
            const SizedBox(width: 8),
            Text(
              _formatDuration(_timeToNextLife!),
              style: TextStyle(
                fontFamily: 'Round',
                fontSize: 14,
                color: AppTheme.brown.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
