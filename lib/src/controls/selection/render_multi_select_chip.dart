// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';


class RenderMultiSelectChip extends RenderBox {
  RenderMultiSelectChip({required String label, required VoidCallback onRemove})
    : _label = label,
      _onRemove = onRemove {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  String _label;
  set label(String value) {
    if (_label != value) {
      _label = value;
      markNeedsLayout();
    }
  }

  VoidCallback _onRemove;
  set onRemove(VoidCallback value) => _onRemove = value;

  late TapGestureRecognizer _tap;

  @override
  void performLayout() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF2196F3)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Width = text + padding + icon space
    // Height = text + padding
    size = Size(textPainter.width + 16 + 12 + 4, textPainter.height + 8);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Bg
    final Rect rect = offset & size;
    final Paint bg = Paint()..color = const Color(0xFFE3F2FD);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      bg,
    );

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: _label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF2196F3)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(context.canvas, offset + const Offset(8, 4));

    // X Icon (manual paint x)
    final double iconX = offset.dx + size.width - 8 - 8; // Right aligned
    final double iconY = offset.dy + size.height / 2;

    final Paint iconPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    context.canvas.drawLine(
      Offset(iconX - 3, iconY - 3),
      Offset(iconX + 3, iconY + 3),
      iconPaint,
    );
    context.canvas.drawLine(
      Offset(iconX + 3, iconY - 3),
      Offset(iconX - 3, iconY + 3),
      iconPaint,
    );
  }

  void _handleTapUp(TapUpDetails details) {
    if (details.localPosition.dx > size.width - 20) {
      _onRemove();
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
