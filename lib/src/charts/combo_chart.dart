import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Combo chart data with bars and line.
class ComboChartData {
  const ComboChartData({
    required this.label,
    required this.barValue,
    required this.lineValue,
  });
  final String label;
  final double barValue;
  final double lineValue;
}

/// A combo chart widget with bars and line.
class ComboChart extends LeafRenderObjectWidget {
  const ComboChart({
    super.key,
    required this.data,
    this.barColor = const Color(0xFF2196F3),
    this.lineColor = const Color(0xFFE91E63),
    this.onBarTap,
    this.tag,
  });

  final List<ComboChartData> data;
  final Color barColor;
  final Color lineColor;
  final void Function(ComboChartData item)? onBarTap;
  final String? tag;

  @override
  RenderComboChart createRenderObject(BuildContext context) {
    return RenderComboChart(
      data: data,
      barColor: barColor,
      lineColor: lineColor,
      onBarTap: onBarTap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderComboChart renderObject) {
    renderObject
      ..data = data
      ..barColor = barColor
      ..lineColor = lineColor
      ..onBarTap = onBarTap;
  }
}

class RenderComboChart extends RenderBox {
  RenderComboChart({
    required List<ComboChartData> data,
    required Color barColor,
    required Color lineColor,
    void Function(ComboChartData item)? onBarTap,
  }) : _data = data,
       _barColor = barColor,
       _lineColor = lineColor,
       _onBarTap = onBarTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<ComboChartData> _data;
  set data(List<ComboChartData> value) => _data = value;

  Color _barColor;
  set barColor(Color value) => _barColor = value;

  Color _lineColor;
  set lineColor(Color value) => _lineColor = value;

  void Function(ComboChartData item)? _onBarTap;
  set onBarTap(void Function(ComboChartData item)? value) => _onBarTap = value;

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
      size.height - 80,
    );

    // Max values
    final maxBar = _data.map((d) => d.barValue).reduce(math.max);
    final maxLine = _data.map((d) => d.lineValue).reduce(math.max);

    // Grid
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final barVal = maxBar - maxBar * i / 5;
      textPainter.text = TextSpan(
        text: barVal.toStringAsFixed(0),
        style: const TextStyle(fontSize: 9, color: Color(0xFF2196F3)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx + _padding - textPainter.width - 4,
          y - textPainter.height / 2,
        ),
      );

      final lineVal = maxLine - maxLine * i / 5;
      textPainter.text = TextSpan(
        text: lineVal.toStringAsFixed(0),
        style: const TextStyle(fontSize: 9, color: Color(0xFFE91E63)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx + size.width - _padding + 4,
          y - textPainter.height / 2,
        ),
      );
    }

    // Bars
    final barWidth = chartRect.width / _data.length;
    for (int i = 0; i < _data.length; i++) {
      final item = _data[i];
      final x = chartRect.left + barWidth * i + barWidth * 0.15;
      final barHeight = (item.barValue / maxBar) * chartRect.height;
      final barRect = Rect.fromLTWH(
        x,
        chartRect.bottom - barHeight,
        barWidth * 0.7,
        barHeight,
      );

      _barRects.add(
        Rect.fromLTWH(
          x - offset.dx,
          chartRect.bottom - barHeight - offset.dy,
          barWidth * 0.7,
          barHeight,
        ),
      );

      final isHovered = _hoveredIndex == i;
      canvas.drawRect(
        barRect,
        Paint()
          ..color = isHovered ? _barColor : _barColor.withValues(alpha: 0.7),
      );

      // Label
      textPainter.text = TextSpan(
        text: item.label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth * 0.35 - textPainter.width / 2,
          chartRect.bottom + 4,
        ),
      );
    }

    // Line
    final linePath = Path();
    for (int i = 0; i < _data.length; i++) {
      final item = _data[i];
      final x = chartRect.left + barWidth * (i + 0.5);
      final y =
          chartRect.bottom - (item.lineValue / maxLine) * chartRect.height;

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = _lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Line points
    for (int i = 0; i < _data.length; i++) {
      final item = _data[i];
      final x = chartRect.left + barWidth * (i + 0.5);
      final y =
          chartRect.bottom - (item.lineValue / maxLine) * chartRect.height;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = _lineColor);
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }

    // Legend
    final legendY = offset.dy + size.height - 20;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + _padding, legendY, 12, 12),
      Paint()..color = _barColor,
    );
    textPainter.text = const TextSpan(
      text: 'Bars',
      style: TextStyle(fontSize: 10, color: Color(0xFF333333)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx + _padding + 16, legendY));

    canvas.drawRect(
      Rect.fromLTWH(offset.dx + _padding + 60, legendY, 12, 12),
      Paint()..color = _lineColor,
    );
    textPainter.text = const TextSpan(
      text: 'Line',
      style: TextStyle(fontSize: 10, color: Color(0xFF333333)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx + _padding + 76, legendY));
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
