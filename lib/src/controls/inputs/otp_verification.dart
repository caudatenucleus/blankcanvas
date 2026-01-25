import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// An OTP verification input with separate digit boxes.
class OTPVerification extends LeafRenderObjectWidget {
  const OTPVerification({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.tag,
  });

  final int length;
  final void Function(String code)? onCompleted;
  final void Function(String code)? onChanged;
  final String? tag;

  @override
  RenderOTPVerification createRenderObject(BuildContext context) {
    return RenderOTPVerification(
      length: length,
      onCompleted: onCompleted,
      onChanged: onChanged,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOTPVerification renderObject,
  ) {
    renderObject
      ..length = length
      ..onCompleted = onCompleted
      ..onChanged = onChanged;
  }
}

class RenderOTPVerification extends RenderBox {
  RenderOTPVerification({
    required int length,
    void Function(String code)? onCompleted,
    void Function(String code)? onChanged,
  }) : _length = length,
       _onCompleted = onCompleted,
       _onChanged = onChanged,
       _digits = List.filled(length, '') {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  int _length;
  set length(int value) {
    if (_length != value) {
      _length = value;
      _digits = List.filled(value, '');
      markNeedsLayout();
    }
  }

  // ignore: unused_field
  void Function(String code)? _onCompleted;
  set onCompleted(void Function(String code)? value) => _onCompleted = value;

  // ignore: unused_field
  void Function(String code)? _onChanged;
  set onChanged(void Function(String code)? value) => _onChanged = value;

  late TapGestureRecognizer _tap;
  List<String> _digits;
  int _focusedIndex = 0;
  int? _hoveredIndex;

  static const double _boxSize = 48.0;
  static const double _spacing = 8.0;

  final List<Rect> _boxRects = [];

  String get _code => _digits.join();

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _boxRects.clear();
    final totalWidth = _length * _boxSize + (_length - 1) * _spacing;
    size = constraints.constrain(Size(totalWidth, _boxSize));

    for (int i = 0; i < _length; i++) {
      _boxRects.add(
        Rect.fromLTWH(i * (_boxSize + _spacing), 0, _boxSize, _boxSize),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < _length; i++) {
      if (i >= _boxRects.length) break;
      final rect = _boxRects[i].shift(offset);
      final isFocused = _focusedIndex == i;
      final isHovered = _hoveredIndex == i;
      final digit = _digits[i];

      // Box background
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = isHovered
              ? const Color(0xFFF5F5F5)
              : const Color(0xFFFFFFFF),
      );

      // Box border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = isFocused
              ? const Color(0xFF2196F3)
              : (digit.isNotEmpty
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE0E0E0))
          ..strokeWidth = isFocused ? 2 : 1,
      );

      // Digit or cursor
      if (digit.isNotEmpty) {
        textPainter.text = TextSpan(
          text: digit,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      } else if (isFocused) {
        // Cursor line
        canvas.drawLine(
          Offset(rect.center.dx, rect.center.dy - 12),
          Offset(rect.center.dx, rect.center.dy + 12),
          Paint()
            ..color = const Color(0xFF2196F3)
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _boxRects.length; i++) {
      if (_boxRects[i].contains(local)) {
        _focusedIndex = i;
        markNeedsPaint();
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _boxRects.length; i++) {
      if (_boxRects[i].contains(local)) {
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
