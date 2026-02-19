import 'package:flutter/material.dart';

class PulsingWidget extends StatefulWidget {
  final Widget child;
  final double scaleFactor;
  final Duration duration;

  const PulsingWidget({
    super.key,
    required this.child,
    this.scaleFactor = 0.08,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curvedValue = Curves.easeInOutSine.transform(_controller.value);
        final scale = 1.0 + (curvedValue * widget.scaleFactor);
        return Transform.scale(
          scale: scale,
          filterQuality: FilterQuality.medium,
          child: RepaintBoundary(child: child),
        );
      },
      child: widget.child,
    );
  }
}
