import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Mixed chart data series.
class MixedChartSeries {
  const MixedChartSeries({
    required this.name,
    required this.type,
    required this.data,
    this.color,
  });
  final String name;
  final MixedChartType type;
  final List<double> data;
  final Color? color;
}

enum MixedChartType { bar, line, area, scatter }

/// A mixed chart widget supporting multiple chart types.
class MixedChart extends LeafRenderObjectWidget {
  const MixedChart({
    super.key,
    required this.series,
    required this.labels,
    this.onPointTap,
    this.tag,
  });

  final List<MixedChartSeries> series;
  final List<String> labels;
  final void Function(int seriesIndex, int pointIndex)? onPointTap;
  final String? tag;

  @override
  RenderMixedChart createRenderObject(BuildContext context) {
    return RenderMixedChart(
      series: series,
      labels: labels,
      onPointTap: onPointTap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMixedChart renderObject) {
    renderObject
      ..series = series
      ..labels = labels
      ..onPointTap = onPointTap;
  }
}

class RenderMixedChart extends RenderBox {
  RenderMixedChart({
    required List<MixedChartSeries> series,
    required List<String> labels,
    void Function(int seriesIndex, int pointIndex)? onPointTap,
  }) : _series = series,
       _labels = labels,
       _onPointTap = onPointTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<MixedChartSeries> _series;
  set series(List<MixedChartSeries> value) {
    _series = value;
    markNeedsPaint();
  }

  List<String> _labels;
  set labels(List<String> value) {
    _labels = value;
    markNeedsPaint();
  }

  void Function(int seriesIndex, int pointIndex)? _onPointTap;
  set onPointTap(void Function(int seriesIndex, int pointIndex)? value) =>
      _onPointTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredSeries;
  int? _hoveredIndex;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
  ];
  static const double _padding = 40.0;

  final Map<int, List<Rect>> _hitRects = {};

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _hitRects.clear();
    size = constraints.constrain(Size(constraints.maxWidth, 300));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (_series.isEmpty || _labels.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      offset.dx + _padding,
      offset.dy + 20,
      size.width - _padding * 2,
      size.height - 50,
    );

    // Calc Max
    double maxVal = 0;
    for (final s in _series) {
      if (s.data.isNotEmpty) {
        maxVal = math.max(maxVal, s.data.reduce(math.max));
      }
    }

    // Grid
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final value = maxVal - maxVal * i / 5;
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(0),
        style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
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

    // Draw
    final stepWidth = chartRect.width / _labels.length;

    for (int sIdx = 0; sIdx < _series.length; sIdx++) {
      final s = _series[sIdx];
      final color = s.color ?? _colors[sIdx % _colors.length];
      final rects = <Rect>[];

      switch (s.type) {
        case MixedChartType.bar:
          final barWidth =
              stepWidth *
              0.6 /
              _series.where((sr) => sr.type == MixedChartType.bar).length;
          final barOffset = _series
              .where((sr) => sr.type == MixedChartType.bar)
              .toList()
              .indexOf(s);

          for (int i = 0; i < s.data.length; i++) {
            final x =
                chartRect.left +
                i * stepWidth +
                stepWidth * 0.1 +
                barOffset * barWidth;
            final val = s.data[i];
            final height = (val / maxVal) * chartRect.height;
            final rect = Rect.fromLTWH(
              x,
              chartRect.bottom - height,
              barWidth,
              height,
            );
            final hitRect = rect.shift(-offset);
            rects.add(hitRect);

            final isHovered = _hoveredSeries == sIdx && _hoveredIndex == i;
            canvas.drawRect(
              rect,
              Paint()..color = isHovered ? color : color.withValues(alpha: 0.8),
            );
          }
          break;

        case MixedChartType.area:
          final path = Path();
          path.moveTo(chartRect.left, chartRect.bottom);
          for (int i = 0; i < s.data.length; i++) {
            final x = chartRect.left + i * stepWidth + stepWidth * 0.5;
            final y =
                chartRect.bottom - (s.data[i] / maxVal) * chartRect.height;
            path.lineTo(x, y);
            // Add dummy hit rects for points
            rects.add(
              Rect.fromCircle(
                center: Offset(x - offset.dx, y - offset.dy),
                radius: 8,
              ),
            );
          }
          path.lineTo(
            chartRect.left + (_labels.length - 1) * stepWidth + stepWidth * 0.5,
            chartRect.bottom,
          );
          path.close();
          canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.3));
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = color
              ..strokeWidth = 2,
          );
          break;

        case MixedChartType.line:
          final path = Path();
          for (int i = 0; i < s.data.length; i++) {
            final x = chartRect.left + i * stepWidth + stepWidth * 0.5;
            final y =
                chartRect.bottom - (s.data[i] / maxVal) * chartRect.height;
            if (i == 0) {
              path.moveTo(x, y);
            } else {
              path.lineTo(x, y);
            }
            rects.add(
              Rect.fromCircle(
                center: Offset(x - offset.dx, y - offset.dy),
                radius: 8,
              ),
            );
          }
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = color
              ..strokeWidth = 2,
          );
          // Dots
          for (int i = 0; i < s.data.length; i++) {
            final x = chartRect.left + i * stepWidth + stepWidth * 0.5;
            final y =
                chartRect.bottom - (s.data[i] / maxVal) * chartRect.height;
            canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
            if (_hoveredSeries == sIdx && _hoveredIndex == i) {
              canvas.drawCircle(
                Offset(x, y),
                6,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..color = const Color(0xFF000000)
                  ..strokeWidth = 1,
              );
            }
          }
          break;

        case MixedChartType.scatter:
          for (int i = 0; i < s.data.length; i++) {
            final x = chartRect.left + i * stepWidth + stepWidth * 0.5;
            final y =
                chartRect.bottom - (s.data[i] / maxVal) * chartRect.height;
            rects.add(
              Rect.fromCircle(
                center: Offset(x - offset.dx, y - offset.dy),
                radius: 8,
              ),
            );
            final isHovered = _hoveredSeries == sIdx && _hoveredIndex == i;
            canvas.drawCircle(
              Offset(x, y),
              isHovered ? 6 : 4,
              Paint()..color = color,
            );
          }
          break;
      }
      _hitRects[sIdx] = rects;
    }

    // X Axis Labels
    for (int i = 0; i < _labels.length; i++) {
      final x = chartRect.left + i * stepWidth + stepWidth * 0.5;
      textPainter.text = TextSpan(
        text: _labels[i],
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartRect.bottom + 4),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    _hitRects.forEach((sIdx, rects) {
      for (int i = 0; i < rects.length; i++) {
        if (rects[i].contains(local)) {
          _onPointTap?.call(sIdx, i);
          return;
        }
      }
    });
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? sIndex, pIndex;
    _hitRects.forEach((sIdx, rects) {
      for (int i = 0; i < rects.length; i++) {
        if (rects[i].contains(local)) {
          sIndex = sIdx;
          pIndex = i;
          return;
        }
      }
    });

    if (_hoveredSeries != sIndex || _hoveredIndex != pIndex) {
      _hoveredSeries = sIndex;
      _hoveredIndex = pIndex;
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
