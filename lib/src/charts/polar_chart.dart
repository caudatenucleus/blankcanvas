import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A polar chart data point.
class PolarData {
  const PolarData({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

/// A polar chart widget.
class PolarChart extends LeafRenderObjectWidget {
  const PolarChart({
    super.key,
    required this.data,
    this.onSegmentTap,
    this.tag,
  });

  final List<PolarData> data;
  final void Function(PolarData segment)? onSegmentTap;
  final String? tag;

  @override
  RenderPolarChart createRenderObject(BuildContext context) {
    return RenderPolarChart(data: data, onSegmentTap: onSegmentTap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderPolarChart renderObject) {
    renderObject
      ..data = data
      ..onSegmentTap = onSegmentTap;
  }
}

class RenderPolarChart extends RenderBox {
  RenderPolarChart({
    required List<PolarData> data,
    void Function(PolarData segment)? onSegmentTap,
  }) : _data = data,
       _onSegmentTap = onSegmentTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<PolarData> _data;
  set data(List<PolarData> value) {
    _data = value;
    markNeedsPaint();
  }

  void Function(PolarData segment)? _onSegmentTap;
  set onSegmentTap(void Function(PolarData segment)? value) =>
      _onSegmentTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  final List<Path> _segmentPaths = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final double dim = math.min(
      constraints.maxWidth,
      constraints.maxHeight.clamp(200, 300),
    );
    size = constraints.constrain(Size(dim, dim));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    _segmentPaths.clear();

    if (_data.isEmpty) return;

    final center = offset + Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 30;
    final maxValue = _data.map((d) => d.value).reduce(math.max);
    final angleStep = 2 * math.pi / _data.length;

    // Grid circles
    for (int i = 1; i <= 4; i++) {
      final r = maxRadius * i / 4;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFEEEEEE),
      );
    }

    // Segments
    for (int i = 0; i < _data.length; i++) {
      final item = _data[i];
      final startAngle = angleStep * i - math.pi / 2;
      final radius = (item.value / maxValue) * maxRadius;
      final isHovered = _hoveredIndex == i;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          angleStep - 0.02,
          false,
        )
        ..close();

      _segmentPaths.add(path);

      final color = item.color ?? _colors[i % _colors.length];
      canvas.drawPath(
        path,
        Paint()..color = isHovered ? color : color.withValues(alpha: 0.8),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = 1,
      );

      // Label
      final labelAngle = startAngle + angleStep / 2;
      final labelRadius = maxRadius + 15;
      final labelPos =
          center +
          Offset(
            math.cos(labelAngle) * labelRadius,
            math.sin(labelAngle) * labelRadius,
          );

      textPainter.text = TextSpan(
        text: item.label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _segmentPaths.length; i++) {
      if (_segmentPaths[i].contains(local)) {
        _onSegmentTap?.call(_data[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _segmentPaths.length; i++) {
      if (_segmentPaths[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredIndex != hovered) {
      _hoveredIndex = hovered;
      markNeedsPaint();
    }
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
