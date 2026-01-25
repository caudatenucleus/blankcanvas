// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'password_strength_meter.dart';


class RenderPasswordStrengthMeter extends RenderBox {
  RenderPasswordStrengthMeter({
    required String password,
    required int minLength,
  }) : _password = password,
       _minLength = minLength;

  String _password;
  set password(String value) {
    if (_password != value) {
      _password = value;
      markNeedsPaint();
    }
  }

  int _minLength;
  set minLength(int value) => _minLength = value;

  PasswordStrength get _strength {
    if (_password.isEmpty) return PasswordStrength.none;

    int score = 0;
    if (_password.length >= _minLength) score++;
    if (_password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(_password)) score++;
    if (RegExp(r'[a-z]').hasMatch(_password)) score++;
    if (RegExp(r'[0-9]').hasMatch(_password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_password)) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 2) return PasswordStrength.fair;
    if (score <= 4) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  static const double _height = 8.0;
  static const double _barSpacing = 4.0;

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _height + 20));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final strength = _strength;

    // Colors for each strength level
    final colors = {
      PasswordStrength.none: const Color(0xFFE0E0E0),
      PasswordStrength.weak: const Color(0xFFE53935),
      PasswordStrength.fair: const Color(0xFFFF9800),
      PasswordStrength.good: const Color(0xFFFFC107),
      PasswordStrength.strong: const Color(0xFF4CAF50),
    };

    final labels = {
      PasswordStrength.none: '',
      PasswordStrength.weak: 'Weak',
      PasswordStrength.fair: 'Fair',
      PasswordStrength.good: 'Good',
      PasswordStrength.strong: 'Strong',
    };

    // Draw 4 strength bars
    final barWidth = (size.width - 3 * _barSpacing) / 4;
    final filledBars = strength == PasswordStrength.none
        ? 0
        : strength == PasswordStrength.weak
        ? 1
        : strength == PasswordStrength.fair
        ? 2
        : strength == PasswordStrength.good
        ? 3
        : 4;

    for (int i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(
        offset.dx + i * (barWidth + _barSpacing),
        offset.dy,
        barWidth,
        _height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..color = i < filledBars
              ? colors[strength]!
              : const Color(0xFFE0E0E0),
      );
    }

    // Draw label
    if (strength != PasswordStrength.none) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[strength],
          style: TextStyle(fontSize: 12, color: colors[strength]),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(offset.dx, offset.dy + _height + 4));
    }
  }
}
