import 'package:flutter/material.dart';

class ResourceTransferAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final String assetPath;
  final int itemCount;
  final VoidCallback onAnimationComplete;

  const ResourceTransferAnimation({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.assetPath,
    this.itemCount = 10,
    required this.onAnimationComplete,
  });

  @override
  State<ResourceTransferAnimation> createState() => _ResourceTransferAnimationState();
}

class _ResourceTransferAnimationState extends State<ResourceTransferAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  int _completedAnimations = 0;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.itemCount, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + index * 100),
      );
    });

    _animations = List.generate(widget.itemCount, (index) {

      return Tween<Offset>(
        begin: widget.startPosition,
        end: widget.endPosition,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOutBack,
        ),
      );
    });

    // Démarrer les animations
    for (int i = 0; i < widget.itemCount; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
            if (mounted) {
                _controllers[i].forward().then((_) {
                    _completedAnimations++;
                    if (_completedAnimations == widget.itemCount) {
                        widget.onAnimationComplete();
                    }
                });
            }
        });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.itemCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            final value = _controllers[index].value;

            Offset currentPos = _animations[index].value;
            
            // Ajouter un arc/courbe
            final double arcHeight = 100.0 * (1 - value) * value * 4;
             // Ajouter une déviation basée sur l'index
             final deviationX = (index % 3 - 1) * 50.0 * (1 - value) * value * 4;

            return Positioned(
              left: currentPos.dx + deviationX,
              top: currentPos.dy - arcHeight,
              child: Opacity(
                opacity: value < 0.1 ? value * 10 : (value > 0.9 ? (1-value)*10 : 1.0),
                child: Transform.scale(
                   scale: 0.5 + (value < 0.5 ? value : (1-value)),
                   child: Image.asset(widget.assetPath, width: 24, height: 24),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
