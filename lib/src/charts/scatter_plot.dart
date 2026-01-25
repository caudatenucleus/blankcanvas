import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A data point for the scatter plot.
class ScatterPlotData {
  const ScatterPlotData({
    required this.x,
    required this.y,
    this.size = 8,
    this.color,
    this.label,
  });
  final double x;
  final double y;
  final double size;
  final Color? color;
  final String? label;
}

/// A scatter plot visualization.
class ScatterPlot extends LeafRenderObjectWidget {
  const ScatterPlot({
    super.key,
    required this.data,
    this.pointColor = const Color(0xFF2196F3),
    this.showGrid = true,
    this.onPointTap,
    this.tag,
  });

  final List<ScatterPlotData> data;
  final Color pointColor;
  final bool showGrid;
  final void Function(int index)? onPointTap;
  final String? tag;

  @override
  RenderScatterPlot createRenderObject(BuildContext context) {
    return RenderScatterPlot(
      data: data,
      pointColor: pointColor,
      showGrid: showGrid,
      onPointTap: onPointTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderScatterPlot renderObject,
  ) {
    renderObject
      ..data = data
      ..pointColor = pointColor
      ..showGrid = showGrid
      ..onPointTap = onPointTap;
  }
}

class RenderScatterPlot extends RenderBox {
  RenderScatterPlot({
    required List<ScatterPlotData> data,
    required Color pointColor,
    required bool showGrid,
    void Function(int index)? onPointTap,
  }) : _data = data,
       _pointColor = pointColor,
       _showGrid = showGrid,
       _onPointTap = onPointTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<ScatterPlotData> _data;
  set data(List<ScatterPlotData> value) {
    _data = value;
    markNeedsPaint();
  }

  Color _pointColor;
  set pointColor(Color value) {
    _pointColor = value;
    markNeedsPaint();
  }

  bool _showGrid;
  set showGrid(bool value) {
    _showGrid = value;
    markNeedsPaint();
  }

  void Function(int index)? _onPointTap;
  set onPointTap(void Function(int index)? value) => _onPointTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  final List<Offset> _pointPositions = [];
  final List<double> _pointSizes = [];

  static const double _padding = 30.0;

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
    _pointPositions.clear();
    _pointSizes.clear();

    if (_data.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      offset.dx + _padding,
      offset.dy + _padding / 2,
      size.width - _padding * 2,
      size.height - _padding,
    );

    final minX = _data.fold<double>(_data.first.x, (m, d) => math.min(m, d.x));
    final maxX = _data.fold<double>(_data.first.x, (m, d) => math.max(m, d.x));
    final minY = _data.fold<double>(_data.first.y, (m, d) => math.min(m, d.y));
    final maxY = _data.fold<double>(_data.first.y, (m, d) => math.max(m, d.y));

    final xRange = maxX - minX == 0 ? 1 : maxX - minX;
    final yRange = maxY - minY == 0 ? 1 : maxY - minY;

    // Grid
    if (_showGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFFE0E0E0)
        ..strokeWidth = 1;
      for (int i = 0; i <= 4; i++) {
        final y = chartRect.top + (chartRect.height / 4) * i;
        canvas.drawLine(
          Offset(chartRect.left, y),
          Offset(chartRect.right, y),
          gridPaint,
        );

        final x = chartRect.left + (chartRect.width / 4) * i;
        canvas.drawLine(
          Offset(x, chartRect.top),
          Offset(x, chartRect.bottom),
          gridPaint,
        );
      }
    }

    // Points
    for (int i = 0; i < _data.length; i++) {
      final d = _data[i];
      final x = chartRect.left + ((d.x - minX) / xRange) * chartRect.width;
      final y = chartRect.bottom - ((d.y - minY) / yRange) * chartRect.height;
      final pos = Offset(x, y);
      final isHovered = _hoveredIndex == i;

      _pointPositions.add(Offset(x - offset.dx, y - offset.dy));
      _pointSizes.add(d.size);

      canvas.drawCircle(
        pos,
        isHovered ? d.size + 2 : d.size,
        Paint()
          ..color = (d.color ?? _pointColor).withValues(
            alpha: isHovered ? 1.0 : 0.8,
          ),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _pointPositions.length; i++) {
      if ((local - _pointPositions[i]).distance < _pointSizes[i] + 5) {
        _onPointTap?.call(i);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _pointPositions.length; i++) {
      if ((local - _pointPositions[i]).distance < _pointSizes[i] + 5) {
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
