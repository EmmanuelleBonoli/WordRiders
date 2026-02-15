import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_riders/features/ui/screens/main_scaffold.dart';
import 'package:word_riders/features/ui/widgets/campaign/campaign_preview_game.dart';
import 'package:word_riders/features/ui/styles/app_theme.dart';
import 'package:word_riders/features/gameplay/services/player_preferences.dart';
import 'package:word_riders/features/ui/widgets/campaign/stage_circle_widget.dart';
import 'package:word_riders/features/ui/widgets/game/overlays/no_lives_overlay.dart';
import 'package:word_riders/features/ui/widgets/common/bouncing_scale_button.dart';

class CampaignProgressScreen extends StatefulWidget {
  const CampaignProgressScreen({super.key});

  @override
  State<CampaignProgressScreen> createState() => _CampaignProgressScreenState();
}

class _CampaignProgressScreenState extends State<CampaignProgressScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  late Animation<double> _stageAnimation;
  
  AnimationController? _shakeController;
  late Animation<Offset> _shakeAnimation;


  CampaignPreviewGame? _previewGame;


  int _currentStage = 1;
  bool _loaded = false;
  
  int _viewMinStage = 1;
  int _viewMaxStage = 10;
  
  @override
  void initState() {
    super.initState();
    _loadStageProgress();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _shakeController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  Future<void> _loadStageProgress() async {
    try {
      debugPrint("Starting _loadStageProgress...");
      _currentStage = await PlayerPreferences.getCurrentStage();
      if (!mounted) return;

      debugPrint("Loaded stage: $_currentStage");
      
      // Toujours centrer sur le stage actuel
      // La fenêtre est de 5 de large, centrée sur _currentStage.
      _viewMinStage = _currentStage - 5;
      _viewMaxStage = _currentStage + 5;

      // Animation : entree de l'extérieur (gauche) vers le centre
      final double animStart = _viewMinStage.toDouble() - 1.5; 
      final double animEnd = _currentStage.toDouble();

      debugPrint("Creating preview game...");
      // Prévisualisation du mini-jeu
      _previewGame = CampaignPreviewGame(
        minVisibleStage: _viewMinStage,
        maxVisibleStage: _viewMaxStage,
      );
      // On lance le mouvement
      _previewGame!.setPlaying(true);

      debugPrint("Setting up animations...");
      
      _shakeController?.dispose();
      _shakeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600), 
      )..repeat(reverse: true); // Reverse true crée l'effet "Yoyo"

      _shakeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_shakeController!);

      _animationController?.dispose();
      _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 2500),
      );

      _stageAnimation = Tween<double>(
        begin: animStart,
        end: animEnd,
      ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeOut),
      );

      _animationController!.addListener(() {
        // Mise à jour uniquement si le jeu existe
        if (_previewGame != null) {
          _previewGame!.setStage(_stageAnimation.value);
        }
      });

      _animationController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Arrêter le mouvement à la fin de l'animation
           if (_previewGame != null) {
             _previewGame!.setPlaying(false);
           }
        }
      });

      debugPrint("Starting animation forward...");
      _animationController!.forward();
      
      if (mounted) {
        setState(() => _loaded = true);
        WidgetsBinding.instance.addPostFrameCallback((_) => _centerContent());
      }
    } catch (e) {
      debugPrint("ERROR loading stage progress: $e");
      if (mounted) {
         setState(() => _loaded = true);
      }
    }
  }

  final ScrollController _scrollController = ScrollController();



  void _centerContent() {
    if (_scrollController.hasClients) {
      // Calculer le centrage exact par rapport à la largeur de l'écran
      final viewportWidth = MediaQuery.of(context).size.width - 40;
      const contentWidth = 990.0;
      final offset = (contentWidth - viewportWidth) / 2;
      
      _scrollController.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Transform.translate(
        offset: const Offset(0, 60),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Path Line
              Container(
                 width: 990, 
                 height: 6,
                 decoration: BoxDecoration(
                   color: AppTheme.brown,
                   borderRadius: BorderRadius.circular(3),
                 ),
              ),
              
              // 2. Circles
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildStageCircles(),
              ),

              // 3. Player / Game (Overlay inside ScrollView)
              if (_previewGame != null)
                Positioned(
                  bottom: 125,
                  left: 0,
                  width: 990,
                  height: 230,
                  child: IgnorePointer(
                      child: GameWidget(
                        game: _previewGame!,
                      ),
                    ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStageCircles() {
    // Génère les cercles pour la fenêtre visible
    final count = _viewMaxStage - _viewMinStage + 1;
    return List.generate(count, (index) {
      final stageNumber = _viewMinStage + index;
      
      Widget content;

      if (stageNumber < 1) {
        // Espaceur invisible pour maintenir la mise en page
        // Utilisation d'une largeur fixe de 90 pour aligner avec la grille
        content = const SizedBox(width: 50, height: 50); 
      } else {
        final unlocked = stageNumber <= _currentStage;
        final isCurrent = stageNumber == _currentStage;
        
        Widget circle = StageCircle(number: stageNumber, unlocked: unlocked, isCurrent: isCurrent);
        
        if (isCurrent) {
          content = BouncingScaleButton(
            showShadow: false,
             onTap: () async {
              final mainScaffold = context.findAncestorStateOfType<MainScaffoldState>();
              final lives = mainScaffold?.currentLives ?? 5;
              
              if (lives <= 0) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (ctx) => NoLivesOverlay(
                    onLivesReplenished: () {
                      final mainScaffold = context.findAncestorStateOfType<MainScaffoldState>();
                      mainScaffold?.reloadIndicators();
                    },
                  ),
                );
                return;
              }

              await context.push('/game', extra: {'isCampaign': true});
              if (context.mounted) {
                 _loadStageProgress();
                 mainScaffold?.reloadIndicators();
              }
            },
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final curvedValue = Curves.easeInOutSine.transform(_shakeController!.value);
                final scale = 1.0 + (curvedValue * 0.08); 
                return Transform.scale(
                  scale: scale,
                  filterQuality: FilterQuality.medium,
                  child: RepaintBoundary(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: circle,
            ),
          );
        } else {
          content = circle;
        }
      }

      // Envelopper chaque élément dans un conteneur de largeur fixe (90px)
      // pour garantir un alignement parfait avec le player.
      return SizedBox(
        width: 90,
        child: Center(child: content),
      );
    });
  }
}
