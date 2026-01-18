import 'package:flame/components.dart';

class Player extends SpriteComponent {
  late List<Sprite> frames;
  int currentFrame = 0;
  bool isLoaded = false;

  static const double rabbitWidth = 120;

  // debug : si true, active le debugMode pour tracer un rectangle si le sprite manque
  Player({bool debug = false}) : super(size: Vector2(rabbitWidth, rabbitWidth)) {
    debugMode = debug;
  }

  @override
  Future<void> onLoad() async {
    await _loadFrames();
    sprite = frames[0]; // première frame
    isLoaded = true;
  }

  Future<void> _loadFrames() async {
    frames = [
      await Sprite.load('player/rabbit1.png'),
      // await Sprite.load('player/rabbit2.png'),
      // await Sprite.load('player/rabbit3.png'),
      // await Sprite.load('player/rabbit4.png'),
    ];
  }

  /// Change la frame pour l’animation
  void updateFrame() {
    if (!isLoaded) return;

    currentFrame = (currentFrame + 1) % frames.length;
    sprite = frames[currentFrame]; // met à jour l'image affichée
  }

  /// Déplace le joueur vers l'avant (avec limite)
  void moveForward(double amount, double maxX) {
    position.x = (position.x + amount).clamp(0, maxX);
  }
}
