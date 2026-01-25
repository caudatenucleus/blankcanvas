// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'layout_state_data.dart';


class RenderPersistentLayoutState extends RenderBox {
  RenderPersistentLayoutState({
    required List<LayoutStateData> elements,
    required Color borderColor,
    required Color labelColor,
    required bool showLabels,
  }) : _elements = elements,
       _borderColor = borderColor,
       _labelColor = labelColor,
       _showLabels = showLabels;

  List<LayoutStateData> _elements;
  List<LayoutStateData> get elements => _elements;
  set elements(List<LayoutStateData> value) {
    if (_elements != value) {
      _elements = value;
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

  Color _labelColor;
  Color get labelColor => _labelColor;
  set labelColor(Color value) {
    if (_labelColor != value) {
      _labelColor = value;
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
    final borderPaint = Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final element in _elements) {
      final rect = element.bounds.shift(offset);

      // Draw dashed border
      canvas.drawRect(rect, borderPaint);

      // Draw label
      if (_showLabels && element.label != null) {
        final labelBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
          ..pushStyle(
            ui.TextStyle(
              color: _labelColor,
              fontSize: 10,
              background: Paint()..color = _borderColor,
            ),
          )
          ..addText(' ${element.label} ');

        final paragraph = labelBuilder.build()
          ..layout(ui.ParagraphConstraints(width: rect.width));

        canvas.drawParagraph(paragraph, rect.topLeft);
      }
    }
  }
}

// =============================================================================
// MultiMonitorCanvas - RenderObject for multi-monitor visualization
// =============================================================================
