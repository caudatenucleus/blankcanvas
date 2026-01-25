// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';


class RenderJoystick extends RenderBox {
  RenderJoystick({
    void Function(Offset direction)? onMove,
    VoidCallback? onEnd,
    required double joystickSize,
    required Color backgroundColor,
    required Color handleColor,
  }) : _onMove = onMove,
       _onEnd = onEnd,
       _joystickSize = joystickSize,
       _backgroundColor = backgroundColor,
       _handleColor = handleColor {
    _drag = PanGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  void Function(Offset direction)? _onMove;
  set onMove(void Function(Offset direction)? value) => _onMove = value;

  VoidCallback? _onEnd;
  set onEnd(VoidCallback? value) => _onEnd = value;

  double _joystickSize;
  set joystickSize(double value) {
    if (_joystickSize != value) {
      _joystickSize = value;
      markNeedsLayout();
    }
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    _backgroundColor = value;
    markNeedsPaint();
  }

  Color _handleColor;
  set handleColor(Color value) {
    _handleColor = value;
    markNeedsPaint();
  }

  late PanGestureRecognizer _drag;
  Offset _handleOffset = Offset.zero;
  // ignore: unused_field
  bool _isDragging = false;

  double get _handleRadius => _joystickSize * 0.2;
  double get _maxOffset => _joystickSize / 2 - _handleRadius;

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_joystickSize, _joystickSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final center = offset + Offset(size.width / 2, size.height / 2);

    // Outer ring
    canvas.drawCircle(
      center,
      _joystickSize / 2,
      Paint()..color = _backgroundColor.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      center,
      _joystickSize / 2 - 2,
      Paint()
        ..color = _backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner safe zone
    canvas.drawCircle(
      center,
      _maxOffset,
      Paint()..color = const Color(0x11000000),
    );

    // Cross guides
    final guidePaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - _maxOffset, center.dy),
      Offset(center.dx + _maxOffset, center.dy),
      guidePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - _maxOffset),
      Offset(center.dx, center.dy + _maxOffset),
      guidePaint,
    );

    // Handle
    final handleCenter = center + _handleOffset;
    canvas.drawCircle(
      handleCenter,
      _handleRadius + 2,
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawCircle(
      handleCenter,
      _handleRadius,
      Paint()..color = _handleColor,
    );
    canvas.drawCircle(
      handleCenter,
      _handleRadius - 4,
      Paint()..color = _handleColor.withValues(alpha: 0.8),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    var newOffset = _handleOffset + details.delta;
    final distance = newOffset.distance;

    if (distance > _maxOffset) {
      newOffset = Offset.fromDirection(newOffset.direction, _maxOffset);
    }

    _handleOffset = newOffset;

    // Normalize to -1 to 1 range
    final normalized = Offset(
      _handleOffset.dx / _maxOffset,
      _handleOffset.dy / _maxOffset,
    );
    _onMove?.call(normalized);
    markNeedsPaint();
  }

  void _handleDragEnd(DragEndDetails details) {
    _handleOffset = Offset.zero;
    _isDragging = false;
    _onEnd?.call();
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) {
    final center = Offset(size.width / 2, size.height / 2);
    return (position - center).distance < _joystickSize / 2;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }
}
