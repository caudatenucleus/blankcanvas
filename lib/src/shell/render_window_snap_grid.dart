// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


class RenderWindowSnapGrid extends RenderBox {
  RenderWindowSnapGrid({
    required int columns,
    required int rows,
    required Color gridColor,
    required int hoveredZone,
    required bool showLabels,
  }) : _columns = columns,
       _rows = rows,
       _gridColor = gridColor,
       _hoveredZone = hoveredZone,
       _showLabels = showLabels;

  int _columns;
  int get columns => _columns;
  set columns(int value) {
    if (_columns != value) {
      _columns = value;
      markNeedsPaint();
    }
  }

  int _rows;
  int get rows => _rows;
  set rows(int value) {
    if (_rows != value) {
      _rows = value;
      markNeedsPaint();
    }
  }

  Color _gridColor;
  Color get gridColor => _gridColor;
  set gridColor(Color value) {
    if (_gridColor != value) {
      _gridColor = value;
      markNeedsPaint();
    }
  }

  int _hoveredZone;
  int get hoveredZone => _hoveredZone;
  set hoveredZone(int value) {
    if (_hoveredZone != value) {
      _hoveredZone = value;
      markNeedsPaint();
    }
  }

  bool _showLabels;
  bool get showLabels => _showLabels;
  set showLabels(bool value) {
    if (_showLabels != value) {
      _showLabels = value;
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
    final zoneWidth = size.width / _columns;
    final zoneHeight = size.height / _rows;

    final linePaint = Paint()
      ..color = _gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 1; i < _columns; i++) {
      final x = offset.dx + zoneWidth * i;
      canvas.drawLine(
        Offset(x, offset.dy),
        Offset(x, offset.dy + size.height),
        linePaint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i < _rows; i++) {
      final y = offset.dy + zoneHeight * i;
      canvas.drawLine(
        Offset(offset.dx, y),
        Offset(offset.dx + size.width, y),
        linePaint,
      );
    }

    // Draw hovered zone highlight
    if (_hoveredZone >= 0 && _hoveredZone < _columns * _rows) {
      final row = _hoveredZone ~/ _columns;
      final col = _hoveredZone % _columns;
      final zoneRect = Rect.fromLTWH(
        offset.dx + col * zoneWidth,
        offset.dy + row * zoneHeight,
        zoneWidth,
        zoneHeight,
      );
      final highlightPaint = Paint()
        ..color = _gridColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(zoneRect, highlightPaint);
    }

    // Draw zone labels
    if (_showLabels) {
      for (int row = 0; row < _rows; row++) {
        for (int col = 0; col < _columns; col++) {
          final zoneIndex = row * _columns + col;
          final centerX = offset.dx + col * zoneWidth + zoneWidth / 2;
          final centerY = offset.dy + row * zoneHeight + zoneHeight / 2;

          final labelBuilder =
              ui.ParagraphBuilder(
                  ui.ParagraphStyle(textAlign: TextAlign.center),
                )
                ..pushStyle(ui.TextStyle(color: _gridColor, fontSize: 14))
                ..addText('$zoneIndex');

          final paragraph = labelBuilder.build()
            ..layout(const ui.ParagraphConstraints(width: 50));

          canvas.drawParagraph(paragraph, Offset(centerX - 25, centerY - 7));
        }
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  /// Returns zone index at given local position
  int getZoneAt(Offset localPosition) {
    final zoneWidth = size.width / _columns;
    final zoneHeight = size.height / _rows;
    final col = (localPosition.dx / zoneWidth).floor();
    final row = (localPosition.dy / zoneHeight).floor();
    if (col >= 0 && col < _columns && row >= 0 && row < _rows) {
      return row * _columns + col;
    }
    return -1;
  }
}

// =============================================================================
// DetachablePanelContainer - RenderObject for dock/undock panel behavior
// =============================================================================
