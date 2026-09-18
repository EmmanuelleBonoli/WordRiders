import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game_character.dart';
import 'package:word_riders/features/gameplay/models/character_anim_enums.dart';

class GameRaceArea extends StatefulWidget {
  final bool isCampaign;
  final double rabbitProgress;
  final double foxProgress;
  final bool isGameOver;
  final bool isPlayerWinner;
  final double smoothScrollOffset;

  /// Ordonnée de la ligne de roulage dans le repère local du canvas Flame
  /// (déjà convertie depuis le repère écran par game_screen, via la géométrie
  /// de piste partagée). Les roues du joueur reposent dessus.
  final double rideLineLocalY;

  const GameRaceArea({
    super.key,
    required this.isCampaign,
    required this.rabbitProgress,
    required this.foxProgress,
    required this.isGameOver,
    required this.isPlayerWinner,
    required this.smoothScrollOffset,
    required this.rideLineLocalY,
  });

  @override
  State<GameRaceArea> createState() => _GameRaceAreaState();
}

class _GameRaceAreaState extends State<GameRaceArea> {
  late final RaceGame _game;

  @override
  void initState() {
    super.initState();
    _game = RaceGame(
      isCampaign: widget.isCampaign,
      rideLineLocalY: widget.rideLineLocalY,
    );
  }

