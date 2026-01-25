// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;


class RenderCaptcha extends RenderBox {
  RenderCaptcha({void Function(bool verified)? onVerified, required int length})
    : _onVerified = onVerified,
      _length = length {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _generateCaptcha();
  }

  void Function(bool verified)? _onVerified;
  set onVerified(void Function(bool verified)? value) => _onVerified = value;

  int _length;
  set length(int value) {
    if (_length != value) {
      _length = value;
      _generateCaptcha();
    }
  }

  late TapGestureRecognizer _tap;
  String _captchaText = '';
  String _userInput = '';
  bool _isVerified = false;
  int? _hoveredButton;

  static const double _captchaHeight = 60.0;
  static const double _inputHeight = 44.0;
  static const double _buttonWidth = 100.0;
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  Rect _refreshRect = Rect.zero;
  Rect _verifyRect = Rect.zero;

  void _generateCaptcha() {
    final random = math.Random();
    _captchaText = List.generate(
      _length,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
    _userInput = '';
    _isVerified = false;
    markNeedsPaint();
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, _captchaHeight + _inputHeight + 60),
    );
    _refreshRect = Rect.fromLTWH(
      size.width - _buttonWidth * 2 - 8,
      _captchaHeight + _inputHeight + 16,
      _buttonWidth,
      36,
    );
    _verifyRect = Rect.fromLTWH(
      size.width - _buttonWidth,
      _captchaHeight + _inputHeight + 16,
      _buttonWidth,
      36,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final random = math.Random(42);

    // Captcha box
    final captchaRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _captchaHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(captchaRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFE8E8E8),
    );

    // Noise lines
    final noisePaint = Paint()..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      noisePaint.color = Color.fromRGBO(
        random.nextInt(200),
        random.nextInt(200),
        random.nextInt(200),
        0.5,
      );
      canvas.drawLine(
        Offset(
          offset.dx + random.nextDouble() * size.width,
          offset.dy + random.nextDouble() * _captchaHeight,
        ),
        Offset(
          offset.dx + random.nextDouble() * size.width,
          offset.dy + random.nextDouble() * _captchaHeight,
        ),
        noisePaint,
      );
    }

    // Captcha text with distortion
    final charWidth = (size.width - 40) / _length;
    for (int i = 0; i < _captchaText.length; i++) {
      final color = Color.fromRGBO(
        random.nextInt(100) + 50,
        random.nextInt(100) + 50,
        random.nextInt(100) + 50,
        1,
      );
      textPainter.text = TextSpan(
        text: _captchaText[i],
        style: TextStyle(
          fontSize: 28 + random.nextDouble() * 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(
        offset.dx + 20 + i * charWidth + charWidth / 2,
        offset.dy + _captchaHeight / 2,
      );
      canvas.rotate((random.nextDouble() - 0.5) * 0.4);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Input field
    final inputRect = Rect.fromLTWH(
      offset.dx,
      offset.dy + _captchaHeight + 8,
      size.width,
      _inputHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inputRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inputRect, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _isVerified
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE0E0E0),
    );

    textPainter.text = TextSpan(
      text: _userInput.isEmpty ? 'Enter code above...' : _userInput,
      style: TextStyle(
        fontSize: 16,
        color: _userInput.isEmpty
            ? const Color(0xFF999999)
            : const Color(0xFF333333),
        letterSpacing: 4,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(inputRect.left + 12, inputRect.center.dy - textPainter.height / 2),
    );

    // Status indicator
    if (_isVerified) {
      textPainter.text = const TextSpan(
        text: '✓',
        style: TextStyle(fontSize: 20, color: Color(0xFF4CAF50)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          inputRect.right - 32,
          inputRect.center.dy - textPainter.height / 2,
        ),
      );
    }

    // Buttons
    _paintButton(
      canvas,
      _refreshRect.shift(offset),
      '↻ Refresh',
      _hoveredButton == 0,
      const Color(0xFF666666),
    );
    _paintButton(
      canvas,
      _verifyRect.shift(offset),
      'Verify',
      _hoveredButton == 1,
      const Color(0xFF2196F3),
    );
  }

  void _paintButton(
    Canvas canvas,
    Rect rect,
    String text,
    bool isHovered,
    Color color,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = isHovered ? color : color.withValues(alpha: 0.85),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    if (_refreshRect.contains(local)) {
      _generateCaptcha();
    } else if (_verifyRect.contains(local)) {
      _isVerified = _userInput.toUpperCase() == _captchaText;
      _onVerified?.call(_isVerified);
      markNeedsPaint();
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    if (_refreshRect.contains(local)) {
      hovered = 0;
    } else if (_verifyRect.contains(local))
      hovered = 1;

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
