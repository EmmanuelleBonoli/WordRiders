import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/player_component.dart';
import 'components/rival_component.dart';

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
  Rival? _rival; // Rival est nullable car absent en training

  RaceGame({required this.isCampaign});

// Nécessaire pour que le background soit transparent
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

   // SETUP RENARD (Rival) - Seulement en campagne
    if (isCampaign) {
      _rival = Rival();
      _rival!.scale = Vector2.all(0.9);
      add(_rival!);
    }

    // SETUP LAPIN (Player) - Toujours présent
    _player = Player();
    _player.scale = Vector2.all(0.9);
    add(_player);
    
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isMounted) return;

    // Positionnement dynamique
    // On centre le lapin verticalement s'il est seul, ou on le met en haut s'il y a le renard
    if (isCampaign) {
       // Mode Duel : 2 Pistes
       _player.position = Vector2(10, size.y * 0.75 - 50);
       _rival?.position = Vector2(10, size.y * 0.25 - 50);
    } else {
       // Mode Solo : Lapin au milieu (ou un peu plus bas pour être sur le sol)
       _player.position = Vector2(10, size.y * 0.75 - 50); 
    }
  }
}
