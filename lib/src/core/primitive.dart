import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// A widget that demonstrates the absolute lowest level of drawing in the framework.
///
/// It bypasses [CustomPainter] and uses a raw [RenderBox] to talk to the [Canvas].
class PrimitiveDrawing extends LeafRenderObjectWidget {
  const PrimitiveDrawing({
    super.key,
    required this.color,
    this.strokeWidth = 5.0,
  });

  final Color color;
  final double strokeWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPrimitive(color: color, strokeWidth: strokeWidth);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderPrimitive renderObject,
  ) {
    renderObject
      ..color = color
      ..strokeWidth = strokeWidth;
  }
}

class RenderPrimitive extends RenderBox {
  RenderPrimitive({required Color color, required double strokeWidth})
    : _color = color,
      _strokeWidth = strokeWidth;

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double _strokeWidth;
  double get strokeWidth => _strokeWidth;
  set strokeWidth(double value) {
    if (_strokeWidth == value) return;
    _strokeWidth = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    // A RenderBox must always decide its own size based on constraints
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // context.canvas gives us the dart:ui Canvas primitive
    final ui.Canvas canvas = context.canvas;

    // We create a dart:ui Paint primitive
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = ui.PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    // Drawing a complex mathematical pattern directly
    final ui.Path path = ui.Path();

    // Create a "Star" pattern by calculating points manually
    const int points = 5;
    final double centerX = offset.dx + width / 2;
    final double centerY = offset.dy + height / 2;
    final double outerRadius = (width < height ? width : height) / 2;
    final double innerRadius = outerRadius / 2.5;

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double angle = (i * 360 / (points * 2)) * (math.pi / 180);
      final double x = centerX + radius * math.cos(angle);
      final double y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // The Engine command
    canvas.drawPath(path, paint);

    // Draw circles at each point to show secondary primitive usage
    final ui.Paint dotPaint = ui.Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = ui.PaintingStyle.fill;

    canvas.drawCircle(ui.Offset(centerX, centerY), innerRadius / 2, dotPaint);
  }
}
