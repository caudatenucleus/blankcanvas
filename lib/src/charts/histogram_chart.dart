import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A histogram chart widget.
class HistogramChart extends LeafRenderObjectWidget {
  const HistogramChart({
    super.key,
    required this.data,
    this.bins = 10,
    this.color = const Color(0xFF2196F3),
    this.onBinTap,
    this.tag,
  });

  final List<double> data;
  final int bins;
  final Color color;
  final void Function(int binIndex, double min, double max, int count)?
  onBinTap;
  final String? tag;

  @override
  RenderHistogramChart createRenderObject(BuildContext context) {
    return RenderHistogramChart(
      data: data,
      bins: bins,
      color: color,
      onBinTap: onBinTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHistogramChart renderObject,
  ) {
    renderObject
      ..data = data
      ..bins = bins
      ..color = color
      ..onBinTap = onBinTap;
  }
}

class RenderHistogramChart extends RenderBox {
  RenderHistogramChart({
    required List<double> data,
    required int bins,
    required Color color,
    void Function(int binIndex, double min, double max, int count)? onBinTap,
  }) : _data = data,
       _bins = bins,
       _color = color,
       _onBinTap = onBinTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _calculateBins();
  }

  List<double> _data;
  set data(List<double> value) {
    _data = value;
    _calculateBins();
  }

  int _bins;
  set bins(int value) {
    _bins = value;
    _calculateBins();
  }

  Color _color;
  set color(Color value) {
    _color = value;
    markNeedsPaint();
  }

  void Function(int binIndex, double min, double max, int count)? _onBinTap;
  set onBinTap(
    void Function(int binIndex, double min, double max, int count)? value,
  ) => _onBinTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  List<int> _binCounts = [];
  List<double> _binEdges = [];

  static const double _padding = 50.0;
  final List<Rect> _barRects = [];

  void _calculateBins() {
    if (_data.isEmpty) {
      _binCounts = [];
      _binEdges = [];
      return;
    }

    final minVal = _data.reduce(math.min);
    final maxVal = _data.reduce(math.max);
    final binWidth = (maxVal - minVal) / _bins;

    _binEdges = List.generate(_bins + 1, (i) => minVal + i * binWidth);
    _binCounts = List.filled(_bins, 0);

    for (final val in _data) {
      int binIndex = ((val - minVal) / binWidth).floor();
      if (binIndex >= _bins) binIndex = _bins - 1;
      _binCounts[binIndex]++;
    }

    markNeedsLayout();
  }

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

    if (_binCounts.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      offset.dx + _padding,
      offset.dy + 20,
      size.width - _padding * 2,
      size.height - 60,
    );
    final maxCount = _binCounts.reduce(math.max);

    // Grid
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final value = maxCount - maxCount * i / 5;
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
    final barWidth = chartRect.width / _bins;
    for (int i = 0; i < _binCounts.length; i++) {
      final count = _binCounts[i];
      final barHeight = (count / maxCount) * chartRect.height;
      final x = chartRect.left + i * barWidth;
      final barRect = Rect.fromLTWH(
        x,
        chartRect.bottom - barHeight,
        barWidth - 1,
        barHeight,
      );

      _barRects.add(
        Rect.fromLTWH(
          x - offset.dx,
          chartRect.bottom - barHeight - offset.dy,
          barWidth - 1,
          barHeight,
        ),
      );

      final isHovered = _hoveredIndex == i;
      canvas.drawRect(
        barRect,
        Paint()..color = isHovered ? _color : _color.withValues(alpha: 0.85),
      );

      if (isHovered) {
        textPainter.text = TextSpan(
          text: '$count',
          style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + barWidth / 2 - textPainter.width / 2,
            chartRect.bottom - barHeight - textPainter.height - 2,
          ),
        );
      }
    }

    // X-axis labels
    for (int i = 0; i <= _bins; i += math.max(1, _bins ~/ 5)) {
      if (i < _binEdges.length) {
        final x = chartRect.left + i * barWidth;
        textPainter.text = TextSpan(
          text: _binEdges[i].toStringAsFixed(1),
          style: const TextStyle(fontSize: 9, color: Color(0xFF666666)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, chartRect.bottom + 4),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _barRects.length; i++) {
      if (_barRects[i].contains(local)) {
        _onBinTap?.call(i, _binEdges[i], _binEdges[i + 1], _binCounts[i]);
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
