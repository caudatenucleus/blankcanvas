import 'package:flutter/rendering.dart';
import '../core/atoms/canvas_status.dart';

/// Abstract class for all decorations.
/// Separates Geometry and Paint.
abstract class CanvasDecoration {
  const CanvasDecoration();

  /// Defines the geometry (clipping, hit testing).
  Path getClipPath(Size size);

  /// Paints the decoration based on status.
  void paint(Canvas canvas, Size size, ControlStatus status);

  /// Insets for content (padding).
  EdgeInsets get padding => EdgeInsets.zero;
}

/// A simple box decoration example.
class CanvasBoxDecoration extends CanvasDecoration {
  const CanvasBoxDecoration({
    this.color = const Color(0xFF000000),
    this.borderRadius = 0.0,
  });

  final Color color;
  final double borderRadius;

  @override
  Path getClipPath(Size size) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(borderRadius),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size, ControlStatus status) {
    final Paint paint = Paint()..color = color;

    // Animate based on status?
    // "Automatically darken on press"
    if (status.isPressed) {
      paint.color = Color.lerp(color, const Color(0xFF000000), 0.2)!;
    } else if (status.isHovered) {
      paint.color = Color.lerp(color, const Color(0xFFFFFFFF), 0.1)!;
    } else if (status.isDisabled) {
      paint.color = color.withValues(alpha: 0.5);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(borderRadius),
      ),
      paint,
    );
  }
}
