import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'package:word_riders/features/gameplay/models/character_anim_enums.dart';
import 'package:word_riders/features/ui/animations/character_registry_animation.dart';

class GameCharacter extends SpriteAnimationGroupComponent<CharacterState> with HasGameReference {
  final CharacterType characterType;
  final Random _random = Random();
  
  // Liste des autres idles disponibles (pour les 20%)
  final List<CharacterState> _otherIdles = [
    CharacterState.idleSleeping,
    // Ajouter les futurs idles ici
  ];

  // Liste des animations de tricks disponibles
  final List<CharacterState> _trickAnimations = [
    CharacterState.pedalTrick,
    // Ajouter les futurs tricks ici
  ];

  GameCharacter({required this.characterType, super.position, super.size});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final tempAnimations = <CharacterState, SpriteAnimation>{};

    for (var state in CharacterState.values) {
      try {
        final path = AnimationRegistry.getSpriteSheetPath(characterType, state);
        final data = AnimationRegistry.getAnimationData(characterType, state);
        
        tempAnimations[state] = await game.loadSpriteAnimation(path, data);
      } catch (e) {
        // Optionnel : Gérer le cas où un personnage n'a pas encore une animation spécifique dessinée
        debugPrint('Animation non trouvée pour $characterType - $state : $e');
      }
    }

    animations = tempAnimations;

    playIdleLoop();
  }

  // --- METHODE SECURISÉE --- //
  bool _trySetState(CharacterState state) {
    if (animations?.containsKey(state) == true) {
      current = state;
      return true;
    }
    return false;
  }

  // --- GESTION DE L'IDLE --- //

  /// Lance une animation idle et programme la suivante
  void playIdleLoop() {
    List<CharacterState> availableIdles = [];
    if (animations?.containsKey(CharacterState.idleBreath) == true) {
      availableIdles.add(CharacterState.idleBreath);
    }
    for (var idle in _otherIdles) {
      if (animations?.containsKey(idle) == true) {
        availableIdles.add(idle);
      }
    }

    // S'il n'y a aucune animation idle chargée, on ne fait rien (ex: pour le rival)
    if (availableIdles.isEmpty) return;

    CharacterState nextIdle;

    if (availableIdles.contains(CharacterState.idleBreath) && (availableIdles.length == 1 || _random.nextDouble() < 0.8)) {
      nextIdle = CharacterState.idleBreath;
    } else {
      var others = availableIdles.where((i) => i != CharacterState.idleBreath).toList();
      nextIdle = others[_random.nextInt(others.length)];
    }

    _trySetState(nextIdle);

    final ticker = animationTickers?[nextIdle];
    if (ticker != null) {
      ticker.onComplete = () {
        ticker.reset();
        // S'assurer qu'on est toujours censé être en idle avant de boucler
        if (current == CharacterState.idleBreath || _otherIdles.contains(current)) {
          playIdleLoop();
        }
      };
    }
  }

  /// Passe en mode course
  void startRiding() {
    _trySetState(CharacterState.ride);
  }

  // --- LES DÉCLENCHEURS --- //

  /// Déclenche l'animation de défaite (pas de boucle)
  void triggerDefeat() {
    _trySetState(CharacterState.defeat);
  }

  /// Déclenche l'animation de victoire (pas de boucle)
  void triggerVictory() {
    _trySetState(CharacterState.victory);
  }

  /// Joue un trick aléatoire. 
  /// [resumeRiding] détermine si on reprend la course ou l'idle à la fin de l'animation.
  void triggerTrick({bool resumeRiding = true}) {
    var availableTricks = _trickAnimations.where((t) => animations?.containsKey(t) == true).toList();

    if (availableTricks.isEmpty) {
      if (resumeRiding) {
        startRiding();
      } else {
        playIdleLoop();
      }
      return;
    }

    final index = _random.nextInt(availableTricks.length);
    final trickState = availableTricks[index];
    
    _trySetState(trickState);
    
    final ticker = animationTickers?[trickState];
    if (ticker != null) {
      ticker.onComplete = () {
        ticker.reset(); // On réinitialise pour pouvoir la rejouer plus tard
        if (resumeRiding) {
          startRiding();
        } else {
          playIdleLoop();
        }
      };
    }
  }

  /// Joue une animation ponctuelle spécifique (ex: erreur) et retourne à l'idle
  void playOneShotAnimation(CharacterState targetState) {
    if (!_trySetState(targetState)) {
      playIdleLoop();
      return;
    }

    final animationTicker = animationTickers?[targetState];
    if (animationTicker != null) {
      animationTicker.onComplete = () {
        animationTicker.reset(); // On réinitialise pour pouvoir la rejouer plus tard
        playIdleLoop();
      };
    } else {
      // Sécurité si l'animation boucle (ce qui ne devrait pas arriver pour du OneShot)
      playIdleLoop();
    }
  }

  void moveForward(double amount, double maxX) {
    position.x = (position.x + amount).clamp(0, maxX);
  }
}
