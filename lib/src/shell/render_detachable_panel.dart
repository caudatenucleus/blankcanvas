// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


class RenderDetachablePanel extends RenderProxyBox {
  RenderDetachablePanel({
    required double titleBarHeight,
    required Color titleBarColor,
    required bool isDetached,
    required bool showDetachButton,
  }) : _titleBarHeight = titleBarHeight,
       _titleBarColor = titleBarColor,
       _isDetached = isDetached,
       _showDetachButton = showDetachButton;

  double _titleBarHeight;
  double get titleBarHeight => _titleBarHeight;
  set titleBarHeight(double value) {
    if (_titleBarHeight != value) {
      _titleBarHeight = value;
      markNeedsLayout();
    }
  }

  Color _titleBarColor;
  Color get titleBarColor => _titleBarColor;
  set titleBarColor(Color value) {
    if (_titleBarColor != value) {
      _titleBarColor = value;
      markNeedsPaint();
    }
  }

  bool _isDetached;
  bool get isDetached => _isDetached;
  set isDetached(bool value) {
    if (_isDetached != value) {
      _isDetached = value;
      markNeedsPaint();
    }
  }

  bool _showDetachButton;
  bool get showDetachButton => _showDetachButton;
  set showDetachButton(bool value) {
    if (_showDetachButton != value) {
      _showDetachButton = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      final childConstraints = BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: constraints.maxHeight - _titleBarHeight,
      );
      child!.layout(childConstraints, parentUsesSize: true);
      size = Size(constraints.maxWidth, child!.size.height + _titleBarHeight);
    } else {
      size = Size(constraints.maxWidth, _titleBarHeight);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Draw title bar
    final titleBarRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _titleBarHeight,
    );
    final titleBarPaint = Paint()..color = _titleBarColor;
    canvas.drawRect(titleBarRect, titleBarPaint);

    // Draw detach/attach button
    if (_showDetachButton) {
      final buttonSize = _titleBarHeight - 8;
      final buttonRect = Rect.fromLTWH(
        offset.dx + size.width - buttonSize - 4,
        offset.dy + 4,
        buttonSize,
        buttonSize,
      );

      final buttonPaint = Paint()
        ..color = const Color(0xFF5D5D5D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRect(buttonRect, buttonPaint);

      // Draw arrow icon
      final iconPaint = Paint()
        ..color = const Color(0xFF9D9D9D)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      if (_isDetached) {
        // Down arrow (attach)
        final arrowPath = Path()
          ..moveTo(buttonRect.center.dx - 4, buttonRect.center.dy - 2)
          ..lineTo(buttonRect.center.dx, buttonRect.center.dy + 2)
          ..lineTo(buttonRect.center.dx + 4, buttonRect.center.dy - 2);
        canvas.drawPath(arrowPath, iconPaint);
      } else {
        // Up arrow (detach)
        final arrowPath = Path()
          ..moveTo(buttonRect.center.dx - 4, buttonRect.center.dy + 2)
          ..lineTo(buttonRect.center.dx, buttonRect.center.dy - 2)
          ..lineTo(buttonRect.center.dx + 4, buttonRect.center.dy + 2);
        canvas.drawPath(arrowPath, iconPaint);
      }
    }

    // Paint child below title bar
    if (child != null) {
      context.paintChild(child!, offset + Offset(0, _titleBarHeight));
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null && position.dy > _titleBarHeight) {
      return result.addWithPaintOffset(
        offset: Offset(0, _titleBarHeight),
        position: position,
        hitTest: (result, transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }

  /// Returns true if position is within the detach button
  bool hitTestDetachButton(Offset position) {
    if (!_showDetachButton) return false;
    final buttonSize = _titleBarHeight - 8;
    final buttonRect = Rect.fromLTWH(
      size.width - buttonSize - 4,
      4,
      buttonSize,
      buttonSize,
    );
    return buttonRect.contains(position);
  }
}

// =============================================================================
// FocusModeOverlay - RenderObject for dimming non-active areas
// =============================================================================
