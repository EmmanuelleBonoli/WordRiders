import 'package:flutter/material.dart';

import 'package:word_riders/features/ui/animations/resource_transfer_animation.dart';

class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  OverlayEntry? _overlayEntry;

  void showCoinAnimation({
    required BuildContext context,
    required Offset startPosition,
    required Offset endPosition,
    required VoidCallback onComplete,
    int amount = 10,
  }) {
    _showAnimation(
      context: context,
      start: startPosition,
      end: endPosition,
      asset: 'assets/images/indicators/coin.png',
      count: amount.clamp(5, 20),
      onComplete: onComplete,
    );
  }

  void showLifeAnimation({
    required BuildContext context,
    required Offset startPosition,
    required Offset endPosition,
    required VoidCallback onComplete,
    int amount = 5,
  }) {
    _showAnimation(
      context: context,
      start: startPosition,
      end: endPosition,
      asset: 'assets/images/indicators/heart.png',
      count: amount.clamp(3, 10),
      onComplete: onComplete,
    );
  }

  void _showAnimation({
    required BuildContext context,
    required Offset start,
    required Offset end,
    required String asset,
    required int count,
    required VoidCallback onComplete,
  }) {
    final entry = OverlayEntry(
      builder: (context) => ResourceTransferAnimation(
        startPosition: start,
        endPosition: end,
        assetPath: asset,
        itemCount: count,
        onAnimationComplete: () {
          _removeOverlay();
          onComplete();
        },
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(entry);
    _overlayEntry = entry;
  }

   void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
