import 'package:flutter/material.dart';

import 'package:word_riders/features/ui/widgets/common/main_layout.dart';

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

  // Démarre une animation de transfert de ressources d'un widget source vers une cible.
  //
  // [startKey] est le widget d'où part l'animation.
  // [endKey] (optionnel) est un widget cible spécifique.
  // [endOffset] (optionnel) est une position cible spécifique si aucune clé de widget n'est disponible.
  // Si ni [endKey] ni [endOffset] n'est fourni, il tente de trouver les cibles standard (Coin/Heart) dans [MainLayout].
  static void start(
    BuildContext context, {
    required GlobalKey startKey,
    required String assetPath,
    GlobalKey? endKey,
    Offset? endOffset,
    VoidCallback? onComplete,
  }) {
    // 1. Trouver la position de départ
    final RenderBox? box = startKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      onComplete?.call();
      return;
    }

    // Position globale sur l'écran
    final Offset startPos = box.localToGlobal(box.size.center(Offset.zero));

    // 2. Trouver la position de fin
    double endX = 0;
    double endY = 0;
    bool endFound = false;

    // A. Priorité : Clé de fin explicite
    if (endKey != null) {
       final RenderBox? targetBox = endKey.currentContext?.findRenderObject() as RenderBox?;
       if (targetBox != null) {
          final center = targetBox.localToGlobal(targetBox.size.center(Offset.zero));
          endX = center.dx;
          endY = center.dy;
          endFound = true;
       }
    }

    // B. Offset explicite
    if (!endFound && endOffset != null) {
       endX = endOffset.dx;
       endY = endOffset.dy;
       endFound = true;
    }

    // C. Fallback: MainLayout (Comportement standard)
    if (!endFound) {
      final mainState = context.findAncestorStateOfType<MainLayoutState>();
      // Fallback par défaut
      endX = MediaQuery.of(context).size.width - 60;
      endY = 60;

      if (mainState != null) {
        final bool isHeart = assetPath.contains('heart');
        final targetContext = isHeart ? mainState.lifeIndicatorContext : mainState.coinIndicatorContext;

        if (targetContext != null) {
          final RenderBox? targetBox = targetContext.findRenderObject() as RenderBox?;
          if (targetBox != null) {
            final center = targetBox.localToGlobal(targetBox.size.center(Offset.zero));
            endX = center.dx;
            endY = center.dy;
          }
        }
      }
    }

    // 3. Lancement de l'animation via Overlay ROOT
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => ResourceTransferAnimation(
        startPosition: startPos,
        endPosition: Offset(endX, endY),
        assetPath: assetPath,
        itemCount: 8,
        onAnimationComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(entry);
  }

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
