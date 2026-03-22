import 'package:flame/components.dart';

class Rival extends SpriteComponent {
  late List<Sprite> frames;
  int currentFrame = 0;
  @override
  bool isLoaded = false;

  static const double foxWidth = 120; // Même taille que le player

  double _timer = 0;
  bool isPlaying = false;

  Rival({bool debug = false}) : super(size: Vector2(foxWidth, foxWidth)) {
    debugMode = debug;
  }

  @override
  Future<void> onLoad() async {
    await _loadFrames();
    if (frames.isNotEmpty) {
      sprite = frames[0];
    }
    isLoaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPlaying && isLoaded && frames.length > 1) {
      _timer += dt;
      if (_timer > 0.08) {
        _timer = 0;
        currentFrame = (currentFrame + 1) % frames.length;
        sprite = frames[currentFrame];
      }
    }
  }
  Future<void> _loadFrames() async {
    frames = [
      await Sprite.load('player/fox1.png'),
      await Sprite.load('player/fox2.png'),
      await Sprite.load('player/fox3.png'),
      await Sprite.load('player/fox4.png'),
      await Sprite.load('player/fox5.png'),
      await Sprite.load('player/fox6.png'),
    ];
  }

  // Déplace le rival vers l'avant (avec limite)
  void moveForward(double amount, double maxX) {
    position.x = (position.x + amount).clamp(0, maxX);
  }
}
