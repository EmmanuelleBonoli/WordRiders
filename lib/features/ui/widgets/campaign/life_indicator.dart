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
          // Mise à jour locale
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
    const double depth = 4.0;
    const Color faceColor = AppTheme.woodBoard; 
    const Color sideColor = AppTheme.woodBoardShadow;
    const Color highlightColor = AppTheme.woodBoardHighlight;
    
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
                const Icon(Icons.favorite_rounded, color: AppTheme.red, size: 24),
                const SizedBox(width: 6),
                Text(
                  '${_currentLives ?? 5}',
                  style: const TextStyle(
                    fontFamily: 'Round',
                    fontSize: 20,
                    color: AppTheme.brown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if ((_currentLives ?? 5) < 5 && _timeToNextLife != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatDuration(_timeToNextLife!),
                      style: const TextStyle(
                        fontFamily: 'Round',
                        fontSize: 14,
                        color: AppTheme.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
