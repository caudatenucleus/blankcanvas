import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Stacked bar data.
class StackedBarData {
  const StackedBarData({required this.label, required this.values});
  final String label;
  final List<double> values;
}

/// A stacked bar chart widget.
class StackedBarChart extends LeafRenderObjectWidget {
  const StackedBarChart({
    super.key,
    required this.data,
    this.seriesLabels = const [],
    this.colors = const [],
    this.horizontal = false,
    this.onBarTap,
    this.tag,
  });

  final List<StackedBarData> data;
  final List<String> seriesLabels;
  final List<Color> colors;
  final bool horizontal;
  final void Function(StackedBarData bar, int seriesIndex)? onBarTap;
  final String? tag;

  @override
  RenderStackedBarChart createRenderObject(BuildContext context) {
    return RenderStackedBarChart(
      data: data,
      seriesLabels: seriesLabels,
      colors: colors,
      horizontal: horizontal,
      onBarTap: onBarTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStackedBarChart renderObject,
  ) {
    renderObject
      ..data = data
      ..seriesLabels = seriesLabels
      ..colors = colors
      ..horizontal = horizontal
      ..onBarTap = onBarTap;
  }
}

class RenderStackedBarChart extends RenderBox {
  RenderStackedBarChart({
    required List<StackedBarData> data,
    required List<String> seriesLabels,
    required List<Color> colors,
    required bool horizontal,
    void Function(StackedBarData bar, int seriesIndex)? onBarTap,
  }) : _data = data,
       _seriesLabels = seriesLabels,
       _colors = colors,
       _horizontal = horizontal,
       _onBarTap = onBarTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<StackedBarData> _data;
  set data(List<StackedBarData> value) => _data = value;

  List<String> _seriesLabels;
  set seriesLabels(List<String> value) => _seriesLabels = value;

  List<Color> _colors;
  set colors(List<Color> value) => _colors = value;

  // ignore: unused_field
  bool _horizontal;
  set horizontal(bool value) => _horizontal = value;

  void Function(StackedBarData bar, int seriesIndex)? _onBarTap;
  set onBarTap(void Function(StackedBarData bar, int seriesIndex)? value) =>
      _onBarTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredBarIndex;
  int? _hoveredSeriesIndex;

  static const List<Color> _defaultColors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];
  static const double _padding = 50.0;

  final List<List<Rect>> _barRects = [];

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
    final usedColors = _colors.isEmpty ? _defaultColors : _colors;

    // Max total
    double maxTotal = 0;
    for (final bar in _data) {
      final total = bar.values.fold<double>(0, (a, b) => a + b);
      maxTotal = math.max(maxTotal, total);
    }

    // Grid
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final value = maxTotal - maxTotal * i / 5;
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
    for (int i = 0; i < _data.length; i++) {
      final bar = _data[i];
      final centerX = chartRect.left + barWidth * (i + 0.5);
      final width = barWidth * 0.7;
      final barRects = <Rect>[];

      double stackY = chartRect.bottom;
      for (int j = 0; j < bar.values.length; j++) {
        final value = bar.values[j];
        final segmentHeight = (value / maxTotal) * chartRect.height;
        final segmentRect = Rect.fromLTWH(
          centerX - width / 2,
          stackY - segmentHeight,
          width,
          segmentHeight,
        );
        barRects.add(
          Rect.fromLTWH(
            centerX - width / 2 - offset.dx,
            stackY - segmentHeight - offset.dy,
            width,
            segmentHeight,
          ),
        );

        final color = usedColors[j % usedColors.length];
        final isHovered = _hoveredBarIndex == i && _hoveredSeriesIndex == j;

        canvas.drawRect(
          segmentRect,
          Paint()..color = isHovered ? color : color.withValues(alpha: 0.85),
        );

        stackY -= segmentHeight;
      }

      _barRects.add(barRects);

      // Label
      textPainter.text = TextSpan(
        text: bar.label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, chartRect.bottom + 4),
      );
    }

    // Legend
    final legendY = offset.dy + size.height - 20;
    double legendX = offset.dx + _padding;
    for (int j = 0; j < _seriesLabels.length; j++) {
      final color = usedColors[j % usedColors.length];
      canvas.drawRect(
        Rect.fromLTWH(legendX, legendY, 12, 12),
        Paint()..color = color,
      );
      legendX += 16;

      textPainter.text = TextSpan(
        text: _seriesLabels[j],
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(legendX, legendY));
      legendX += textPainter.width + 16;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _barRects.length; i++) {
      for (int j = 0; j < _barRects[i].length; j++) {
        if (_barRects[i][j].contains(local)) {
          _onBarTap?.call(_data[i], j);
          return;
        }
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? barIndex, seriesIndex;
    for (int i = 0; i < _barRects.length; i++) {
      for (int j = 0; j < _barRects[i].length; j++) {
        if (_barRects[i][j].contains(local)) {
          barIndex = i;
          seriesIndex = j;
          break;
        }
      }
    }
    if (_hoveredBarIndex != barIndex || _hoveredSeriesIndex != seriesIndex) {
      _hoveredBarIndex = barIndex;
      _hoveredSeriesIndex = seriesIndex;
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
