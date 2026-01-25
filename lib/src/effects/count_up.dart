import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A lowest-level widget that animates a number counting up from begin to end.
class CountUp extends LeafRenderObjectWidget {
  const CountUp({
    super.key,
    required this.count,
    this.separator = ',',
    this.style,
  });

  /// The animation driving the numeric value.
  final Animation<double> count;
  final String separator;
  final TextStyle? style;

  @override
  RenderCountUp createRenderObject(BuildContext context) {
    return RenderCountUp(
      count: count,
      separator: separator,
      style:
          style ??
          const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          ),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCountUp renderObject) {
    renderObject
      ..count = count
      ..separator = separator
      ..style =
          style ??
          const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          );
  }
}

class RenderCountUp extends RenderBox {
  RenderCountUp({
    required Animation<double> count,
    required String separator,
    required TextStyle style,
  }) : _count = count,
       _separator = separator,
       _style = style {
    _updateText();
  }

  Animation<double> _count;
  set count(Animation<double> value) {
    if (_count == value) return;
    if (attached) _count.removeListener(_handleTick);
    _count = value;
    if (attached) _count.addListener(_handleTick);
    _handleTick();
  }

  String _separator;
  set separator(String value) {
    if (_separator == value) return;
    _separator = value;
    _updateText();
  }

  TextStyle _style;
  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    _updateText();
  }

  void _handleTick() {
    _updateText();
    markNeedsLayout(); // Size might change as number grows
    markNeedsPaint();
  }

  late TextPainter _textPainter;

  void _updateText() {
    final int value = _count.value.toInt();
    // Simple integer formatting with separator (simplification)
    final String text = value.toString();
    _textPainter = TextPainter(
      text: TextSpan(text: text, style: _style),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _count.addListener(_handleTick);
  }

  @override
  void detach() {
    _count.removeListener(_handleTick);
    super.detach();
  }

  @override
  void performLayout() {
    _textPainter.layout();
    size = constraints.constrain(_textPainter.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }
}