  @override
  void didUpdateWidget(GameRaceArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    // La ligne de roulage change après la première mesure de la zone de course
    // (et sur redimensionnement) : la répercuter immédiatement.
    if (oldWidget.rideLineLocalY != widget.rideLineLocalY) {
      _game.setRideLine(widget.rideLineLocalY);
    }

    // Pousser les nouvelles valeurs dans Flame à chaque changement
    if (oldWidget.rabbitProgress != widget.rabbitProgress ||
        oldWidget.foxProgress != widget.foxProgress ||
        oldWidget.isGameOver != widget.isGameOver ||
        oldWidget.smoothScrollOffset != widget.smoothScrollOffset) {
      _game.updateProgress(
        widget.rabbitProgress,
        widget.foxProgress,
        widget.isGameOver,
        widget.isPlayerWinner,
        widget.smoothScrollOffset,
        MediaQuery.of(context).size.width,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le fond est géré au niveau de game_screen.dart (plein écran).
    // GameRaceArea affiche uniquement les personnages Flame sur fond transparent.
    return GameWidget(game: _game);
  }
}

class RaceGame extends FlameGame {
  final bool isCampaign;

  late GameCharacter _player;
  GameCharacter? _rival;

  double _rabbitProgress = 0.0;
  double _foxProgress = 0.0;
  double _prevRabbitProgress = 0.0;
  bool _isGameOver = false;
  double _scrollOffset = 0.0;
  double _screenWidth = 0.0;

  // Ligne de roulage partagée (repère local du canvas). 0 tant que la zone de
  // course n'a pas été mesurée : on retombe alors sur l'ancien ratio.
  double _rideLineLocalY;

  double _playerY = 0.0;

  // Durée d'animation run après qu'il a physiquement cessé de bouger
  // (Le ressort s'occupe de la durée de progression)
  static const double _runDurationAfterWord = 0.4;
  double _runTimer = 0.0;

  static const double _spriteSize = 120.0 * 0.9;

  // Écart vertical entre la voie du rival et celle du joueur : le rival court
  // presque à hauteur du joueur, juste un très léger décalage vertical.
  static const double _rivalLaneGap = 15.0;

  // Léger enfoncement des roues sous la ride line (quelques pixels), pour un
  // rendu plus naturel. S'applique au joueur comme au rival.
  static const double _rideLineVerticalNudge = 8.0;

  RaceGame({required this.isCampaign, required double rideLineLocalY})
    : _rideLineLocalY = rideLineLocalY;

  /// Met à jour la ligne de roulage et repositionne aussitôt les personnages.
  void setRideLine(double y) {
    _rideLineLocalY = y;
    if (isLoaded) {
      _updatePositions(size);
    }
  }

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (isCampaign) {
      _rival = GameCharacter(
        characterType: CharacterType.rival,
        size: Vector2.all(120.0),
      )..position = Vector2(-1000, -1000);
      _rival!.scale = Vector2.all(0.9);
      add(_rival!);
    }

    _player = GameCharacter(
      characterType: CharacterType.player,
      size: Vector2.all(120.0),
    )..position = Vector2(-1000, -1000);
    _player.scale = Vector2.all(0.9);
    add(_player);

    _updatePositions(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _updatePositions(size);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // La position X est directement modifiée dans _updatePositions car le lissage
    // physique avec inertie est géré par la progression animée (GameScreen).

    // --- Timer run → idle ---
    if (_runTimer > 0) {
      _runTimer -= dt;
      if (_runTimer <= 0 && !_isGameOver) {
        _player.playIdleLoop();
      }
    }
  }

  /// Appelé depuis Flutter à chaque changement de progression ou de scroll lissé.
  void updateProgress(
    double rabbit,
    double fox,
    bool isGameOver,
    bool isPlayerWinner,
    double scrollOffset,
    double screenWidth,
  ) {
    final bool wasGameOver = _isGameOver;

    _prevRabbitProgress = _rabbitProgress;
    _rabbitProgress = rabbit;
    _foxProgress = fox;
    _isGameOver = isGameOver;
    _scrollOffset = scrollOffset;
    _screenWidth = screenWidth;

    // Déclencher l'animation run si le joueur a avancé (mot validé)
    if (_rabbitProgress > _prevRabbitProgress) {
      _player.startRiding();
      _runTimer = _runDurationAfterWord;
    }

    // On ne déclenche victory/defeat qu'une fois, au moment où la partie bascule
    if (_isGameOver && !wasGameOver) {
      if (isPlayerWinner) {
        _player.triggerVictory();
        _rival?.triggerDefeat();
      } else {
        _player.triggerDefeat();
        _rival?.triggerVictory();
      }
    }

    _updatePositions(size);
  }

  void _updatePositions(Vector2 gameSize) {
    if (gameSize.x == 0 || gameSize.y == 0) return;

    final double screenW = _screenWidth > 0 ? _screenWidth : gameSize.x;
    final double centerX = screenW / 2 - _spriteSize / 2;
    // La const 0.04 (était 0.13) défini que 4% du niveau représente le centre de l'écran.
    // La course sera donc >3x plus longue et >3x plus rapide visuellement en pixels.
    final double worldScale = centerX / 0.04;

    // Position d'arrivée à 78% de la largeur pour éviter que le joueur soit
    // collé au bord droit de l'écran quand il franchit la ligne.
    final double finishX = gameSize.x * 0.78 - _spriteSize / 2;
    final double playerWorldX = _rabbitProgress * worldScale;

    // Positionnement immédiat de la vue (le mouvement de la variable _rabbitProgress est déjà animé avec inertie)
    _player.position.x = (playerWorldX - _scrollOffset).clamp(0.0, finishX);

    // Les roues du joueur reposent sur la ligne de roulage partagée. Repli sur
    // l'ancien ratio 0.72 tant que la zone de course n'est pas mesurée.
    final double rideLine = _rideLineLocalY > 0
        ? _rideLineLocalY
        : gameSize.y * 0.72;
    _playerY = rideLine - _spriteSize + _rideLineVerticalNudge;
    _player.position.y = _playerY;

    // --- Rival (positionné directement via le scroll lissé) ---
    if (_rival != null && isCampaign) {
      // Ne pas relancer le ride une fois la partie terminée : ça écraserait
      // l'animation victory/defeat déclenchée dans updateProgress().
      if (!_isGameOver) {
        _rival!.startRiding();
      }

      final double rivalWorldX = _foxProgress * worldScale;
      final double rivalScreenX = rivalWorldX - _scrollOffset;
      // Option A : même piste que le joueur, une voie au-dessus (roues sur
      // rideLine - _rivalLaneGap).
      final double rivalY =
          rideLine - _rivalLaneGap - _spriteSize + _rideLineVerticalNudge;

      if (rivalScreenX < -_spriteSize || rivalScreenX > gameSize.x) {
        _rival!.position = Vector2(-_spriteSize * 2, rivalY);
      } else {
        _rival!.position = Vector2(rivalScreenX, rivalY);
      }
    }
  }
}
