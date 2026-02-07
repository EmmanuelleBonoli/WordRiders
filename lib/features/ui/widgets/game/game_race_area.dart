import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'player_component.dart';
import 'rival_component.dart';

class GameRaceArea extends StatefulWidget {
  final bool isCampaign;

  const GameRaceArea({
    super.key, 
    required this.isCampaign,
  });

  @override
  State<GameRaceArea> createState() => _GameRaceAreaState();
}

class _GameRaceAreaState extends State<GameRaceArea> {
  late final RaceGame _game;

  @override
  void initState() {
    super.initState();
    _game = RaceGame(isCampaign: widget.isCampaign);
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}

class RaceGame extends FlameGame {
  final bool isCampaign;
  
  late Player _player;
  Rival? _rival; 

  RaceGame({required this.isCampaign});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configuration Rival
    if (isCampaign) {
      _rival = Rival()..position = Vector2(-1000, -1000);
      _rival!.scale = Vector2.all(0.9);
      add(_rival!);
    }

    // Configuration Joueur
    _player = Player()..position = Vector2(-1000, -1000);
    _player.scale = Vector2.all(0.9);
    add(_player);
    
    // Forcer le positionnement initial maintenant que les composants sont créés et que la taille est disponible
    // Si la taille est (0,0), ils restent hors écran jusqu'au premier redimensionnement.
    _updatePositions(size);
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Positionner uniquement si le jeu est entièrement chargé (les composants existent)
    if (isLoaded) {
       _updatePositions(size);
    }
  }

  void _updatePositions(Vector2 gameSize) {
    if (isCampaign) {
       // Mode Duel
       _player.position = Vector2(10, gameSize.y * 0.75 - 50);
       _rival?.position = Vector2(10, gameSize.y * 0.25 - 50);
    } else {
       // Mode Solo
       _player.position = Vector2(10, gameSize.y * 0.75 - 50); 
    }
  }
}
