import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:word_riders/features/gameplay/models/character_anim_enums.dart';
import 'package:word_riders/features/ui/widgets/game/game_character.dart';
import 'package:word_riders/features/ui/widgets/game/race_track_geometry.dart';

class CampaignPreviewGame extends FlameGame {
  final double currentAnimationValue;
  final int minVisibleStage;
  final int maxVisibleStage;
  late GameCharacter _player;
  double? _pendingStage;

  bool _playerAdded = false;

  @override
  Color backgroundColor() => Colors.transparent;

  CampaignPreviewGame({
    required this.minVisibleStage,
    required this.maxVisibleStage,
    this.currentAnimationValue = 1.0,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _player = GameCharacter(
      characterType: CharacterType.player,
      size: Vector2(150, 150),
    );

    await add(_player);
    _playerAdded = true;
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
    if (_playerAdded) {
      if (playing) {
        // todo: revoir les animations ! idle : le player ne doit pas bouger.
        _player.startRiding();
      } else {
        _player.playIdleLoop();
      }
    }
  }

  // Écart vertical imposé entre les roues du vélo et la ligne de stages.
  // Aligné sur la géométrie de piste partagée : le joueur roule ainsi sur la
  // même ride line que la track peinte par GameBackground.
  static const double _gapAboveStageLine = kRaceTrackRideLineToStageLine;
  // Pixels transparents sous les roues dans le sprite du personnage.
  static const double _wheelInset = 10.0;
  // Léger enfoncement supplémentaire des roues sous la ride line (quelques
  // pixels), pour un rendu plus naturel.
  static const double _verticalNudge = 8.0;

  void _applyStage(double stage) {
    if (!_playerAdded) return;

    // X : géométrie fixe alignée sur les cercles d'étape (emplacements de 90px).
    // Centre de l'élément 0 = 45.0 (moitié de 90).
    final x = 45.0 + ((stage - minVisibleStage) * 90.0) - (_player.size.x / 2);

    // Y : le canvas remplit la piste, la ligne de stages est donc à size.y / 2.
    // On place les roues _gapAboveStageLine pixels au-dessus de cette ligne.
    final double stageLineY = size.y / 2;
    final double wheelsY = stageLineY - _gapAboveStageLine;
    final y = wheelsY - _player.size.y + _wheelInset + _verticalNudge;

    _player.position = Vector2(x, y);
  }
}
