import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A sunburst chart segment.
class SunburstSegment {
  const SunburstSegment({
    required this.label,
    required this.value,
    this.children = const [],
    this.color,
  });
  final String label;
  final double value;
  final List<SunburstSegment> children;
  final Color? color;
}

/// A sunburst chart widget.
class SunburstChart extends LeafRenderObjectWidget {
  const SunburstChart({
    super.key,
    required this.data,
    this.onSegmentTap,
    this.tag,
  });

  final SunburstSegment data;
  final void Function(SunburstSegment segment)? onSegmentTap;
  final String? tag;

  @override
  RenderSunburstChart createRenderObject(BuildContext context) {
    return RenderSunburstChart(data: data, onSegmentTap: onSegmentTap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSunburstChart renderObject,
  ) {
    renderObject
      ..data = data
      ..onSegmentTap = onSegmentTap;
  }
}

class RenderSunburstChart extends RenderBox {
  RenderSunburstChart({
    required SunburstSegment data,
    void Function(SunburstSegment segment)? onSegmentTap,
  }) : _data = data,
       _onSegmentTap = onSegmentTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  SunburstSegment _data;
  set data(SunburstSegment value) {
    _data = value;
    markNeedsPaint();
  }

  void Function(SunburstSegment segment)? _onSegmentTap;
  set onSegmentTap(void Function(SunburstSegment segment)? value) =>
      _onSegmentTap = value;

  late TapGestureRecognizer _tap;
  String? _hoveredLabel;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF3F51B5),
    Color(0xFFCDDC39),
  ];

  final List<_SegmentPath> _segmentPaths = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final double minDim = math.min(
      constraints.maxWidth,
      constraints.maxHeight.clamp(200, 400),
    );
    size = constraints.constrain(Size(minDim, minDim));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    _segmentPaths.clear();

    final center = offset + Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 20;

    // Center circle
    canvas.drawCircle(center, 30, Paint()..color = const Color(0xFFEEEEEE));

    // Draw segments
    _drawLevel(
      canvas,
      center,
      _data.children,
      0,
      2 * math.pi,
      40,
      maxRadius / 3,
      0,
    );
  }

  void _drawLevel(
    Canvas canvas,
    Offset center,
    List<SunburstSegment> segments,
    double startAngle,
    double sweepAngle,
    double innerRadius,
    double thickness,
    int level,
  ) {
    if (segments.isEmpty || level > 3) return;

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    double angle = startAngle;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final segmentSweep = (segment.value / total) * sweepAngle;
      final color = segment.color ?? _colors[(i + level * 3) % _colors.length];
      final isHovered = _hoveredLabel == segment.label;

      final outerRadius = innerRadius + thickness;
      final path = _createArcPath(
        center,
        innerRadius,
        outerRadius,
        angle,
        segmentSweep,
      );

      _segmentPaths.add(_SegmentPath(path, segment));

      canvas.drawPath(
        path,
        Paint()
          ..color = isHovered
              ? color
              : color.withValues(alpha: 0.85 - level * 0.1),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = 1,
      );

      // Label
      if (segmentSweep > 0.2 && thickness > 20) {
        final labelAngle = angle + segmentSweep / 2;
        final labelRadius = innerRadius + thickness / 2;
        final labelPos =
            center +
            Offset(
              math.cos(labelAngle) * labelRadius,
              math.sin(labelAngle) * labelRadius,
            );

        textPainter.text = TextSpan(
          text: segment.label,
          style: TextStyle(
            fontSize: 9.0 - level,
            color: const Color(0xFFFFFFFF),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      // Recurse children
      if (segment.children.isNotEmpty) {
        _drawLevel(
          canvas,
          center,
          segment.children,
          angle,
          segmentSweep,
          outerRadius,
          thickness * 0.8,
          level + 1,
        );
      }

      angle += segmentSweep;
    }
  }

  Path _createArcPath(
    Offset center,
    double innerRadius,
    double outerRadius,
    double startAngle,
    double sweepAngle,
  ) {
    final path = Path();

    // Outer arc
    path.arcTo(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      sweepAngle,
      true,
    );

    // Inner arc (reverse)
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle + sweepAngle,
      -sweepAngle,
      false,
    );

    path.close();
    return path;
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (final sp in _segmentPaths) {
      if (sp.path.contains(local)) {
        _onSegmentTap?.call(sp.segment);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    String? hovered;
    for (final sp in _segmentPaths) {
      if (sp.path.contains(local)) {
        hovered = sp.segment.label;
        break;
      }
    }
    if (_hoveredLabel != hovered) {
      _hoveredLabel = hovered;
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

class _SegmentPath {
  _SegmentPath(this.path, this.segment);
  final Path path;
  final SunburstSegment segment;
}
