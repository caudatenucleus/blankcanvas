// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'monitor_data.dart';


class RenderMultiMonitorCanvas extends RenderProxyBox {
  RenderMultiMonitorCanvas({
    required List<MonitorData> monitors,
    required Color monitorColor,
    required Color primaryColor,
    required Color borderColor,
    required double gapBetweenMonitors,
  }) : _monitors = monitors,
       _monitorColor = monitorColor,
       _primaryColor = primaryColor,
       _borderColor = borderColor,
       _gapBetweenMonitors = gapBetweenMonitors;

  List<MonitorData> _monitors;
  List<MonitorData> get monitors => _monitors;
  set monitors(List<MonitorData> value) {
    if (_monitors != value) {
      _monitors = value;
      markNeedsPaint();
    }
  }

  Color _monitorColor;
  Color get monitorColor => _monitorColor;
  set monitorColor(Color value) {
    if (_monitorColor != value) {
      _monitorColor = value;
      markNeedsPaint();
    }
  }

  Color _primaryColor;
  Color get primaryColor => _primaryColor;
  set primaryColor(Color value) {
    if (_primaryColor != value) {
      _primaryColor = value;
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

  double _gapBetweenMonitors;
  double get gapBetweenMonitors => _gapBetweenMonitors;
  set gapBetweenMonitors(double value) {
    if (_gapBetweenMonitors != value) {
      _gapBetweenMonitors = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Calculate scale to fit all monitors
    if (_monitors.isEmpty) {
      if (child != null) context.paintChild(child!, offset);
      return;
    }

    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final monitor in _monitors) {
      if (monitor.bounds.left < minX) minX = monitor.bounds.left;
      if (monitor.bounds.top < minY) minY = monitor.bounds.top;
      if (monitor.bounds.right > maxX) maxX = monitor.bounds.right;
      if (monitor.bounds.bottom > maxY) maxY = monitor.bounds.bottom;
    }

    final totalWidth = maxX - minX;
    final totalHeight = maxY - minY;
    final scaleX = size.width / totalWidth;
    final scaleY = size.height / totalHeight;
    final scale = (scaleX < scaleY ? scaleX : scaleY) * 0.9;

    final offsetX = (size.width - totalWidth * scale) / 2;
    final offsetY = (size.height - totalHeight * scale) / 2;

    for (final monitor in _monitors) {
      final scaledRect = Rect.fromLTWH(
        offset.dx + offsetX + (monitor.bounds.left - minX) * scale,
        offset.dy + offsetY + (monitor.bounds.top - minY) * scale,
        monitor.bounds.width * scale - _gapBetweenMonitors,
        monitor.bounds.height * scale - _gapBetweenMonitors,
      );

      // Monitor background
      final fillPaint = Paint()
        ..color = monitor.isPrimary
            ? _primaryColor.withValues(alpha: 0.3)
            : _monitorColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, const Radius.circular(4)),
        fillPaint,
      );

      // Monitor border
      final borderPaint = Paint()
        ..color = monitor.isPrimary ? _primaryColor : _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = monitor.isPrimary ? 2.0 : 1.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, const Radius.circular(4)),
        borderPaint,
      );

      // Monitor label
      final labelBuilder =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
            ..pushStyle(
              ui.TextStyle(
                color: monitor.isPrimary ? _primaryColor : _borderColor,
                fontSize: 12,
              ),
            )
            ..addText(monitor.name ?? 'Display ${monitor.index + 1}');

      final paragraph = labelBuilder.build()
        ..layout(ui.ParagraphConstraints(width: scaledRect.width));

      canvas.drawParagraph(
        paragraph,
        Offset(scaledRect.left, scaledRect.center.dy - paragraph.height / 2),
      );
    }

    // Paint child content on top
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}

// =============================================================================
// WorkspaceProfileSelector - RenderObject for profile selection
// =============================================================================
