import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShinyCornerEffect extends StatelessWidget {
  final bool isCircle;
  final BorderRadius? borderRadius;
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double padding;
  final double blurSigma;

  const ShinyCornerEffect({
    super.key,
    this.isCircle = false,
    this.borderRadius,
    this.color = Colors.white,
    this.strokeWidth = 1.0,
    this.cornerLength = 15.0,
    this.padding = 4.0,
    this.blurSigma = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ShinyCornerPainter(
          isCircle: isCircle,
          borderRadius: borderRadius,
          color: color,
          strokeWidth: strokeWidth,
          cornerLength: cornerLength,
          padding: padding,
          blurSigma: blurSigma,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ShinyCornerPainter extends CustomPainter {
  final bool isCircle;
  final BorderRadius? borderRadius;
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double padding;
  final double blurSigma;

  _ShinyCornerPainter({
    required this.isCircle,
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.padding,
    required this.blurSigma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    if (isCircle) {
      _drawCircleCorners(canvas, size, paint);
    } else {
      _drawRRectCorners(canvas, size, paint);
    }
  }

  void _drawCircleCorners(Canvas canvas, Size size, Paint paint) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    // Appliquer le padding
    final adjustedRadius = radius - padding;
    if (adjustedRadius <= 0) return;
    
    final rect = Rect.fromCircle(center: center, radius: adjustedRadius);

    // Calcul des angles basés sur cornerLength (pixels)
    // Convertir les longueurs en pixels en radians: angle = arc / radius
    final double longDashAngle = cornerLength / adjustedRadius;
    final double smallDashAngle = longDashAngle * 0.3; // Le petit tiret fait 30% du long
    final double gapAngle = longDashAngle * 0.25;      // Gap is 25% of long
    
    final totalSpan = smallDashAngle + gapAngle + longDashAngle;
    
    // COIN HAUT-GAUCHE (Centré autour de -135 degrés / -3pi/4)
    const double centerTL = -math.pi * 0.75;
    final double startAngleTL = centerTL - totalSpan / 2;

    // Petit trait
    canvas.drawArc(rect, startAngleTL, smallDashAngle, false, paint);
    // Long trait
    canvas.drawArc(rect, startAngleTL + smallDashAngle + gapAngle, longDashAngle, false, paint);

    // COIN BAS-DROITE (Centré autour de 45 degrés / pi/4)
    const double centerBR = math.pi * 0.25;
    final double startAngleBR = centerBR - totalSpan / 2;
    
    canvas.drawArc(rect, startAngleBR, smallDashAngle, false, paint);
    canvas.drawArc(rect, startAngleBR + smallDashAngle + gapAngle, longDashAngle, false, paint);
  }

  void _drawRRectCorners(Canvas canvas, Size size, Paint paint) {
    final rTL = borderRadius?.topLeft ?? Radius.zero;
    final rBR = borderRadius?.bottomRight ?? Radius.zero;
    
    // Configuration
    const double smallDash = 0.15;
    const double gap = 0.4;
    const double longDash = 0.5;

    // HAUT-GAUCHE
    if (rTL != Radius.zero) {
        final outerRect = Rect.fromLTWH(0, 0, rTL.x * 2, rTL.y * 2);
        final rect = outerRect.deflate(padding);

        if (rect.width > 0 && rect.height > 0) {
             const double midAngle = -math.pi * 0.75;
             final double startAngle = midAngle - (smallDash + gap + longDash) / 2;
             
             canvas.drawArc(rect, startAngle, smallDash, false, paint);
             canvas.drawArc(rect, startAngle + smallDash + gap, longDash, false, paint);
        }
    } else {
        // Coin carré : Dessin manuel de deux segments
        // Segment Vertical (Court)
        canvas.drawLine(
            Offset(padding, padding + 14), 
            Offset(padding, padding + 8), 
            paint
        ); 
        
        // Segment Horizontal (Long)
        canvas.drawLine(
            Offset(padding + 8, padding), 
            Offset(padding + 25, padding), 
            paint
        );
    }

    // BAS-DROITE
    if (rBR != Radius.zero) {
        final outerRect = Rect.fromLTWH(
            size.width - rBR.x * 2, 
            size.height - rBR.y * 2, 
            rBR.x * 2, 
            rBR.y * 2
        );
        final rect = outerRect.deflate(padding);
        
        if (rect.width > 0 && rect.height > 0) {
             const double midAngle = math.pi * 0.25;
             final double startAngle = midAngle - (smallDash + gap + longDash) / 2;
             
             canvas.drawArc(rect, startAngle, smallDash, false, paint);
             canvas.drawArc(rect, startAngle + smallDash + gap, longDash, false, paint);
        }
    } else {
         // Coin carré BAS-DROITE
         // Vertical (Court)
         canvas.drawLine(
             Offset(size.width - padding, size.height - padding - 14),
             Offset(size.width - padding, size.height - padding - 8),
             paint
         );
         
         // Horizontal (Long)
         canvas.drawLine(
             Offset(size.width - padding - 8, size.height - padding),
             Offset(size.width - padding - 25, size.height - padding),
             paint
         );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
