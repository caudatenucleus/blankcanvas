// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'window_group_tab_data.dart';


class RenderWindowGroupTabs extends RenderBox {
  RenderWindowGroupTabs({
    required List<WindowGroupTabData> groups,
    required String activeGroupId,
    required double tabHeight,
    required double tabMinWidth,
    required Color backgroundColor,
    required Color activeTabColor,
    required Color inactiveTabColor,
    required Color textColor,
  }) : _groups = groups,
       _activeGroupId = activeGroupId,
       _tabHeight = tabHeight,
       _tabMinWidth = tabMinWidth,
       _backgroundColor = backgroundColor,
       _activeTabColor = activeTabColor,
       _inactiveTabColor = inactiveTabColor,
       _textColor = textColor;

  List<WindowGroupTabData> _groups;
  List<WindowGroupTabData> get groups => _groups;
  set groups(List<WindowGroupTabData> value) {
    if (_groups != value) {
      _groups = value;
      markNeedsPaint();
    }
  }

  String _activeGroupId;
  String get activeGroupId => _activeGroupId;
  set activeGroupId(String value) {
    if (_activeGroupId != value) {
      _activeGroupId = value;
      markNeedsPaint();
    }
  }

  double _tabHeight;
  double get tabHeight => _tabHeight;
  set tabHeight(double value) {
    if (_tabHeight != value) {
      _tabHeight = value;
      markNeedsLayout();
    }
  }

  double _tabMinWidth;
  double get tabMinWidth => _tabMinWidth;
  set tabMinWidth(double value) {
    if (_tabMinWidth != value) {
      _tabMinWidth = value;
      markNeedsLayout();
    }
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  Color _activeTabColor;
  Color get activeTabColor => _activeTabColor;
  set activeTabColor(Color value) {
    if (_activeTabColor != value) {
      _activeTabColor = value;
      markNeedsPaint();
    }
  }

  Color _inactiveTabColor;
  Color get inactiveTabColor => _inactiveTabColor;
  set inactiveTabColor(Color value) {
    if (_inactiveTabColor != value) {
      _inactiveTabColor = value;
      markNeedsPaint();
    }
  }

  Color _textColor;
  Color get textColor => _textColor;
  set textColor(Color value) {
    if (_textColor != value) {
      _textColor = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    final totalTabWidth =
        _groups.length * _tabMinWidth + 30; // +30 for add button
    size = Size(constraints.constrainWidth(totalTabWidth), _tabHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Draw background
    final bgPaint = Paint()..color = _backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      bgPaint,
    );

    // Draw tabs
    double xOffset = offset.dx;
    for (final group in _groups) {
      final isActive = group.id == _activeGroupId;
      final tabWidth = _tabMinWidth;
      final tabRect = Rect.fromLTWH(xOffset, offset.dy, tabWidth, _tabHeight);

      // Tab background
      final tabPaint = Paint()
        ..color = isActive ? _activeTabColor : _inactiveTabColor;

      final tabPath = Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            tabRect,
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          ),
        );
      canvas.drawPath(tabPath, tabPaint);

      // Tab text
      final textBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(textAlign: TextAlign.center, maxLines: 1),
            )
            ..pushStyle(ui.TextStyle(color: _textColor, fontSize: 11))
            ..addText('${group.name} (${group.windowCount})');

      final paragraph = textBuilder.build()
        ..layout(ui.ParagraphConstraints(width: tabWidth - 8));

      canvas.drawParagraph(
        paragraph,
        Offset(xOffset + 4, offset.dy + (_tabHeight - paragraph.height) / 2),
      );

      xOffset += tabWidth + 2;
    }

    // Draw add button
    final addButtonRect = Rect.fromLTWH(
      xOffset,
      offset.dy + 4,
      20,
      _tabHeight - 8,
    );
    final addPaint = Paint()
      ..color = _inactiveTabColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(addButtonRect, const Radius.circular(4)),
      addPaint,
    );

    // Plus icon
    final plusPaint = Paint()
      ..color = _textColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(addButtonRect.center.dx - 4, addButtonRect.center.dy),
      Offset(addButtonRect.center.dx + 4, addButtonRect.center.dy),
      plusPaint,
    );
    canvas.drawLine(
      Offset(addButtonRect.center.dx, addButtonRect.center.dy - 4),
      Offset(addButtonRect.center.dx, addButtonRect.center.dy + 4),
      plusPaint,
    );
  }

  @override
  bool hitTestSelf(Offset position) => true;

  /// Returns group id at position, or null if none
  String? getGroupAt(Offset localPosition) {
    double xOffset = 0;
    for (final group in _groups) {
      if (localPosition.dx >= xOffset &&
          localPosition.dx < xOffset + _tabMinWidth &&
          localPosition.dy >= 0 &&
          localPosition.dy < _tabHeight) {
        return group.id;
      }
      xOffset += _tabMinWidth + 2;
    }
    return null;
  }
}

// =============================================================================
// PersistentLayoutState - RenderObject for visualizing layout state
// =============================================================================
