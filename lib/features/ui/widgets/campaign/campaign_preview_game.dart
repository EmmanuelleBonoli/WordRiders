import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/ui/widgets/game/components/player_component.dart';

/// Petit FlameGame utilisé pour prévisualiser le player sur l'écran de progression
class CampaignPreviewGame extends FlameGame {
  final double currentAnimationValue;
  final int minVisibleStage;
  final int maxVisibleStage;
  late Player _player;
  double? _pendingStage;

  bool _playerAdded = false;
  bool _shouldPlay = false;

  @override
  Color backgroundColor() => const Color(0x00000000); 

  CampaignPreviewGame({
    required this.minVisibleStage,
    required this.maxVisibleStage,
    this.currentAnimationValue = 1.0,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _player = Player(debug: false); 
    _player.size = Vector2(Player.rabbitWidth, Player.rabbitWidth);
    await add(_player);
    _playerAdded = true;

    // Appliquer l'état en attente
    if (_shouldPlay) {
      _player.isPlaying = true;
    }

    if (_pendingStage != null) {
      _applyStage(_pendingStage!);
      _pendingStage = null;
    } 
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_playerAdded) return;
    
    if (_pendingStage != null) {
      _applyStage(_pendingStage!);
      _pendingStage = null;
    }
  }

  void setStage(double stage) {
    if (!_playerAdded || size.x == 0) {
      _pendingStage = stage;
      return;
    }
    _applyStage(stage);
  }

  void setPlaying(bool playing) {
    _shouldPlay = playing;
    if (_playerAdded) {
      _player.isPlaying = playing;
    }
  }

  void _applyStage(double stage) {
    if (!_playerAdded) return;

    // Use fixed geometry matching the Stage Circles (90px slots)
    // Item 0 Center = 45.0 (half of 90)
    // Spacing = 90.0
    final x = 45.0 + ((stage - minVisibleStage) * 90.0) - (_player.size.x / 2);

    // Monter le joueur de 50px
    final y = (size.y / 2) - (_player.size.y / 2) - 50;

    _player.position = Vector2(x, y);
  }
}
