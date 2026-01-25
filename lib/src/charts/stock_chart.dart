import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Stock chart data point.
class StockData {
  const StockData({required this.date, required this.price, this.volume});
  final DateTime date;
  final double price;
  final double? volume;
}

/// A stock chart widget with price and volume.
class StockChart extends LeafRenderObjectWidget {
  const StockChart({
    super.key,
    required this.data,
    this.onPointTap,
    this.lineColor = const Color(0xFF2196F3),
    this.volumeColor = const Color(0xFFBDBDBD),
    this.tag,
  });

  final List<StockData> data;
  final void Function(StockData point)? onPointTap;
  final Color lineColor;
  final Color volumeColor;
  final String? tag;

  @override
  RenderStockChart createRenderObject(BuildContext context) {
    return RenderStockChart(
      data: data,
      onPointTap: onPointTap,
      lineColor: lineColor,
      volumeColor: volumeColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStockChart renderObject) {
    renderObject
      ..data = data
      ..onPointTap = onPointTap
      ..lineColor = lineColor
      ..volumeColor = volumeColor;
  }
}

class RenderStockChart extends RenderBox {
  RenderStockChart({
    required List<StockData> data,
    void Function(StockData point)? onPointTap,
    required Color lineColor,
    required Color volumeColor,
  }) : _data = data,
       _onPointTap = onPointTap,
       _lineColor = lineColor,
       _volumeColor = volumeColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<StockData> _data;
  set data(List<StockData> value) {
    _data = value;
    markNeedsPaint();
  }

  // ignore: unused_field
  void Function(StockData point)? _onPointTap;
  set onPointTap(void Function(StockData point)? value) => _onPointTap = value;

  Color _lineColor;
  set lineColor(Color value) => _lineColor = value;

  Color _volumeColor;
  set volumeColor(Color value) => _volumeColor = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const double _padding = 50.0;
  static const double _volumeHeight = 50.0;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, 250));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (_data.isEmpty) return;

    final priceChartRect = Rect.fromLTWH(
      offset.dx + _padding,
      offset.dy + 20,
      size.width - _padding * 2,
      size.height - _volumeHeight - 60,
    );
    final volumeChartRect = Rect.fromLTWH(
      offset.dx + _padding,
      priceChartRect.bottom + 10,
      size.width - _padding * 2,
      _volumeHeight,
    );

    // Price range
    final minPrice = _data.map((d) => d.price).reduce(math.min);
    final maxPrice = _data.map((d) => d.price).reduce(math.max);
    final priceRange = maxPrice - minPrice;

    // Volume range
    final maxVolume = _data
        .where((d) => d.volume != null)
        .map((d) => d.volume!)
        .fold<double>(1, math.max);

    // Grid
    for (int i = 0; i <= 4; i++) {
      final y = priceChartRect.top + priceChartRect.height * i / 4;
      canvas.drawLine(
        Offset(priceChartRect.left, y),
        Offset(priceChartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final price = maxPrice - priceRange * i / 4;
      textPainter.text = TextSpan(
        text: price.toStringAsFixed(2),
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

    // Price line
    final pointWidth = priceChartRect.width / (_data.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < _data.length; i++) {
      final point = _data[i];
      final x = priceChartRect.left + i * pointWidth;
      final y =
          priceChartRect.bottom -
          (point.price - minPrice) / priceRange * priceChartRect.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, priceChartRect.bottom);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(priceChartRect.right, priceChartRect.bottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()..color = _lineColor.withValues(alpha: 0.1),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Volume bars
    if (_data.any((d) => d.volume != null)) {
      final barWidth = volumeChartRect.width / _data.length * 0.8;
      for (int i = 0; i < _data.length; i++) {
        final point = _data[i];
        if (point.volume == null) continue;

        final x =
            volumeChartRect.left + i * volumeChartRect.width / _data.length;
        final barHeight = (point.volume! / maxVolume) * volumeChartRect.height;
        final barRect = Rect.fromLTWH(
          x,
          volumeChartRect.bottom - barHeight,
          barWidth,
          barHeight,
        );

        final isHovered = _hoveredIndex == i;
        canvas.drawRect(
          barRect,
          Paint()
            ..color = isHovered
                ? _volumeColor
                : _volumeColor.withValues(alpha: 0.6),
        );
      }
    }

    // Hover crosshair
    if (_hoveredIndex != null && _hoveredIndex! < _data.length) {
      final point = _data[_hoveredIndex!];
      final x = priceChartRect.left + _hoveredIndex! * pointWidth;
      final y =
          priceChartRect.bottom -
          (point.price - minPrice) / priceRange * priceChartRect.height;

      canvas.drawLine(
        Offset(x, priceChartRect.top),
        Offset(x, volumeChartRect.bottom),
        Paint()
          ..color = const Color(0x44000000)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = _lineColor);

      // Tooltip
      textPainter.text = TextSpan(
        text: '\$${point.price.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      canvas.drawRect(
        Rect.fromLTWH(
          x - textPainter.width / 2 - 4,
          y - 20,
          textPainter.width + 8,
          16,
        ),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 18));
    }
  }

  void _handleTapUp(TapUpDetails details) {
    // Simplified tap handling
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    final chartWidth = size.width - _padding * 2;
    final index = ((local.dx - _padding) / chartWidth * _data.length)
        .floor()
        .clamp(0, _data.length - 1);

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
