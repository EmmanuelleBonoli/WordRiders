import 'dart:async';
import 'package:flutter/material.dart';

import 'package:word_train/features/gameplay/services/player_preferences.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import 'package:word_train/features/ui/widgets/common/resource_badge.dart';

class LifeIndicator extends StatefulWidget {
  final VoidCallback? onLivesChanged;

  const LifeIndicator({super.key, this.onLivesChanged});

  @override
  State<LifeIndicator> createState() => LifeIndicatorState();
}

class LifeIndicatorState extends State<LifeIndicator> {
  int? _currentLives;
  Timer? _lifeTimer;
  Duration? _timeToNextLife;
  DateTime? _nextLifeTime;
  DateTime? _unlimitedUntil;

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
      final now = DateTime.now();

      // Gestion des Vies Illimitées
      if (_unlimitedUntil != null) {
        if (now.isAfter(_unlimitedUntil!)) {
           // Expiré
           _loadLives(); 
        } else {
           // Mise à jour de l'UI
           if (mounted) setState(() {});
        }
        return; // Priorité à l'affichage illimité
      }

      // Gestion de la Régénération Normale
      if (_nextLifeTime != null) {
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
    final unlimited = await PlayerPreferences.getUnlimitedLivesExpiration();
    
    if (mounted) {
      setState(() {
        final oldLives = _currentLives;
        _currentLives = lives;
        _timeToNextLife = time;
        _unlimitedUntil = (unlimited != null && unlimited.isAfter(DateTime.now())) ? unlimited : null;
        
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
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlimited = _unlimitedUntil != null;
    Duration? remainingUnlimited;
    if (isUnlimited) {
       remainingUnlimited = _unlimitedUntil!.difference(DateTime.now());
    }

    return ResourceBadge(
      imageAsset: 'assets/images/indicators/heart.png',
      imageSize: 56, 
      overlayIcon: isUnlimited 
          ? Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.all_inclusive, color: Colors.purple, size: 20),
            )
          : null,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUnlimited)
            Text(
              _formatDuration(remainingUnlimited!),
              style: const TextStyle(
                fontFamily: 'Round',
                fontSize: 16,
                height: 1.2, 
                color: Colors.purple,
                fontWeight: FontWeight.w900,
              ),
            )
          else ...[
            Text(
              '${_currentLives ?? 5}',
              style: const TextStyle(
                fontFamily: 'Round',
                fontSize: 18,
                height: 1.2, 
                color: AppTheme.darkBrown,
                fontWeight: FontWeight.w900,
              ),
            ),
            if ((_currentLives ?? 5) < 5 && _timeToNextLife != null) ...[
              const SizedBox(width: 6),
              Text(
                _formatDuration(_timeToNextLife!),
                style: const TextStyle(
                  fontFamily: 'Round',
                  fontSize: 14,
                  color: AppTheme.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
