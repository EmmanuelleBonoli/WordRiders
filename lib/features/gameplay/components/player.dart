import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Player extends PositionComponent {
  late List<ui.Image> _frames;
  int currentFrame = 0;
  bool _isLoaded = false;

  static const double rabbitWidth = 120;

  Player() : super(size: Vector2(rabbitWidth, rabbitWidth));

  @override
  Future<void> onLoad() async {
    await _loadFrames();
  }

  // Future<void> _loadFrames() async {
  //   _frames = [
  //     await Sprite(Image.asset('player/rabbit1.png')),
  //     // await Sprite.load('player/rabbit2.png'),
  //     // await Sprite.load('player/rabbit3.png'),
  //     // await Sprite.load('player/rabbit4.png'),
  //   ];
  // }

  Future<void> _loadFrames() async {
    final image2 = await _loadImage('assets/images/player/rabbit1.png');
    _frames = [image2];
    _isLoaded = true;
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void render(Canvas canvas) {
    if (!_isLoaded || _frames.isEmpty) {
      // Affiche un rectangle rouge si l'image ne charge pas
      final paint = Paint()..color = const Color(0xFFFF0000);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
      return;
    }

    final image = _frames[currentFrame];
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: image,
      fit: BoxFit.contain,
    );
  }

  /// Change la frame pour l’animation (appelé par un Timer)
  void updateFrame() {
    currentFrame = (currentFrame + 1) % _frames.length;
  }

  /// Déplace le joueur vers l'avant (avec limite)
  void moveForward(double amount, double maxX) {
    position.x = (position.x + amount).clamp(0, maxX);
  }
}
