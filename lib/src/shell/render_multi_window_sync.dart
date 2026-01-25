// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'window_state_data.dart';


class RenderMultiWindowSync extends RenderBox {
  RenderMultiWindowSync({
    required List<WindowStateData> windows,
    required String activeWindowId,
    required Color windowColor,
    required Color activeColor,
    required Color borderColor,
  }) : _windows = windows,
       _activeWindowId = activeWindowId,
       _windowColor = windowColor,
       _activeColor = activeColor,
       _borderColor = borderColor;

  List<WindowStateData> _windows;
  List<WindowStateData> get windows => _windows;
  set windows(List<WindowStateData> value) {
    if (_windows != value) {
      _windows = value;
      markNeedsPaint();
    }
  }

  String _activeWindowId;
  String get activeWindowId => _activeWindowId;
  set activeWindowId(String value) {
    if (_activeWindowId != value) {
      _activeWindowId = value;
      markNeedsPaint();
    }
  }

  Color _windowColor;
  Color get windowColor => _windowColor;
  set windowColor(Color value) {
    if (_windowColor != value) {
      _windowColor = value;
      markNeedsPaint();
    }
  }

  Color _activeColor;
  Color get activeColor => _activeColor;
  set activeColor(Color value) {
    if (_activeColor != value) {
      _activeColor = value;
      markNeedsPaint();
    }
  }

  Color _borderColor;
  Color get borderColor => _borderColor;
  set borderColor(Color value) {
    if (_borderColor != value) {
      _borderColor = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Calculate scale to fit all windows in view
    if (_windows.isEmpty) return;

    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final window in _windows) {
      if (window.bounds.left < minX) minX = window.bounds.left;
      if (window.bounds.top < minY) minY = window.bounds.top;
      if (window.bounds.right > maxX) maxX = window.bounds.right;
      if (window.bounds.bottom > maxY) maxY = window.bounds.bottom;
    }

    final totalWidth = maxX - minX;
    final totalHeight = maxY - minY;
    final scaleX = size.width / totalWidth;
    final scaleY = size.height / totalHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    for (final window in _windows) {
      final isActive = window.id == _activeWindowId;
      final scaledRect = Rect.fromLTWH(
        offset.dx + (window.bounds.left - minX) * scale,
        offset.dy + (window.bounds.top - minY) * scale,
        window.bounds.width * scale,
        window.bounds.height * scale,
      );

      // Draw window background
      final fillPaint = Paint()
        ..color = isActive ? _activeColor : _windowColor
        ..style = PaintingStyle.fill;
      canvas.drawRect(scaledRect, fillPaint);

      // Draw window border
      final borderPaint = Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(scaledRect, borderPaint);

      // Draw title bar
      final titleBarRect = Rect.fromLTWH(
        scaledRect.left,
        scaledRect.top,
        scaledRect.width,
        20.0 * scale,
      );
      final titlePaint = Paint()
        ..color = isActive
            ? _activeColor.withValues(alpha: 0.8)
            : _windowColor.withValues(alpha: 0.8);
      canvas.drawRect(titleBarRect, titlePaint);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

// =============================================================================
// WindowSnapGridOverlay - RenderObject for snap zone visualization
// =============================================================================
