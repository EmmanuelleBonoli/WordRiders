
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:word_train/features/gameplay/components/player.dart';
import '../../gameplay/services/player_preferences.dart';
import '../widgets/stage_circle_widget.dart';

class CampaignProgressScreen extends StatefulWidget {
  const CampaignProgressScreen({super.key});

  @override
  State<CampaignProgressScreen> createState() => _CampaignProgressScreenState();
}

class _CampaignProgressScreenState extends State<CampaignProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _stageAnimation;

  CampaignPreviewGame? _previewGame;

  int _currentStage = 1;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadStageProgress();
  }

  Future<void> _loadStageProgress() async {
    _currentStage = await PlayerProgress.getCurrentStage();
    final startingStage = (_currentStage > 10)
        ? _currentStage - 10
        : _currentStage;

    // Crée le mini-jeu de preview avec les bornes de stage
    _previewGame = CampaignPreviewGame(
      startingStage: startingStage,
      maxStage: _currentStage,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );

    _stageAnimation = IntTween(begin: startingStage, end: _currentStage)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _previewGame?.onRemove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
           Positioned.fill(
             child: Image.asset(
               'assets/images/background/game_bg.png',
               fit: BoxFit.cover,
               alignment: Alignment.center, // Loopable bg usually works well centered or tiled
             ),
           ),
           
           // Overlay for contrast
           Positioned.fill(
             child: Container(
               color: Colors.white.withValues(alpha: 0.4),
             ),
           ),

           SafeArea(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Align(
                   alignment: Alignment.topLeft,
                   child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Container(
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         boxShadow: [
                           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                         ],
                       ),
                       child: BackButton(
                         color: Theme.of(context).primaryColor,
                       ),
                     ),
                   ),
                 ),
                 
                 Expanded(
                   child: Center(
                     child: Container(
                        height: 250, // Enough height for game + circles
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // GAME PREVIEW
                            SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: _previewGame == null
                                  ? const SizedBox.shrink()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: GameWidget(
                                        game: _previewGame!,
                                      ),
                                    ),
                            ),
                            
                            const Spacer(),
                            
                            // STAGE INDICATORS
                            AnimatedBuilder(
                              animation: _stageAnimation,
                              builder: (context, child) {
                                // Update game stage
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _previewGame?.setStage(_stageAnimation.value);
                                });

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _buildStageCircles(_stageAnimation.value)
                                        .map((w) => Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: w))
                                        .toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                     ),
                   ),
                 ),
                 
                 const SizedBox(height: 20),
               ],
             ),
           ),
        ],
      ),
    );
  }

  List<Widget> _buildStageCircles(int displayedStage) {
    return List.generate(10, (index) {
      final stageNumber = displayedStage - 4 + index;

      if (stageNumber < 1) {
        return const SizedBox(width: 40);
      }

      final unlocked = stageNumber <= _currentStage;

      return StageCircle(number: stageNumber, unlocked: unlocked);
    });
  }
}

/// Petit FlameGame utilisé pour prévisualiser le player sur l'écran de progression
class CampaignPreviewGame extends FlameGame {
  final int startingStage;
  final int maxStage;
  late Player _player;
  int? _pendingStage;
  static const double _horizontalPadding = 12.0;

  CampaignPreviewGame({required this.startingStage, required this.maxStage});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // active le debug pour voir un conteneur si la sprite ne s'affiche pas
    _player = Player(debug: true);
    // taille raisonnable pour mini-preview
    _player.size = Vector2(Player.rabbitWidth, Player.rabbitWidth);
    await add(_player);

    // position initiale
    // Utilise setStage qui gére le cas size.x == 0 (mémorise en _pendingStage)
    setStage(startingStage);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // repositionne le player si on avait une mise à jour en attente
    if (_pendingStage != null) {
      _applyStage(_pendingStage!);
      _pendingStage = null;
    } else {
      // redispatch de la position courante pour tenir compte de la nouvelle largeur
      _applyStage(startingStage);
    }
  }

  /// Mappe un numéro de stage à une position X et place le player
  void setStage(int stage) {
    // si la taille du canvas n'est pas encore connue, mémorise
    if (size.x == 0) {
      _pendingStage = stage;
      return;
    }

    _applyStage(stage);
  }

  void _applyStage(int stage) {
    final effectiveStart = startingStage;
    final effectiveEnd = maxStage == effectiveStart ? effectiveStart + 1 : maxStage;
    final progress = ((stage - effectiveStart) / (effectiveEnd - effectiveStart)).clamp(0.0, 1.0);

    final usableWidth = size.x - 2 * _horizontalPadding - _player.size.x;
    final x = _horizontalPadding + usableWidth * progress;

    // place le player sur l'axe Y au centre vertical de la zone de preview
    final y = (size.y / 2) - (_player.size.y / 2);

    _player.position = Vector2(x, y);
  }
}
