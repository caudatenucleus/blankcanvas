import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A data point for the pie chart.
class PieChartData {
  const PieChartData({required this.value, required this.color, this.label});
  final double value;
  final Color color;
  final String? label;
}

/// A pie chart visualization.
class PieChart extends LeafRenderObjectWidget {
  const PieChart({
    super.key,
    required this.data,
    this.donut = false,
    this.donutRadius = 0.5,
    this.onSegmentTap,
    this.tag,
  });

  final List<PieChartData> data;
  final bool donut;
  final double donutRadius;
  final void Function(int index)? onSegmentTap;
  final String? tag;

  @override
  RenderPieChart createRenderObject(BuildContext context) {
    return RenderPieChart(
      data: data,
      donut: donut,
      donutRadius: donutRadius,
      onSegmentTap: onSegmentTap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPieChart renderObject) {
    renderObject
      ..data = data
      ..donut = donut
      ..donutRadius = donutRadius
      ..onSegmentTap = onSegmentTap;
  }
}

class RenderPieChart extends RenderBox {
  RenderPieChart({
    required List<PieChartData> data,
    required bool donut,
    required double donutRadius,
    void Function(int index)? onSegmentTap,
  }) : _data = data,
       _donut = donut,
       _donutRadius = donutRadius,
       _onSegmentTap = onSegmentTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<PieChartData> _data;
  set data(List<PieChartData> value) {
    _data = value;
    markNeedsPaint();
  }

  bool _donut;
  set donut(bool value) {
    _donut = value;
    markNeedsPaint();
  }

  double _donutRadius;
  set donutRadius(double value) {
    _donutRadius = value;
    markNeedsPaint();
  }

  void Function(int index)? _onSegmentTap;
  set onSegmentTap(void Function(int index)? value) => _onSegmentTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  final List<_PieSegment> _segments = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxWidth),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    _segments.clear();

    if (_data.isEmpty) return;

    final center = offset + Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final total = _data.fold<double>(0, (sum, d) => sum + d.value);

    double startAngle = -math.pi / 2;
    for (int i = 0; i < _data.length; i++) {
      final d = _data[i];
      final sweepAngle = (d.value / total) * 2 * math.pi;
      final isHovered = _hoveredIndex == i;

      // Calculate segment path
      final segmentRadius = isHovered ? radius + 5 : radius;
      final innerRadius = _donut ? segmentRadius * _donutRadius : 0.0;

      final path = Path();
      final outerRect = Rect.fromCircle(center: center, radius: segmentRadius);

      if (_donut) {
        final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
        path.arcTo(outerRect, startAngle, sweepAngle, true);
        path.arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false);
        path.close();
      } else {
        path.moveTo(center.dx, center.dy);
        path.arcTo(outerRect, startAngle, sweepAngle, false);
        path.close();
      }

      _segments.add(
        _PieSegment(path: path, startAngle: startAngle, sweepAngle: sweepAngle),
      );

      canvas.drawPath(path, Paint()..color = d.color);

      // Draw label
      if (d.label != null) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.7;
        final labelPos =
            center +
            Offset(
              math.cos(labelAngle) * labelRadius,
              math.sin(labelAngle) * labelRadius,
            );

        final textPainter = TextPainter(
          text: TextSpan(
            text: d.label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }
  }

  int? _getSegmentAt(Offset position) {
    for (int i = 0; i < _segments.length; i++) {
      if (_segments[i].path.contains(position)) {
        return i;
      }
    }
    return null;
  }

  void _handleTapUp(TapUpDetails details) {
    final index = _getSegmentAt(details.localPosition);
    if (index != null) {
      _onSegmentTap?.call(index);
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final index = _getSegmentAt(event.localPosition);
    if (_hoveredIndex != index) {
      _hoveredIndex = index;
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

class _PieSegment {
  _PieSegment({
    required this.path,
    required this.startAngle,
    required this.sweepAngle,
  });
  final Path path;
  final double startAngle;
  final double sweepAngle;
}
