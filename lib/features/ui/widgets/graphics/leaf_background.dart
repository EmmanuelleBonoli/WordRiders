import 'dart:math';
import 'package:flutter/material.dart';

class LeafBackground extends StatefulWidget {
  final Color backgroundColor;
  final Color leafColor;
  final int leafCount;
  final Widget? child;

  const LeafBackground({
    super.key,
    this.backgroundColor = Colors.transparent,
    required this.leafColor,
    this.leafCount = 25,
    this.child,
  });

  @override
  State<LeafBackground> createState() => _LeafBackgroundState();
}

class _LeafBackgroundState extends State<LeafBackground> {
  final List<Map<String, double>> _leaves = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateLeaves();
  }

  void _generateLeaves() {
    _leaves.clear();
    for (int i = 0; i < widget.leafCount; i++) {
      _leaves.add({
        'x': _random.nextDouble(), 
        'y': _random.nextDouble(),
        'angle': _random.nextDouble() * 2 * pi,
        'size': 20 + _random.nextDouble() * 40, 
        'opacity': 0.15 + _random.nextDouble() * 0.20, 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: CustomPaint(
        painter: _LeafPainter(
          leaves: _leaves,
          baseColor: widget.leafColor,
        ),
        child: widget.child ?? Container(),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final List<Map<String, double>> leaves;
  final Color baseColor;

  _LeafPainter({required this.leaves, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    for (final leaf in leaves) {
        final double x = leaf['x']! * size.width;
        final double y = leaf['y']! * size.height;
        final double angle = leaf['angle']!;
        final double s = leaf['size']!;
        final double opacity = leaf['opacity']!;
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(Icons.eco_rounded.codePoint),
            style: TextStyle(
              fontSize: s,
              fontFamily: Icons.eco_rounded.fontFamily,
              color: baseColor.withValues(alpha: opacity),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle);
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
