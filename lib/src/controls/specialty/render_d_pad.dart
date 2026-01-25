// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'd_pad.dart';


class RenderDPad extends RenderBox {
  RenderDPad({
    void Function(DPadDirection direction)? onDirection,
    required double dpadSize,
    required Color activeColor,
    required Color inactiveColor,
  }) : _onDirection = onDirection,
       _dpadSize = dpadSize,
       _activeColor = activeColor,
       _inactiveColor = inactiveColor {
    _tap = TapGestureRecognizer()
      ..onTapDown = _handleTapDown
      ..onTapUp = _handleTapUp
      ..onTapCancel = _handleTapCancel;
  }

  void Function(DPadDirection direction)? _onDirection;
  set onDirection(void Function(DPadDirection direction)? value) =>
      _onDirection = value;

  double _dpadSize;
  set dpadSize(double value) {
    if (_dpadSize != value) {
      _dpadSize = value;
      markNeedsLayout();
    }
  }

  Color _activeColor;
  set activeColor(Color value) {
    _activeColor = value;
    markNeedsPaint();
  }

  Color _inactiveColor;
  set inactiveColor(Color value) {
    _inactiveColor = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  DPadDirection? _activeDirection;
  DPadDirection? _hoveredDirection;

  final Map<DPadDirection, Rect> _directionRects = {};

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_dpadSize, _dpadSize));

    final buttonSize = _dpadSize / 3;
    _directionRects[DPadDirection.up] = Rect.fromLTWH(
      buttonSize,
      0,
      buttonSize,
      buttonSize,
    );
    _directionRects[DPadDirection.down] = Rect.fromLTWH(
      buttonSize,
      buttonSize * 2,
      buttonSize,
      buttonSize,
    );
    _directionRects[DPadDirection.left] = Rect.fromLTWH(
      0,
      buttonSize,
      buttonSize,
      buttonSize,
    );
    _directionRects[DPadDirection.right] = Rect.fromLTWH(
      buttonSize * 2,
      buttonSize,
      buttonSize,
      buttonSize,
    );
    _directionRects[DPadDirection.center] = Rect.fromLTWH(
      buttonSize,
      buttonSize,
      buttonSize,
      buttonSize,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw plus-shaped D-Pad
    for (final entry in _directionRects.entries) {
      final dir = entry.key;
      final rect = entry.value.shift(offset);
      final isActive = _activeDirection == dir;
      final isHovered = _hoveredDirection == dir;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6)),
        Paint()
          ..color = isActive
              ? _activeColor
              : (isHovered
                    ? _inactiveColor.withValues(alpha: 0.9)
                    : _inactiveColor),
      );

      // Arrow or dot
      String symbol;
      switch (dir) {
        case DPadDirection.up:
          symbol = '▲';
          break;
        case DPadDirection.down:
          symbol = '▼';
          break;
        case DPadDirection.left:
          symbol = '◀';
          break;
        case DPadDirection.right:
          symbol = '▶';
          break;
        case DPadDirection.center:
          symbol = '●';
          break;
      }

      textPainter.text = TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: 16,
          color: isActive ? const Color(0xFFFFFFFF) : const Color(0xFF999999),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  DPadDirection? _getDirectionAt(Offset position) {
    for (final entry in _directionRects.entries) {
      if (entry.value.contains(position)) {
        return entry.key;
      }
    }
    return null;
  }

  void _handleTapDown(TapDownDetails details) {
    _activeDirection = _getDirectionAt(details.localPosition);
    if (_activeDirection != null) {
      _onDirection?.call(_activeDirection!);
    }
    markNeedsPaint();
  }

  void _handleTapUp(TapUpDetails details) {
    _activeDirection = null;
    markNeedsPaint();
  }

  void _handleTapCancel() {
    _activeDirection = null;
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    final dir = _getDirectionAt(event.localPosition);
    if (_hoveredDirection != dir) {
      _hoveredDirection = dir;
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
