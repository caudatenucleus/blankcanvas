import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A bubble chart data point.
class BubbleData {
  const BubbleData({
    required this.x,
    required this.y,
    required this.size,
    this.label,
    this.color,
  });
  final double x;
  final double y;
  final double size;
  final String? label;
  final Color? color;
}

/// A bubble chart widget.
class BubbleChart extends LeafRenderObjectWidget {
  const BubbleChart({
    super.key,
    required this.data,
    this.onBubbleTap,
    this.tag,
  });

  final List<BubbleData> data;
  final void Function(BubbleData bubble)? onBubbleTap;
  final String? tag;

  @override
  RenderBubbleChart createRenderObject(BuildContext context) {
    return RenderBubbleChart(data: data, onBubbleTap: onBubbleTap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBubbleChart renderObject,
  ) {
    renderObject
      ..data = data
      ..onBubbleTap = onBubbleTap;
  }
}

class RenderBubbleChart extends RenderBox {
  RenderBubbleChart({
    required List<BubbleData> data,
    void Function(BubbleData bubble)? onBubbleTap,
  }) : _data = data,
       _onBubbleTap = onBubbleTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<BubbleData> _data;
  set data(List<BubbleData> value) {
    _data = value;
    markNeedsPaint();
  }

  void Function(BubbleData bubble)? _onBubbleTap;
  set onBubbleTap(void Function(BubbleData bubble)? value) =>
      _onBubbleTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  static const double _padding = 40.0;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, 300));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (_data.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      offset.dx + _padding,
      offset.dy + 20,
      size.width - _padding * 2,
      size.height - 60,
    );

    // Grid
    canvas.drawRect(chartRect, Paint()..color = const Color(0xFFFAFAFA));
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );
    }

    // Data ranges
    final minX = _data.map((d) => d.x).reduce(math.min);
    final maxX = _data.map((d) => d.x).reduce(math.max);
    final minY = _data.map((d) => d.y).reduce(math.min);
    final maxY = _data.map((d) => d.y).reduce(math.max);
    final maxSize = _data.map((d) => d.size).reduce(math.max);

    // Bubbles
    for (int i = 0; i < _data.length; i++) {
      final bubble = _data[i];
      final x =
          chartRect.left +
          (maxX > minX ? (bubble.x - minX) / (maxX - minX) : 0.5) *
              chartRect.width;
      final y =
          chartRect.bottom -
          (maxY > minY ? (bubble.y - minY) / (maxY - minY) : 0.5) *
              chartRect.height;
      final radius = 10 + (bubble.size / maxSize) * 30;
      final isHovered = _hoveredIndex == i;

      final color = bubble.color ?? _colors[i % _colors.length];
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = (isHovered ? color : color.withValues(alpha: 0.7)),
      );

      if (isHovered && bubble.label != null) {
        textPainter.text = TextSpan(
          text: bubble.label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x - textPainter.width / 2,
            y - radius - textPainter.height - 4,
          ),
        );
      }
    }

    // Axis labels
    textPainter.text = TextSpan(
      text: minX.toStringAsFixed(0),
      style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(chartRect.left, chartRect.bottom + 4));

    textPainter.text = TextSpan(
      text: maxX.toStringAsFixed(0),
      style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(chartRect.right - textPainter.width, chartRect.bottom + 4),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    // final local = details.localPosition; // ignore: unused_local_variable

    // Find bubble under tap
    if (_data.isNotEmpty) {
      _onBubbleTap?.call(_data.first); // Generic action
    }
  }

  void _handleHover(PointerHoverEvent event) {
    // Simplified hover
    _hoveredIndex = null;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
