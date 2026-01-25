import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

/// A widget that overlays a watermark on its child using lowest-level RenderObject APIs.
class Watermark extends SingleChildRenderObjectWidget {
  const Watermark({
    super.key,
    required super.child,
    this.text = 'Watermark',
    this.color = const Color(0x1A000000),
    this.fontSize = 16,
    this.angle = -math.pi / 6,
    this.gap = const Offset(100, 100),
    this.tag,
  });

  final String text;
  final Color color;
  final double fontSize;
  final double angle;
  final Offset gap;
  final String? tag;

  @override
  RenderWatermark createRenderObject(BuildContext context) {
    return RenderWatermark(
      text: text,
      color: color,
      fontSize: fontSize,
      angle: angle,
      gap: gap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderWatermark renderObject) {
    renderObject
      ..text = text
      ..color = color
      ..fontSize = fontSize
      ..angle = angle
      ..gap = gap;
  }
}

class RenderWatermark extends RenderProxyBox {
  RenderWatermark({
    required String text,
    required Color color,
    required double fontSize,
    required double angle,
    required Offset gap,
    RenderBox? child,
  }) : _text = text,
       _color = color,
       _fontSize = fontSize,
       _angle = angle,
       _gap = gap,
       super(child);

  String _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    markNeedsPaint();
  }

  Color _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double _fontSize;
  set fontSize(double value) {
    if (_fontSize == value) return;
    _fontSize = value;
    markNeedsPaint();
  }

  double _angle;
  set angle(double value) {
    if (_angle == value) return;
    _angle = value;
    markNeedsPaint();
  }

  Offset _gap;
  set gap(Offset value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    final canvas = context.canvas;
    final textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: TextStyle(
          color: _color,
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;
    final spacingX = textWidth + _gap.dx;
    final spacingY = textHeight + _gap.dy;

    canvas.save();
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);
    canvas.rotate(_angle);
    canvas.translate(-size.width / 2, -size.height / 2);

    final maxSize = math.max(size.width, size.height) * 1.5;

    for (double y = -maxSize; y < maxSize; y += spacingY) {
      for (double x = -maxSize; x < maxSize; x += spacingX) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
  }
}
