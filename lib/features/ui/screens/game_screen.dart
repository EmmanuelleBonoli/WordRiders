import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:word_riders/features/gameplay/controllers/game_controller.dart';
import 'package:word_riders/features/gameplay/controllers/game_keyboard_handler.dart';
import 'package:word_riders/features/gameplay/controllers/physics_progress_controller.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/gameplay/services/word_service.dart';
import 'package:word_riders/features/ui/widgets/game/game_background.dart';
import 'package:word_riders/features/ui/widgets/game/game_header.dart';
import 'package:word_riders/features/ui/widgets/game/game_header_background.dart';
import 'package:word_riders/features/ui/widgets/game/input/game_input_area.dart';
import 'package:word_riders/features/ui/widgets/game/game_race_area.dart';
import 'package:word_riders/features/ui/widgets/game/race_track_geometry.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/game_end_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/game_pause_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/no_lives_overlay.dart';
import 'package:word_riders/features/ui/widgets/game/game_timeline.dart';
import 'package:word_riders/features/ui/widgets/game/game_bonus_panel.dart';

import 'package:word_riders/features/ui/widgets/game/overlays/training_config_overlay.dart';

class GameScreen extends StatelessWidget {
  final bool isCampaign;

  const GameScreen({super.key, this.isCampaign = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey(context.locale.languageCode),
      create: (ctx) => GameController(
        isCampaign: isCampaign,
        locale: context.locale.languageCode,
        wordService: ctx.read<WordService>(),
      ),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatefulWidget {
  const _GameScreenContent();

  @override
  State<_GameScreenContent> createState() => _GameScreenContentState();
}

class _GameScreenContentState extends State<_GameScreenContent>
    with SingleTickerProviderStateMixin {
  late final PhysicsProgressController _physicsController;
  late final GameController _controller;
  late final GameKeyboardHandler _keyboardHandler;
  final FocusNode _keyboardFocusNode = FocusNode(
    debugLabel: 'GameKeyboardFocus',
  );

  // Délai avant l'ouverture de la modale de fin, pour laisser le temps
  // de voir l'animation victory/defeat se jouer sur la zone de course.
  static const Duration _endOverlayDelay = Duration(milliseconds: 1500);
  Timer? _endOverlayTimer;
  bool _showEndOverlay = false;
  GameStatus? _lastHandledStatus;

  static const double _spriteSize = 120.0 * 0.9;

  // --- Mesure de la zone de course (pour la géométrie de piste partagée) ---
  // On mesure la position/hauteur réelle du canvas Flame afin de convertir la
  // ride line du repère écran vers le repère local du canvas, et d'en déduire
  // la hauteur d'UI basse à ne pas recouvrir (bottomReserved).
  final GlobalKey _raceAreaKey = GlobalKey();
  double _raceAreaTop = 0;
  double _raceAreaHeight = 0;
  bool _raceAreaMeasured = false;

  // --- Mesure du header (pour caler le haut du fond sur le milieu des
  // boutons premium retour/réglages, plutôt que sur le haut de la zone de
  // course). ---
  final GlobalKey _headerKey = GlobalKey();
  double _headerMidY = 0;
  bool _headerMeasured = false;

  // --- Mesure de la ligne de saisie (pour caler le bas du fond sur la ligne
  // dorée qui coupe en 2 les boutons premium Mélanger/Valider). ---
  final GlobalKey _inputAreaKey = GlobalKey();
  double _inputAreaGoldenY = 0;
  bool _inputAreaMeasured = false;

  void _measureRaceArea() {
    final RenderObject? obj = _raceAreaKey.currentContext?.findRenderObject();
    if (obj is! RenderBox || !obj.hasSize) return;
    final double top = obj.localToGlobal(Offset.zero).dy;
    final double height = obj.size.height;
    if (!_raceAreaMeasured ||
        (top - _raceAreaTop).abs() > 0.5 ||
        (height - _raceAreaHeight).abs() > 0.5) {
      setState(() {
        _raceAreaTop = top;
        _raceAreaHeight = height;
        _raceAreaMeasured = true;
      });
    }
  }

  void _measureHeader() {
    final RenderObject? obj = _headerKey.currentContext?.findRenderObject();
    if (obj is! RenderBox || !obj.hasSize) return;
    final double midY = obj.localToGlobal(Offset.zero).dy + obj.size.height / 2;
    if (!_headerMeasured || (midY - _headerMidY).abs() > 0.5) {
      setState(() {
        _headerMidY = midY;
        _headerMeasured = true;
      });
    }
  }

  void _measureInputArea() {
    final RenderObject? obj = _inputAreaKey.currentContext?.findRenderObject();
    if (obj is! RenderBox || !obj.hasSize) return;
    final double goldenY =
        obj.localToGlobal(Offset.zero).dy + GameInputArea.goldenLineOffset;
    if (!_inputAreaMeasured || (goldenY - _inputAreaGoldenY).abs() > 0.5) {
      setState(() {
        _inputAreaGoldenY = goldenY;
        _inputAreaMeasured = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _physicsController = PhysicsProgressController(this);
    _physicsController.addListener(_onPhysicsUpdate);
    _controller = context.read<GameController>();
    _controller.addListener(_onControllerStatusChanged);
    _keyboardHandler = GameKeyboardHandler(
      target: _controller,
      onPauseRequested: _onBackTap,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStatusChanged);
    _endOverlayTimer?.cancel();
    _physicsController.removeListener(_onPhysicsUpdate);
    _physicsController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _onPhysicsUpdate() {
    setState(() {});
  }

  /// Ouvre la modale de pause
  void _onBackTap() {
    _controller.pauseGame();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GamePauseOverlay(
        title: context.tr('game.pause_title'),
        isCampaign: _controller.isCampaign,
        onResume: () {
          Navigator.pop(ctx);
          _controller.resumeGame();
        },
        onRestart: () async {
          Navigator.pop(ctx);

          // En campagne, recommencer en cours de jeu coûte une vie (abandon)
          if (_controller.isCampaign) {
            final success = await _controller.consumeLifeForRestart();
            if (!success) {
              // Si plus de vie : afficher la modale pour recharger
              if (context.mounted) {
                await showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (dialogCtx) => NoLivesOverlay(
                    fromGame: true,
                    onLivesReplenished: () {
                      _controller.restartGame();
                    },
                  ),
                );

                if (context.mounted) {
                  final currentLives = await PlayerPreferences.getLives();
                  if (currentLives <= 0) {
                    if (context.mounted) {
                      context.go('/campaign');
                    }
                  }
                }
              }
              return;
            }
          }

          _controller.restartGame();
        },
        onQuit: () async {
          Navigator.pop(ctx);
          await _controller.quitGame();
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  /// Programme l'ouverture de la modale de fin après [_endOverlayDelay],
  /// pour laisser le temps de voir l'animation victory/defeat.
  void _onControllerStatusChanged() {
    final status = _controller.status;
    final bool isOver = status == GameStatus.won || status == GameStatus.lost;

    // Redonne le focus clavier quand la partie commence ou reprend
    if (status == GameStatus.playing && !_keyboardFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.status == GameStatus.playing) {
          _keyboardFocusNode.requestFocus();
        }
      });
    }

    if (!isOver) {
      _lastHandledStatus = status;
      _endOverlayTimer?.cancel();
      if (_showEndOverlay) setState(() => _showEndOverlay = false);
      return;
    }

    if (_lastHandledStatus == status) return;
    _lastHandledStatus = status;

    _endOverlayTimer?.cancel();
    _endOverlayTimer = Timer(_endOverlayDelay, () {
      if (mounted) setState(() => _showEndOverlay = true);
    });
  }

  /// Calcule l'offset cible depuis la progression du joueur.
  double _computeTargetOffset(
    double rabbitProgress,
    double screenWidth,
    bool isOver,
  ) {
    final double centerX = screenWidth / 2 - _spriteSize / 2;
    // En baissant cette valeur (ex: 0.03 au lieu de 0.13), on multiplie la distance virtuelle totale.
    // Les personnages devront courir beaucoup plus de pixels pour faire 1% de progression,
    // ce qui donne l'impression d'une vitesse et d'une distance de course plus longue !
    final double worldScale = centerX / 0.04;
    final double maxScroll = (worldScale - screenWidth).clamp(
      0.0,
      double.infinity,
    );
    if (isOver && rabbitProgress >= 1.0) return maxScroll;
    final double playerWorldX = rabbitProgress * worldScale;
    return (playerWorldX - centerX).clamp(0.0, maxScroll);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.status == GameStatus.waitingForConfig) {
      return TrainingConfigOverlay(
        onSelectLength: (length) => controller.startTraining(length),
        onBack: () => context.pop(),
      );
    }

    // Mise à jour de l'offset cible à chaque rebuild du controller
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final bool isOver =
        controller.status == GameStatus.won ||
        controller.status == GameStatus.lost;

    // Re-mesure des repères de fond après la frame (no-op si inchangés).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureRaceArea();
      _measureHeader();
      _measureInputArea();
    });

    // Mise à jour des cibles pour le contrôleur de physique
    _physicsController.updateTargets(
      controller.rabbitProgress,
      controller.foxProgress,
    );

    // On calcule l'offset directement depuis la progression lissée du joueur.
    // Ainsi la caméra suit naturellement et fluidement le joueur avec la même inertie.
    final double smoothScrollOffset = _computeTargetOffset(
      _physicsController.smoothRabbitProgress,
      screenWidth,
      isOver,
    );

    // Géométrie de piste partagée : le fond doit démarrer au milieu des
    // boutons premium du header (topReserved) et descendre jusqu'à la ligne
    // dorée des boutons premium de la ligne de saisie (bottomReserved).
    // La ride line, elle, reste calculée en repère écran puis convertie en
    // repère local du canvas Flame via _raceAreaTop.
    // Avant la première mesure, on estime ces repères pour éviter une frame
    // de fond dégénéré (l'écran affiche de toute façon un loader).
    final double topReserved = _headerMeasured
        ? _headerMidY
        : MediaQuery.of(context).padding.top + 50;
    final double bottomReserved = _inputAreaMeasured
        ? (screenSize.height - _inputAreaGoldenY).clamp(0.0, screenSize.height)
        : screenSize.height * 0.38;
    final RaceTrackGeometry trackGeometry = raceTrackGeometry(
      screenSize,
      bottomReserved: bottomReserved,
      topReserved: topReserved,
    );
    final double rideLineLocalY = trackGeometry.rideLineY - _raceAreaTop;

    void onValidate() {
      controller.validate();
    }

    void onSettingsTap() async {
      controller.pauseGame();
      await context.push('/settings');

      // Si on change de langue dans les réglages, cet écran est détruit (nouvelle ValueKey).
      // On s'assure donc que le contexte est toujours monté avant d'utiliser le controller.
      if (!context.mounted) return;

      controller.resumeGame();
    }

    // Le clavier physique n'agit que sur cet écran, jamais via un champ de
    // saisie texte : aucun risque d'ouvrir le clavier virtuel sur tactile.
    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) => _keyboardHandler.handleKeyEvent(event)
          ? KeyEventResult.handled
          : KeyEventResult.ignored,
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Fond de course en 3 couches — piste fixe (référence stable des
            // personnages), avant-plan et arrière-plan en parallaxe pilotés par
            // l'offset lissé de la physique.
            Positioned.fill(
              child: GameBackground(
                scrollOffset: smoothScrollOffset,
                bottomReserved: bottomReserved,
                topReserved: topReserved,
              ),
            ),

          // 2. Header Background Decoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 55,
            child: const GameHeaderBackground(),
          ),

            // 3. Contenu Principal
            SafeArea(
              child: Column(
                children: [
                  KeyedSubtree(
                    key: _headerKey,
                    child: GameHeader(
                      onBack: _onBackTap,
                      onSettings: onSettingsTap,
                      isCampaign: controller.isCampaign,
                      currentStage: controller.currentStage,
                    ),
                  ),

                GameTimeline(
                  rabbitProgress: _physicsController.smoothRabbitProgress,
                  foxProgress: _physicsController.smoothFoxProgress,
                  showFox: controller.isCampaign,
                ),

                // Zone de Course — reçoit la progression et l'offset lissés par la physique.
                // KeyedSubtree : ancre de mesure pour convertir la ride line
                // écran → repère local du canvas Flame.
                Expanded(
                  child: KeyedSubtree(
                    key: _raceAreaKey,
                    child: GameRaceArea(
                      isCampaign: controller.isCampaign,
                      rabbitProgress: _physicsController.smoothRabbitProgress,
                      foxProgress: _physicsController.smoothFoxProgress,
                      isGameOver: isOver,
                      isPlayerWinner: controller.status == GameStatus.won,
                      smoothScrollOffset: smoothScrollOffset,
                      rideLineLocalY: rideLineLocalY,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: KeyedSubtree(
                    key: _inputAreaKey,
                    child: GameInputArea(
                      feedbackMessage: controller.feedbackMessage,
                      currentInput: controller.currentInput,
                      shuffledLetters: controller.shuffledLetters,
                      onBackspace: controller.onBackspace,
                      onValidate: onValidate,
                      onShuffle: controller.onShuffle,
                      onLetterTap: controller.onLetterTap,
                      isSuccessFlash: controller.isSuccessFlash,
                    ),
                  ),
                ),

                if (controller.isCampaign)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GameBonusPanel(controller: controller),
                  ),
              ],
            ),
          ),

            // 4. Overlays (Pause & Fin)
            if (_showEndOverlay)
              GameEndOverlay(
                currentLevel: controller.currentStage,
                isWon: controller.status == GameStatus.won,
                isCampaign: controller.isCampaign,
                onQuit: () async {
                  if (controller.isCampaign &&
                      controller.status == GameStatus.lost) {
                    await controller.concedeGame();
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                onRestart: () => controller.restartGame(),
                onContinue: () => Navigator.pop(context),
                onRevive: () => controller.revive(),
              ),
          ],
        ),
      ),
    );
  }
}
