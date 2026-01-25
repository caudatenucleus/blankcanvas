import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Candlestick data point.
class CandlestickData {
  const CandlestickData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;

  bool get isUp => close >= open;
}

/// A candlestick chart widget.
class CandlestickChart extends LeafRenderObjectWidget {
  const CandlestickChart({
    super.key,
    required this.data,
    this.onCandleTap,
    this.upColor = const Color(0xFF4CAF50),
    this.downColor = const Color(0xFFE53935),
    this.tag,
  });

  final List<CandlestickData> data;
  final void Function(CandlestickData candle)? onCandleTap;
  final Color upColor;
  final Color downColor;
  final String? tag;

  @override
  RenderCandlestickChart createRenderObject(BuildContext context) {
    return RenderCandlestickChart(
      data: data,
      onCandleTap: onCandleTap,
      upColor: upColor,
      downColor: downColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCandlestickChart renderObject,
  ) {
    renderObject
      ..data = data
      ..onCandleTap = onCandleTap
      ..upColor = upColor
      ..downColor = downColor;
  }
}

class RenderCandlestickChart extends RenderBox {
  RenderCandlestickChart({
    required List<CandlestickData> data,
    void Function(CandlestickData candle)? onCandleTap,
    required Color upColor,
    required Color downColor,
  }) : _data = data,
       _onCandleTap = onCandleTap,
       _upColor = upColor,
       _downColor = downColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<CandlestickData> _data;
  set data(List<CandlestickData> value) {
    _data = value;
    markNeedsPaint();
  }

  void Function(CandlestickData candle)? _onCandleTap;
  set onCandleTap(void Function(CandlestickData candle)? value) =>
      _onCandleTap = value;

  Color _upColor;
  set upColor(Color value) {
    _upColor = value;
    markNeedsPaint();
  }

  Color _downColor;
  set downColor(Color value) {
    _downColor = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const double _padding = 50.0;

  final List<Rect> _candleRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _candleRects.clear();
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

    // Price range
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;
    for (final candle in _data) {
      minPrice = math.min(minPrice, candle.low);
      maxPrice = math.max(maxPrice, candle.high);
    }
    final priceRange = maxPrice - minPrice;

    // Grid
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      final price = maxPrice - priceRange * i / 5;
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

    // Candlesticks
    final candleWidth = chartRect.width / _data.length;
    for (int i = 0; i < _data.length; i++) {
      final candle = _data[i];
      final centerX = chartRect.left + candleWidth * (i + 0.5);
      final bodyWidth = candleWidth * 0.7;
      final isHovered = _hoveredIndex == i;

      double toY(double price) =>
          chartRect.top + (maxPrice - price) / priceRange * chartRect.height;

      final highY = toY(candle.high);
      final lowY = toY(candle.low);
      final openY = toY(candle.open);
      final closeY = toY(candle.close);

      final color = candle.isUp ? _upColor : _downColor;

      // Wick
      canvas.drawLine(
        Offset(centerX, highY),
        Offset(centerX, lowY),
        Paint()
          ..color = color
          ..strokeWidth = 1,
      );

      // Body
      final bodyTop = math.min(openY, closeY);
      final bodyHeight = (openY - closeY).abs().clamp(1.0, double.infinity);
      final bodyRect = Rect.fromLTWH(
        centerX - bodyWidth / 2,
        bodyTop,
        bodyWidth,
        bodyHeight,
      );

      _candleRects.add(
        Rect.fromLTWH(
          centerX - bodyWidth / 2 - offset.dx,
          bodyTop - offset.dy,
          bodyWidth,
          bodyHeight,
        ),
      );

      canvas.drawRect(
        bodyRect,
        Paint()..color = isHovered ? color : color.withValues(alpha: 0.9),
      );

      // Hollow for up candles
      if (candle.isUp) {
        canvas.drawRect(
          bodyRect.deflate(1),
          Paint()..color = const Color(0xFFFFFFFF),
        );
        canvas.drawRect(
          bodyRect,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = color
            ..strokeWidth = 2,
        );
      }
    }

    // Date labels
    if (_data.isNotEmpty) {
      for (int i = 0; i < _data.length; i += math.max(1, _data.length ~/ 5)) {
        final x = chartRect.left + candleWidth * (i + 0.5);
        final date = _data[i].date;
        textPainter.text = TextSpan(
          text: '${date.month}/${date.day}',
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
    for (int i = 0; i < _candleRects.length; i++) {
      if (_candleRects[i].contains(local)) {
        _onCandleTap?.call(_data[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _candleRects.length; i++) {
      if (_candleRects[i].contains(local)) {
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
