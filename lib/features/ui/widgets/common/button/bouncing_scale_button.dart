import 'package:flutter/material.dart';
import 'package:word_riders/data/audio_data.dart';
import 'package:word_riders/features/gameplay/services/audio_service.dart';
class BouncingScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleTarget;
  final bool showShadow;

  const BouncingScaleButton({
    super.key, 
    required this.child, 
    required this.onTap,
    this.scaleTarget = 0.92,
    this.showShadow = true,
  });

  @override
  State<BouncingScaleButton> createState() => _BouncingScaleButtonState();
}

class _BouncingScaleButtonState extends State<BouncingScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: widget.scaleTarget).animate(_controller);
    _offset = Tween<double>(begin: 4.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    AudioService().playSfx(AudioData.sfxButtonPress);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.showShadow)
                  Positioned(
                    top: _offset.value,
                    bottom: -_offset.value, 
                    left: 2, right: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                
                Transform.translate(
                  offset: widget.showShadow 
                      ? Offset(0, _offset.value > 0 ? 0 : 2)
                      : Offset.zero, // Pas de décalage vertical si pas d'ombre 3D simulée
                  child: widget.child,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
