import 'package:flame/components.dart';
import 'package:word_riders/features/gameplay/models/character_anim_enums.dart';

class AnimationRegistry {
  // Fonction utilitaire pour générer les données d'une animation
  static SpriteAnimationData _createData({
    required int frameCount, 
    required double stepTime, 
    required Vector2 textureSize,
    int? amountPerRow,
    bool loop = true,
  }) {
    return SpriteAnimationData.sequenced(
      amount: frameCount,
      stepTime: stepTime,
      textureSize: textureSize,
      amountPerRow: amountPerRow,
      loop: loop,
    );
  }

  // Obtenir le chemin de l'asset en fonction du personnage et de l'état
  static String getSpriteSheetPath(CharacterType type, CharacterState state) {
    final typeStr = type.name; // ex: 'player', 'rival'
    String stateStr = state.name; // ex: 'ride', 'celebrateJump'
    
    // Mapping pour les noms de fichiers qui ne suivent pas le nom de l'enum
    if (state == CharacterState.idleBreath) stateStr = 'idle_breath';
    if (state == CharacterState.idleSleeping) stateStr = 'idle_sleeping';
    if (state == CharacterState.defeat) stateStr = 'defeat'; 

    // Tes fichiers devront être nommés de façon logique, ex: assets/images/animations/player_running.png
    return 'animations/${typeStr}_$stateStr.png';
  }

  // Associer un état à sa configuration (nombre de frames, vitesse, TAILLE)
  static SpriteAnimationData getAnimationData(CharacterType type, CharacterState state) {
    if (type == CharacterType.player) {
      switch (state) {
        case CharacterState.idleBreath:
        case CharacterState.idleSleeping:
        case CharacterState.defeat:
        case CharacterState.victory:
        case CharacterState.pedalTrick:
          // On met loop à false pour pouvoir déclencher le prochain idle à la fin de l'animation
          // ou pour que les animations de fin s'arrêtent sur la dernière frame.
          return _createData(frameCount: 25, stepTime: 0.1, textureSize: Vector2(256, 256), amountPerRow: 5, loop: false);
        case CharacterState.ride:
          // Exemple avec amountPerRow :
          return _createData(frameCount: 20, stepTime: 0.1, textureSize: Vector2(256, 256), amountPerRow: 5, loop: true);
        // Ajoute ici les autres états quand tu les auras mis dans l'Enum
      }
    }

    if (type == CharacterType.rival) {
      switch (state) {
        case CharacterState.idleBreath:
        case CharacterState.defeat:
        case CharacterState.victory:
          // Même logique que le player : loop à false pour figer sur la dernière frame.
          return _createData(frameCount: 25, stepTime: 0.1, textureSize: Vector2(256, 256), amountPerRow: 5, loop: false);
        case CharacterState.ride:
          return _createData(frameCount: 25, stepTime: 0.1, textureSize: Vector2(256, 256), amountPerRow: 5, loop: true);
        case CharacterState.idleSleeping:
        case CharacterState.pedalTrick:
          break; // Pas d'asset pour ces états côté rival, on laisse le fallback échouer proprement.
      }
    }

    // Configuration par défaut pour les autres cas non gérés ci-dessus
    return _createData(frameCount: 4, stepTime: 0.2, textureSize: Vector2(256, 256), loop: true);
  }
}
