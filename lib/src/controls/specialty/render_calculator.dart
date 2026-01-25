// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';


class RenderCalculator extends RenderBox {
  RenderCalculator({void Function(double result)? onResult})
    : _onResult = onResult {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  void Function(double result)? _onResult;
  set onResult(void Function(double result)? value) => _onResult = value;

  late TapGestureRecognizer _tap;

  String _display = '0';
  String _currentInput = '';
  double _accumulator = 0;
  String _operator = '';
  int? _hoveredButton;

  static const _buttons = [
    'C',
    '±',
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '=',
  ];

  static const double _buttonSize = 60.0;
  static const double _spacing = 4.0;
  static const double _displayHeight = 80.0;

  final List<Rect> _buttonRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _buttonRects.clear();
    final width = 4 * _buttonSize + 3 * _spacing;
    final height = _displayHeight + 5 * (_buttonSize + _spacing);
    size = constraints.constrain(Size(width, height));

    // Button positions
    double y = _displayHeight;
    int buttonIndex = 0;
    for (int row = 0; row < 5; row++) {
      double x = 0;
      final buttonsInRow = row == 4 ? 3 : 4;
      for (int col = 0; col < buttonsInRow; col++) {
        final button = _buttons[buttonIndex];
        final buttonWidth = (row == 4 && button == '0')
            ? _buttonSize * 2 + _spacing
            : _buttonSize;
        _buttonRects.add(Rect.fromLTWH(x, y, buttonWidth, _buttonSize));
        x += buttonWidth + _spacing;
        buttonIndex++;
        if (row == 4 && button == '0') {
          col++; // Skip one column for wide 0 button
        }
      }
      y += _buttonSize + _spacing;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Display
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
    textPainter.text = TextSpan(
      text: _display,
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w300,
        color: Color(0xFFFFFFFF),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        displayRect.right - textPainter.width - 16,
        displayRect.center.dy - textPainter.height / 2,
      ),
    );

    // Buttons
    for (int i = 0; i < _buttonRects.length; i++) {
      if (i >= _buttons.length) break;
      final rect = _buttonRects[i].shift(offset);
      final button = _buttons[i];
      final isHovered = _hoveredButton == i;

      Color bgColor;
      Color textColor = const Color(0xFFFFFFFF);
      if ('0123456789.'.contains(button)) {
        bgColor = isHovered ? const Color(0xFF444444) : const Color(0xFF333333);
      } else if (button == '=') {
        bgColor = isHovered ? const Color(0xFFFF9500) : const Color(0xFFFF9800);
      } else if ('+-×÷'.contains(button)) {
        bgColor = isHovered ? const Color(0xFF666666) : const Color(0xFF555555);
      } else {
        bgColor = isHovered ? const Color(0xFF777777) : const Color(0xFF666666);
        textColor = const Color(0xFF000000);
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
        Paint()..color = bgColor,
      );

      textPainter.text = TextSpan(
        text: button,
        style: TextStyle(
          fontSize: 24,
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

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _buttonRects.length; i++) {
      if (_buttonRects[i].contains(local)) {
        _onButtonPressed(_buttons[i]);
        return;
      }
    }
  }

  void _onButtonPressed(String button) {
    if ('0123456789'.contains(button)) {
      _currentInput += button;
      _display = _currentInput;
    } else if (button == '.') {
      if (!_currentInput.contains('.')) {
        _currentInput += _currentInput.isEmpty ? '0.' : '.';
        _display = _currentInput;
      }
    } else if (button == 'C') {
      _currentInput = '';
      _accumulator = 0;
      _operator = '';
      _display = '0';
    } else if (button == '±') {
      if (_currentInput.isNotEmpty) {
        if (_currentInput.startsWith('-')) {
          _currentInput = _currentInput.substring(1);
        } else {
          _currentInput = '-$_currentInput';
        }
        _display = _currentInput;
      }
    } else if (button == '%') {
      if (_currentInput.isNotEmpty) {
        final value = double.parse(_currentInput) / 100;
        _currentInput = value.toString();
        _display = _currentInput;
      }
    } else if ('+-×÷'.contains(button)) {
      if (_currentInput.isNotEmpty) {
        _accumulator = double.parse(_currentInput);
        _currentInput = '';
        _operator = button;
      }
    } else if (button == '=') {
      if (_currentInput.isNotEmpty && _operator.isNotEmpty) {
        final current = double.parse(_currentInput);
        double result;
        switch (_operator) {
          case '+':
            result = _accumulator + current;
            break;
          case '-':
            result = _accumulator - current;
            break;
          case '×':
            result = _accumulator * current;
            break;
          case '÷':
            result = current != 0 ? _accumulator / current : 0;
            break;
          default:
            result = current;
        }
        _display = result.toString();
        if (_display.endsWith('.0')) {
          _display = _display.substring(0, _display.length - 2);
        }
        _currentInput = _display;
        _accumulator = result;
        _operator = '';
        _onResult?.call(result);
      }
    }
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
