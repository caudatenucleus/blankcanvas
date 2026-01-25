import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A data point for the bar chart.
class BarChartData {
  const BarChartData({required this.value, this.label, this.color});
  final double value;
  final String? label;
  final Color? color;
}

/// A bar chart visualization.
class BarChart extends LeafRenderObjectWidget {
  const BarChart({
    super.key,
    required this.data,
    this.horizontal = false,
    this.barColor = const Color(0xFF2196F3),
    this.showLabels = true,
    this.showValues = true,
    this.onBarTap,
    this.tag,
  });

  final List<BarChartData> data;
  final bool horizontal;
  final Color barColor;
  final bool showLabels;
  final bool showValues;
  final void Function(int index)? onBarTap;
  final String? tag;

  @override
  RenderBarChart createRenderObject(BuildContext context) {
    return RenderBarChart(
      data: data,
      horizontal: horizontal,
      barColor: barColor,
      showLabels: showLabels,
      showValues: showValues,
      onBarTap: onBarTap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBarChart renderObject) {
    renderObject
      ..data = data
      ..horizontal = horizontal
      ..barColor = barColor
      ..showLabels = showLabels
      ..showValues = showValues
      ..onBarTap = onBarTap;
  }
}

class RenderBarChart extends RenderBox {
  RenderBarChart({
    required List<BarChartData> data,
    required bool horizontal,
    required Color barColor,
    required bool showLabels,
    required bool showValues,
    void Function(int index)? onBarTap,
  }) : _data = data,
       _horizontal = horizontal,
       _barColor = barColor,
       _showLabels = showLabels,
       _showValues = showValues,
       _onBarTap = onBarTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<BarChartData> _data;
  set data(List<BarChartData> value) {
    _data = value;
    markNeedsPaint();
  }

  bool _horizontal;
  set horizontal(bool value) {
    _horizontal = value;
    markNeedsPaint();
  }

  Color _barColor;
  set barColor(Color value) {
    _barColor = value;
    markNeedsPaint();
  }

  bool _showLabels;
  set showLabels(bool value) {
    _showLabels = value;
    markNeedsPaint();
  }

  bool _showValues;
  set showValues(bool value) {
    _showValues = value;
    markNeedsPaint();
  }

  void Function(int index)? _onBarTap;
  set onBarTap(void Function(int index)? value) => _onBarTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  final List<Rect> _barRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, 200));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    _barRects.clear();

    if (_data.isEmpty) return;

    final maxValue = _data.fold<double>(0, (max, d) => math.max(max, d.value));
    final labelHeight = _showLabels ? 24.0 : 0.0;
    final chartHeight = size.height - labelHeight;

    if (_horizontal) {
      // Horizontal bars
      final barHeight = (chartHeight - (_data.length - 1) * 4) / _data.length;
      final chartWidth = size.width - 50; // Leave space for labels

      for (int i = 0; i < _data.length; i++) {
        final d = _data[i];
        final barWidth = (d.value / maxValue) * chartWidth;
        final y = offset.dy + i * (barHeight + 4);
        final rect = Rect.fromLTWH(offset.dx + 50, y, barWidth, barHeight);
        final isHovered = _hoveredIndex == i;

        _barRects.add(
          Rect.fromLTWH(50, i * (barHeight + 4), barWidth, barHeight),
        );

        // Bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color = (d.color ?? _barColor).withValues(
              alpha: isHovered ? 1.0 : 0.85,
            ),
        );

        // Label
        if (d.label != null) {
          textPainter.text = TextSpan(
            text: d.label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              offset.dx + 48 - textPainter.width,
              y + barHeight / 2 - textPainter.height / 2,
            ),
          );
        }

        // Value
        if (_showValues) {
          textPainter.text = TextSpan(
            text: d.value.toStringAsFixed(0),
            style: const TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(offset.dx + 54, y + barHeight / 2 - textPainter.height / 2),
          );
        }
      }
    } else {
      // Vertical bars
      final barWidth = (size.width - (_data.length - 1) * 4) / _data.length;

      for (int i = 0; i < _data.length; i++) {
        final d = _data[i];
        final barHeight = (d.value / maxValue) * chartHeight;
        final x = offset.dx + i * (barWidth + 4);
        final y = offset.dy + chartHeight - barHeight;
        final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
        final isHovered = _hoveredIndex == i;

        _barRects.add(
          Rect.fromLTWH(
            i * (barWidth + 4),
            chartHeight - barHeight,
            barWidth,
            barHeight,
          ),
        );

        // Bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color = (d.color ?? _barColor).withValues(
              alpha: isHovered ? 1.0 : 0.85,
            ),
        );

        // Value on top
        if (_showValues) {
          textPainter.text = TextSpan(
            text: d.value.toStringAsFixed(0),
            style: const TextStyle(fontSize: 11, color: Color(0xFF333333)),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(x + barWidth / 2 - textPainter.width / 2, y - 16),
          );
        }

        // Label below
        if (d.label != null && _showLabels) {
          textPainter.text = TextSpan(
            text: d.label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              x + barWidth / 2 - textPainter.width / 2,
              offset.dy + chartHeight + 4,
            ),
          );
        }
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _barRects.length; i++) {
      if (_barRects[i].contains(local)) {
        _onBarTap?.call(i);
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
