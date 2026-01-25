import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A math input widget for entering mathematical expressions.
class MathInput extends LeafRenderObjectWidget {
  const MathInput({
    super.key,
    this.expression = '',
    this.onChanged,
    this.showKeypad = true,
    this.tag,
  });

  final String expression;
  final void Function(String expression)? onChanged;
  final bool showKeypad;
  final String? tag;

  @override
  RenderMathInput createRenderObject(BuildContext context) {
    return RenderMathInput(
      expression: expression,
      onChanged: onChanged,
      showKeypad: showKeypad,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMathInput renderObject) {
    renderObject
      ..expression = expression
      ..onChanged = onChanged
      ..showKeypad = showKeypad;
  }
}

class RenderMathInput extends RenderBox {
  RenderMathInput({
    required String expression,
    void Function(String expression)? onChanged,
    required bool showKeypad,
  }) : _expression = expression,
       _onChanged = onChanged,
       _showKeypad = showKeypad {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  String _expression;
  set expression(String value) {
    if (_expression != value) {
      _expression = value;
      markNeedsPaint();
    }
  }

  void Function(String expression)? _onChanged;
  set onChanged(void Function(String expression)? value) => _onChanged = value;

  bool _showKeypad;
  set showKeypad(bool value) {
    if (_showKeypad != value) {
      _showKeypad = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int? _hoveredButton;

  static const _mathButtons = [
    '7',
    '8',
    '9',
    '÷',
    '√',
    '4',
    '5',
    '6',
    '×',
    'xⁿ',
    '1',
    '2',
    '3',
    '-',
    'π',
    '0',
    '.',
    '=',
    '+',
    'e',
    '(',
    ')',
    '←',
    'C',
    '∞',
  ];

  static const double _displayHeight = 60.0;
  static const double _buttonSize = 48.0;
  static const double _buttonSpacing = 4.0;
  static const int _columns = 5;

  final List<Rect> _buttonRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _buttonRects.clear();
    final rows = (_mathButtons.length / _columns).ceil();
    final keypadHeight = _showKeypad
        ? rows * (_buttonSize + _buttonSpacing)
        : 0.0;
    size = constraints.constrain(
      Size(constraints.maxWidth, _displayHeight + keypadHeight + 8),
    );

    if (_showKeypad) {
      final buttonWidth =
          (size.width - (_columns - 1) * _buttonSpacing) / _columns;
      for (int i = 0; i < _mathButtons.length; i++) {
        final row = i ~/ _columns;
        final col = i % _columns;
        _buttonRects.add(
          Rect.fromLTWH(
            col * (buttonWidth + _buttonSpacing),
            _displayHeight + 8 + row * (_buttonSize + _buttonSpacing),
            buttonWidth,
            _buttonSize,
          ),
        );
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Display area
    final displayRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _displayHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(displayRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // Expression
    textPainter.text = TextSpan(
      text: _expression.isEmpty ? '0' : _expression,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w300,
        color: Color(0xFFFFFFFF),
      ),
    );
    textPainter.layout(maxWidth: size.width - 24);
    textPainter.paint(
      canvas,
      Offset(
        displayRect.right - textPainter.width - 12,
        displayRect.center.dy - textPainter.height / 2,
      ),
    );

    // Keypad
    if (_showKeypad) {
      for (int i = 0; i < _buttonRects.length; i++) {
        if (i >= _mathButtons.length) break;
        final rect = _buttonRects[i].shift(offset);
        final button = _mathButtons[i];
        final isHovered = _hoveredButton == i;

        Color bgColor;
        Color textColor = const Color(0xFFFFFFFF);
        if ('0123456789.'.contains(button)) {
          bgColor = isHovered
              ? const Color(0xFF444444)
              : const Color(0xFF333333);
        } else if (button == '=') {
          bgColor = isHovered
              ? const Color(0xFF4CAF50)
              : const Color(0xFF43A047);
        } else if ('+-×÷'.contains(button)) {
          bgColor = isHovered
              ? const Color(0xFFFF9500)
              : const Color(0xFFFF9800);
        } else if (button == 'C' || button == '←') {
          bgColor = isHovered
              ? const Color(0xFFE53935)
              : const Color(0xFFF44336);
        } else {
          bgColor = isHovered
              ? const Color(0xFF5C6BC0)
              : const Color(0xFF3F51B5);
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          Paint()..color = bgColor,
        );

        textPainter.text = TextSpan(
          text: button,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    for (int i = 0; i < _buttonRects.length; i++) {
      if (_buttonRects[i].contains(local)) {
        _onButtonPressed(_mathButtons[i]);
        return;
      }
    }
  }

  void _onButtonPressed(String button) {
    if (button == 'C') {
      _expression = '';
    } else if (button == '←') {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    } else if (button == '=') {
      // Simple evaluation would go here
    } else {
      _expression += button;
    }
    _onChanged?.call(_expression);
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _buttonRects.length; i++) {
      if (_buttonRects[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredButton != hovered) {
      _hoveredButton = hovered;
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
