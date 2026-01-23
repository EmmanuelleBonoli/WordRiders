
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_train/features/ui/widgets/campaign/campaign_preview_game.dart';
import 'package:word_train/features/ui/styles/app_theme.dart';
import '../../gameplay/services/player_preferences.dart';
import '../widgets/navigation/app_back_button.dart';
import '../widgets/navigation/settings_button.dart';
import '../widgets/campaign/stage_circle_widget.dart';

class CampaignProgressScreen extends StatefulWidget {
  const CampaignProgressScreen({super.key});

  @override
  State<CampaignProgressScreen> createState() => _CampaignProgressScreenState();
}

class _CampaignProgressScreenState extends State<CampaignProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _stageAnimation;
  
  late AnimationController _shakeController;
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

  Future<void> _loadStageProgress() async {
    try {
      debugPrint("Starting _loadStageProgress...");
      _currentStage = await PlayerProgress.getCurrentStage();
      debugPrint("Loaded stage: $_currentStage");
      
      // Toujours centrer sur le stage actuel
      // La fenêtre est de 5 de large, centrée sur _currentStage.
      _viewMinStage = _currentStage - 5;
      _viewMaxStage = _currentStage + 5;

      // Animation : entree de l'extérieur (gauche) vers le centre
      // On commence 1 unité *avant* le minimum visible.
      // Progress 0.0 est le bouton visible à gauche.
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
      _shakeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600), 
      )..repeat(reverse: true); // Reverse true crée l'effet "Yoyo"

      _shakeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_shakeController);

      _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 2500),
      );

      _stageAnimation = Tween<double>(
        begin: animStart,
        end: animEnd,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      _animationController.addListener(() {
        // Mise à jour uniquement si le jeu existe
        if (_previewGame != null) {
          _previewGame!.setStage(_stageAnimation.value);
        }
      });

      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Arrêter le mouvement à la fin de l'animation
           if (_previewGame != null) {
             _previewGame!.setPlaying(false);
           }
        }
      });

      debugPrint("Starting animation forward...");
      _animationController.forward();
      
      if (mounted) {
        setState(() => _loaded = true);
      }
    } catch (e) {
      debugPrint("ERROR loading stage progress: $e");
      if (mounted) {
         setState(() => _loaded = true);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
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
           Positioned.fill(
             child: Image.asset(
               'assets/images/background/game_bg.png',
               fit: BoxFit.cover,
               alignment: Alignment.center,
             ),
           ),

           SafeArea(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppBackButton(),
                        const SettingsButton(),
                      ],
                    ),
                  ),
                 
                 Expanded(
                   child: Center(
                     child: Container(
                        height: 250, 
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                     width: 900, 
                                     height: 6,
                                     decoration: BoxDecoration(
                                       color: AppTheme.brown,
                                       borderRadius: BorderRadius.circular(3),
                                     ),
                                  ),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _buildStageCircles()
                                        .map((w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: w))
                                        .toList(),
                                  ),
                                ],
                              ),
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

  List<Widget> _buildStageCircles() {
    // Génère les cercles pour la fenêtre visible
    final count = _viewMaxStage - _viewMinStage + 1;
    return List.generate(count, (index) {
      final stageNumber = _viewMinStage + index;
      if (stageNumber < 1) {
        // Espaceur invisible pour maintenir la mise en page
        return const SizedBox(width: 54, height: 54);
      }
      final unlocked = stageNumber <= _currentStage;
      final isCurrent = stageNumber == _currentStage;
      
      Widget circle = StageCircle(number: stageNumber, unlocked: unlocked);
      
      // Rendre l'étape actuelle cliquable pour lancer le niveau
      if (isCurrent) {
        return GestureDetector(
          onTap: () async {
            // Navigation vers l'écran de jeu en mode Campagne
            await context.push('/game', extra: {'isCampaign': true});
            // Au retour, on recharge la progression
            if (context.mounted) {
               _loadStageProgress();
            }
          },
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final curvedValue = Curves.easeInOutSine.transform(_shakeController.value);
              
              final scale = 1.0 + (curvedValue * 0.08); 
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6 * curvedValue),
                        blurRadius: 15 * scale,
                        spreadRadius: 2 * scale,
                      ),
                      BoxShadow(
                        color: AppTheme.cream.withValues(alpha: 0.6 * curvedValue),
                        blurRadius: 20 * scale, 
                        spreadRadius: 2 * scale,
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: circle,
          ),
        );
      }
      
      return circle;
    });
  }
}


