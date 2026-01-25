// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


class RenderFocusModeOverlay extends RenderProxyBox {
  RenderFocusModeOverlay({
    required bool isActive,
    required double dimAmount,
    required Color dimColor,
    Rect? focusRect,
  }) : _isActive = isActive,
       _dimAmount = dimAmount,
       _dimColor = dimColor,
       _focusRect = focusRect;

  bool _isActive;
  bool get isActive => _isActive;
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      markNeedsPaint();
    }
  }

  double _dimAmount;
  double get dimAmount => _dimAmount;
  set dimAmount(double value) {
    if (_dimAmount != value) {
      _dimAmount = value;
      markNeedsPaint();
    }
  }

  Color _dimColor;
  Color get dimColor => _dimColor;
  set dimColor(Color value) {
    if (_dimColor != value) {
      _dimColor = value;
      markNeedsPaint();
    }
  }

  Rect? _focusRect;
  Rect? get focusRect => _focusRect;
  set focusRect(Rect? value) {
    if (_focusRect != value) {
      _focusRect = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint child first
    if (child != null) {
      context.paintChild(child!, offset);
    }

    // Paint dim overlay if active
    if (_isActive) {
      final canvas = context.canvas;
      final dimPaint = Paint()..color = _dimColor.withValues(alpha: _dimAmount);

      if (_focusRect != null) {
        // Create path that excludes the focus area
        final fullPath = Path()
          ..addRect(
            Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
          );
        final focusPath = Path()..addRect(_focusRect!.shift(offset));
        final combinedPath = Path.combine(
          PathOperation.difference,
          fullPath,
          focusPath,
        );
        canvas.drawPath(combinedPath, dimPaint);
      } else {
        // Dim everything
        canvas.drawRect(
          Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
          dimPaint,
        );
      }
    }
  }
}

// =============================================================================
// WindowGroupTab - RenderObject for tab-style window group switcher
// =============================================================================
