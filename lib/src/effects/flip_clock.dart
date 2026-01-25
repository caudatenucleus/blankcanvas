import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

/// A flip clock animation widget.
class FlipClock extends LeafRenderObjectWidget {
  const FlipClock({
    super.key,
    this.showSeconds = true,
    this.use24Hour = false,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.textColor = const Color(0xFFFFFFFF),
    this.tag,
  });

  final bool showSeconds;
  final bool use24Hour;
  final Color backgroundColor;
  final Color textColor;
  final String? tag;

  @override
  RenderFlipClock createRenderObject(BuildContext context) {
    return RenderFlipClock(
      showSeconds: showSeconds,
      use24Hour: use24Hour,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlipClock renderObject) {
    renderObject
      ..showSeconds = showSeconds
      ..use24Hour = use24Hour
      ..backgroundColor = backgroundColor
      ..textColor = textColor;
  }
}

class RenderFlipClock extends RenderBox implements TickerProvider {
  RenderFlipClock({
    required bool showSeconds,
    required bool use24Hour,
    required Color backgroundColor,
    required Color textColor,
  }) : _showSeconds = showSeconds,
       _use24Hour = use24Hour,
       _backgroundColor = backgroundColor,
       _textColor = textColor {
    _ticker = createTicker(_onTick)..start();
  }

  bool _showSeconds;
  set showSeconds(bool value) {
    if (_showSeconds != value) {
      _showSeconds = value;
      markNeedsLayout();
    }
  }

  bool _use24Hour;
  set use24Hour(bool value) {
    _use24Hour = value;
    markNeedsPaint();
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    _backgroundColor = value;
    markNeedsPaint();
  }

  Color _textColor;
  set textColor(Color value) {
    _textColor = value;
    markNeedsPaint();
  }

  late Ticker _ticker;
  DateTime _currentTime = DateTime.now();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'FlipClockTicker');
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    if (now.second != _currentTime.second) {
      _currentTime = now;
      markNeedsPaint();
    }
  }

  @override
  void detach() {
    _ticker.dispose();
    super.detach();
  }

  static const double _digitWidth = 50.0;
  static const double _digitHeight = 70.0;
  static const double _spacing = 8.0;
  static const double _colonWidth = 20.0;

  @override
  void performLayout() {
    final digitCount = _showSeconds ? 6 : 4;
    final colonCount = _showSeconds ? 2 : 1;
    final width =
        digitCount * _digitWidth +
        colonCount * _colonWidth +
        (digitCount + colonCount - 1) * _spacing;
    size = constraints.constrain(Size(width, _digitHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    int hour = _currentTime.hour;
    if (!_use24Hour) {
      hour = hour % 12;
      if (hour == 0) hour = 12;
    }

    final digits = <String>[];
    digits.add((hour ~/ 10).toString());
    digits.add((hour % 10).toString());
    digits.add(':');
    digits.add((_currentTime.minute ~/ 10).toString());
    digits.add((_currentTime.minute % 10).toString());
    if (_showSeconds) {
      digits.add(':');
      digits.add((_currentTime.second ~/ 10).toString());
      digits.add((_currentTime.second % 10).toString());
    }

    double x = offset.dx;
    for (final d in digits) {
      final isColon = d == ':';
      final width = isColon ? _colonWidth : _digitWidth;

      if (!isColon) {
        // Digit background
        final rect = Rect.fromLTWH(x, offset.dy, _digitWidth, _digitHeight);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = _backgroundColor,
        );

        // Split line
        canvas.drawLine(
          Offset(x, offset.dy + _digitHeight / 2),
          Offset(x + _digitWidth, offset.dy + _digitHeight / 2),
          Paint()
            ..color = const Color(0x33000000)
            ..strokeWidth = 2,
        );
      }

      // Digit/colon text
      textPainter.text = TextSpan(
        text: d,
        style: TextStyle(
          fontSize: isColon ? 36 : 42,
          fontWeight: FontWeight.bold,
          color: _textColor,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + width / 2 - textPainter.width / 2,
          offset.dy + _digitHeight / 2 - textPainter.height / 2,
        ),
      );

      x += width + _spacing;
    }
  }
}
