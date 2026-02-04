import 'package:flutter/material.dart';
import 'shiny_corner_effect.dart';

class PushableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color? shadowColor;
  final Color? highlightColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double depth;

  const PushableButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.color,
    this.shadowColor,
    this.highlightColor,
    this.width,
    this.height,
    this.borderRadius,
    this.depth = 4.0,
  });

  @override
  State<PushableButton> createState() => _PushableButtonState();
}

class _PushableButtonState extends State<PushableButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  Color _darken(Color color, [double amount = 0.15]) {
    final hsl = HSLColor.fromColor(color);

    double hue = hsl.hue;
    double saturation = hsl.saturation;
    
    if (hue >= 30 && hue <= 90) {
      hue = (hue - 5).clamp(0.0, 360.0);
      saturation = (saturation + 0.1).clamp(0.0, 1.0);
    }
    
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
                       .withHue(hue)
                       .withSaturation(saturation);
    return hslDark.toColor();
  }

  Color _lighten(Color color, [double amount = 0.15]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final effectiveColor = isEnabled ? widget.color : Colors.grey;
    
    final shadowColor = isEnabled 
        ? (widget.shadowColor ?? _darken(effectiveColor, 0.2))
        : _darken(Colors.grey, 0.2);
        
    final topColor = isEnabled
        ? (widget.highlightColor ?? _lighten(effectiveColor, 0.1))
        : _lighten(Colors.grey, 0.1);
    
    // Config du relief
    final double depth = widget.depth;
    const double pressDepth = 2.0; 
    final currentOffset = _isPressed ? (depth - pressDepth) : 0.0;
    
    final radius = widget.borderRadius ?? BorderRadius.circular(24);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        width: widget.width,
        height: (widget.height ?? 64) + depth, 
        margin: const EdgeInsets.only(bottom: 4),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Couche du fond (Side/Shadow)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: currentOffset, 
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: radius,
                ),
              ),
            ),
            // Couche du dessus (Face)
            AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                top: currentOffset, 
                bottom: depth - currentOffset
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: effectiveColor,
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      topColor,
                      effectiveColor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      widthFactor: widget.width == null ? 1.0 : null,
                      child: widget.child,
                    ),
                    Positioned.fill(
                      child: ShinyCornerEffect(
                        borderRadius: radius,
                        color: Colors.white.withValues(alpha: 0.4),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Reflet brillant (Glossy effect)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              top: currentOffset + 4,
              left: 12,
              right: 12,
              height: (widget.height ?? 64) * 0.15,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(radius.topLeft.x / 2)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
