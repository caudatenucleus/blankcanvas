import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Waterfall chart data.
class WaterfallData {
  const WaterfallData({
    required this.label,
    required this.value,
    this.isTotal = false,
  });
  final String label;
  final double value;
  final bool isTotal;
}

/// A waterfall chart widget.
class WaterfallChart extends LeafRenderObjectWidget {
  const WaterfallChart({
    super.key,
    required this.data,
    this.onBarTap,
    this.positiveColor = const Color(0xFF4CAF50),
    this.negativeColor = const Color(0xFFE53935),
    this.totalColor = const Color(0xFF2196F3),
    this.tag,
  });

  final List<WaterfallData> data;
  final void Function(WaterfallData bar)? onBarTap;
  final Color positiveColor;
  final Color negativeColor;
  final Color totalColor;
  final String? tag;

  @override
  RenderWaterfallChart createRenderObject(BuildContext context) {
    return RenderWaterfallChart(
      data: data,
      onBarTap: onBarTap,
      positiveColor: positiveColor,
      negativeColor: negativeColor,
      totalColor: totalColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWaterfallChart renderObject,
  ) {
    renderObject
      ..data = data
      ..onBarTap = onBarTap
      ..positiveColor = positiveColor
      ..negativeColor = negativeColor
      ..totalColor = totalColor;
  }
}

class RenderWaterfallChart extends RenderBox {
  RenderWaterfallChart({
    required List<WaterfallData> data,
    void Function(WaterfallData bar)? onBarTap,
    required Color positiveColor,
    required Color negativeColor,
    required Color totalColor,
  }) : _data = data,
       _onBarTap = onBarTap,
       _positiveColor = positiveColor,
       _negativeColor = negativeColor,
       _totalColor = totalColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<WaterfallData> _data;
  set data(List<WaterfallData> value) {
    _data = value;
    markNeedsPaint();
  }

  void Function(WaterfallData bar)? _onBarTap;
  set onBarTap(void Function(WaterfallData bar)? value) => _onBarTap = value;

  Color _positiveColor;
  set positiveColor(Color value) => _positiveColor = value;

  Color _negativeColor;
  set negativeColor(Color value) => _negativeColor = value;

  Color _totalColor;
  set totalColor(Color value) => _totalColor = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const double _padding = 50.0;

  final List<Rect> _barRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _barRects.clear();
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
      size.height - 70,
    );

    // Calculate cumulative values
    final cumulativeValues = <double>[0];
    double running = 0;
    for (final item in _data) {
      if (item.isTotal) {
        cumulativeValues.add(item.value);
        running = item.value;
      } else {
        running += item.value;
        cumulativeValues.add(running);
      }
    }

    final minValue = cumulativeValues.reduce(math.min);
    final maxValue = cumulativeValues.reduce(math.max);
    final range = maxValue - minValue;

    // Grid
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final value = maxValue - range * i / 5;
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

    // Bars
    final barWidth = chartRect.width / _data.length;
    double runningTotal = 0;

    for (int i = 0; i < _data.length; i++) {
      final item = _data[i];
      final centerX = chartRect.left + barWidth * (i + 0.5);
      final width = barWidth * 0.7;
      final isHovered = _hoveredIndex == i;

      double toY(double value) =>
          chartRect.top + (maxValue - value) / range * chartRect.height;

      double barStart, barEnd;
      Color color;

      if (item.isTotal) {
        barStart = 0;
        barEnd = item.value;
        color = _totalColor;
        runningTotal = item.value;
      } else {
        barStart = runningTotal;
        barEnd = runningTotal + item.value;
        color = item.value >= 0 ? _positiveColor : _negativeColor;
        runningTotal = barEnd;
      }

      final top = toY(math.max(barStart, barEnd));
      final bottom = toY(math.min(barStart, barEnd));
      final barRect = Rect.fromLTRB(
        centerX - width / 2,
        top,
        centerX + width / 2,
        bottom,
      );

      _barRects.add(
        Rect.fromLTRB(
          centerX - width / 2 - offset.dx,
          top - offset.dy,
          centerX + width / 2 - offset.dx,
          bottom - offset.dy,
        ),
      );

      canvas.drawRect(
        barRect,
        Paint()..color = isHovered ? color : color.withValues(alpha: 0.85),
      );

      // Connector line
      if (i < _data.length - 1 && !_data[i + 1].isTotal) {
        final nextX = centerX + barWidth;
        canvas.drawLine(
          Offset(centerX + width / 2, toY(runningTotal)),
          Offset(nextX - width / 2, toY(runningTotal)),
          Paint()
            ..color = const Color(0xFF999999)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      }

      // Value label
      textPainter.text = TextSpan(
        text: item.value >= 0
            ? '+${item.value.toStringAsFixed(0)}'
            : item.value.toStringAsFixed(0),
        style: TextStyle(
          fontSize: 9,
          color: item.isTotal ? _totalColor : color,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, top - textPainter.height - 2),
      );

      // Label
      textPainter.text = TextSpan(
        text: item.label,
        style: const TextStyle(fontSize: 9, color: Color(0xFF333333)),
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
    for (int i = 0; i < _barRects.length; i++) {
      if (_barRects[i].contains(local)) {
        _onBarTap?.call(_data[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _barRects.length; i++) {
      if (_barRects[i].contains(local)) {
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
