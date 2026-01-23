import 'package:flame/components.dart';

class Player extends SpriteComponent {
  late List<Sprite> frames;
  int currentFrame = 0;
  @override
  bool isLoaded = false;

  static const double rabbitWidth = 120;

  double _timer = 0;
  bool isPlaying = false;

  // debug : si true, active le debugMode pour tracer un rectangle si le sprite manque
  Player({bool debug = false}) : super(size: Vector2(rabbitWidth, rabbitWidth)) {
    debugMode = debug;
  }

  @override
  Future<void> onLoad() async {
    await _loadFrames();
    sprite = frames[0];
    isLoaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPlaying && isLoaded && frames.length > 1) {
      _timer += dt;
      if (_timer > 0.1) { // ~10 FPS
        _timer = 0;
        currentFrame = (currentFrame + 1) % frames.length;
        sprite = frames[currentFrame];
      }
    } else if (!isPlaying && isLoaded) {
      // Retour à l'état de repos (idle) si arrêté
      if (currentFrame != 0) {
        currentFrame = 0;
        sprite = frames[0];
      }
    }
  }

  Future<void> _loadFrames() async {
    frames = [
      await Sprite.load('player/rabbit1.png'),
      await Sprite.load('player/rabbit2.png'),
      await Sprite.load('player/rabbit3.png'),
      await Sprite.load('player/rabbit4.png'),
    ];
  }

  /// Change la frame pour l’animation (manuelle)
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
