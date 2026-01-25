import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Box plot data.
class BoxPlotData {
  const BoxPlotData({
    required this.label,
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    this.outliers = const [],
  });
  final String label;
  final double min;
  final double q1;
  final double median;
  final double q3;
  final double max;
  final List<double> outliers;
}

/// A box plot widget.
class BoxPlot extends LeafRenderObjectWidget {
  const BoxPlot({
    super.key,
    required this.data,
    this.onBoxTap,
    this.color = const Color(0xFF2196F3),
    this.tag,
  });

  final List<BoxPlotData> data;
  final void Function(BoxPlotData box)? onBoxTap;
  final Color color;
  final String? tag;

  @override
  RenderBoxPlot createRenderObject(BuildContext context) {
    return RenderBoxPlot(data: data, onBoxTap: onBoxTap, color: color);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBoxPlot renderObject) {
    renderObject
      ..data = data
      ..onBoxTap = onBoxTap
      ..color = color;
  }
}

class RenderBoxPlot extends RenderBox {
  RenderBoxPlot({
    required List<BoxPlotData> data,
    void Function(BoxPlotData box)? onBoxTap,
    required Color color,
  }) : _data = data,
       _onBoxTap = onBoxTap,
       _color = color {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<BoxPlotData> _data;
  set data(List<BoxPlotData> value) {
    _data = value;
    markNeedsPaint();
  }

  void Function(BoxPlotData box)? _onBoxTap;
  set onBoxTap(void Function(BoxPlotData box)? value) => _onBoxTap = value;

  Color _color;
  set color(Color value) {
    _color = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const double _padding = 50.0;

  final List<Rect> _boxRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _boxRects.clear();
    size = constraints.constrain(Size(constraints.maxWidth, 250));
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

    // Find global min/max
    double globalMin = double.infinity;
    double globalMax = double.negativeInfinity;
    for (final box in _data) {
      globalMin = math.min(globalMin, box.min);
      globalMax = math.max(globalMax, box.max);
      for (final o in box.outliers) {
        globalMin = math.min(globalMin, o);
        globalMax = math.max(globalMax, o);
      }
    }

    // Grid lines
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final value = globalMax - (globalMax - globalMin) * i / 5;
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(0),
        style: const TextStyle(fontSize: 9, color: Color(0xFF666666)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx + _padding - textPainter.width - 4,
          y - textPainter.height / 2,
        ),
      );
    }

    // Boxes
    final boxWidth = chartRect.width / _data.length;
    for (int i = 0; i < _data.length; i++) {
      final box = _data[i];
      final centerX = chartRect.left + boxWidth * (i + 0.5);
      final width = boxWidth * 0.6;
      final isHovered = _hoveredIndex == i;

      double toY(double value) =>
          chartRect.bottom -
          (value - globalMin) / (globalMax - globalMin) * chartRect.height;

      final minY = toY(box.min);
      final q1Y = toY(box.q1);
      final medianY = toY(box.median);
      final q3Y = toY(box.q3);
      final maxY = toY(box.max);

      // Whiskers
      canvas.drawLine(
        Offset(centerX, minY),
        Offset(centerX, q1Y),
        Paint()
          ..color = _color
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(centerX, q3Y),
        Offset(centerX, maxY),
        Paint()
          ..color = _color
          ..strokeWidth = 2,
      );

      // Min/max caps
      canvas.drawLine(
        Offset(centerX - width / 4, minY),
        Offset(centerX + width / 4, minY),
        Paint()
          ..color = _color
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(centerX - width / 4, maxY),
        Offset(centerX + width / 4, maxY),
        Paint()
          ..color = _color
          ..strokeWidth = 2,
      );

      // Box
      final boxRect = Rect.fromLTRB(
        centerX - width / 2,
        q3Y,
        centerX + width / 2,
        q1Y,
      );
      _boxRects.add(
        Rect.fromLTRB(
          centerX - width / 2 - offset.dx,
          q3Y - offset.dy,
          centerX + width / 2 - offset.dx,
          q1Y - offset.dy,
        ),
      );
      canvas.drawRect(
        boxRect,
        Paint()..color = isHovered ? _color : _color.withValues(alpha: 0.7),
      );
      canvas.drawRect(
        boxRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = _color
          ..strokeWidth = 2,
      );

      // Median line
      canvas.drawLine(
        Offset(centerX - width / 2, medianY),
        Offset(centerX + width / 2, medianY),
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = 2,
      );

      // Outliers
      for (final outlier in box.outliers) {
        final y = toY(outlier);
        canvas.drawCircle(
          Offset(centerX, y),
          4,
          Paint()
            ..color = _color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // Label
      textPainter.text = TextSpan(
        text: box.label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, chartRect.bottom + 4),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _boxRects.length; i++) {
      if (_boxRects[i].contains(local)) {
        _onBoxTap?.call(_data[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _boxRects.length; i++) {
      if (_boxRects[i].contains(local)) {
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
