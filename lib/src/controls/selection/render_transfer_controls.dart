// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

class RenderTransferControls extends RenderBox {
  RenderTransferControls({
    VoidCallback? onToRight,
    VoidCallback? onAllToRight,
    VoidCallback? onToLeft,
    VoidCallback? onAllToLeft,
  }) : _onToRight = onToRight,
       _onAllToRight = onAllToRight,
       _onToLeft = onToLeft,
       _onAllToLeft = onAllToLeft {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  VoidCallback? _onToRight;
  set onToRight(VoidCallback? val) {
    if (_onToRight != val) {
      _onToRight = val;
      markNeedsPaint();
    }
  }

  VoidCallback? _onAllToRight;
  set onAllToRight(VoidCallback? val) {
    if (_onAllToRight != val) {
      _onAllToRight = val;
      markNeedsPaint();
    }
  }

  VoidCallback? _onToLeft;
  set onToLeft(VoidCallback? val) {
    if (_onToLeft != val) {
      _onToLeft = val;
      markNeedsPaint();
    }
  }

  VoidCallback? _onAllToLeft;
  set onAllToLeft(VoidCallback? val) {
    if (_onAllToLeft != val) {
      _onAllToLeft = val;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;

  static const double _btnSize = 32.0;
  static const double _gap = 8.0;

  @override
  void performLayout() {
    size = Size(64, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    double startY = (size.height - (4 * _btnSize + 3 * _gap)) / 2;
    double x = offset.dx + (size.width - _btnSize) / 2;

    _paintBtn(context, offset, x, startY, 0, _onToRight); // >
    _paintBtn(
      context,
      offset,
      x,
      startY + _btnSize + _gap,
      1,
      _onAllToRight,
    ); // >>
    _paintBtn(
      context,
      offset,
      x,
      startY + 2 * (_btnSize + _gap),
      2,
      _onToLeft,
    ); // <
    _paintBtn(
      context,
      offset,
      x,
      startY + 3 * (_btnSize + _gap),
      3,
      _onAllToLeft,
    ); // <<
  }

  void _paintBtn(
    PaintingContext context,
    Offset offset,
    double x,
    double y,
    int type,
    VoidCallback? cb,
  ) {
    final bool enabled = cb != null;
    final Rect rect = Rect.fromLTWH(x, offset.dy + y, _btnSize, _btnSize);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = enabled ? Color(0xFF2196F3) : Color(0xFFE0E0E0);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4)),
      paint,
    );

    final Paint iconPaint = Paint()
      ..color = enabled ? Color(0xFF2196F3) : Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Path p = Path();
    double cx = rect.center.dx;
    double cy = rect.center.dy;

    if (type == 0) {
      // >
      p.moveTo(cx - 2, cy - 4);
      p.lineTo(cx + 2, cy);
      p.lineTo(cx - 2, cy + 4);
    } else if (type == 1) {
      // >>
      p.moveTo(cx - 4, cy - 4);
      p.lineTo(cx, cy);
      p.lineTo(cx - 4, cy + 4);
      p.moveTo(cx, cy - 4);
      p.lineTo(cx + 4, cy);
      p.lineTo(cx, cy + 4);
    } else if (type == 2) {
      // <
      p.moveTo(cx + 2, cy - 4);
      p.lineTo(cx - 2, cy);
      p.lineTo(cx + 2, cy + 4);
    } else if (type == 3) {
      // <<
      p.moveTo(cx + 4, cy - 4);
      p.lineTo(cx, cy);
      p.lineTo(cx + 4, cy + 4);
      p.moveTo(cx, cy - 4);
      p.lineTo(cx - 4, cy);
      p.lineTo(cx, cy + 4);
    }
    context.canvas.drawPath(p, iconPaint);
  }

  void _handleTapUp(TapUpDetails details) {
    double startY = (size.height - (4 * _btnSize + 3 * _gap)) / 2;
    double localY = details.localPosition.dy;
    double xStart = (size.width - _btnSize) / 2;

    if (details.localPosition.dx < xStart ||
        details.localPosition.dx > xStart + _btnSize) {
      return;
    }

    if (localY >= startY && localY <= startY + _btnSize) {
      _onToRight?.call();
    } else if (localY >= startY + _btnSize + _gap &&
        localY <= startY + 2 * _btnSize + _gap) {
      _onAllToRight?.call();
    } else if (localY >= startY + 2 * (_btnSize + _gap) &&
        localY <= startY + 3 * _btnSize + 2 * _gap) {
      _onToLeft?.call();
    } else if (localY >= startY + 3 * (_btnSize + _gap) &&
        localY <= startY + 4 * _btnSize + 3 * _gap) {
      _onAllToLeft?.call();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }
}
