// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// Long Press Gesture Recognizer Primitive
// =============================================================================

class LongPressGestureRecognizerPrimitive extends LeafRenderObjectWidget {
  const LongPressGestureRecognizerPrimitive({
    super.key,
    required this.onLongPress,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.duration = const Duration(milliseconds: 500),
    this.size = const Size(100, 100),
  });

  final VoidCallback onLongPress;
  final void Function(Offset position)? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final Duration duration;
  final Size size;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLongPressGestureRecognizer(
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      duration: duration,
      preferredSize: size,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLongPressGestureRecognizer renderObject,
  ) {
    renderObject
      ..onLongPress = onLongPress
      ..onLongPressStart = onLongPressStart
      ..onLongPressEnd = onLongPressEnd
      ..duration = duration
      ..preferredSize = size;
  }
}

class RenderLongPressGestureRecognizer extends RenderBox {
  RenderLongPressGestureRecognizer({
    required VoidCallback onLongPress,
    void Function(Offset)? onLongPressStart,
    VoidCallback? onLongPressEnd,
    required Duration duration,
    required Size preferredSize,
  }) : _onLongPress = onLongPress,
       _onLongPressStart = onLongPressStart,
       _onLongPressEnd = onLongPressEnd,
       _duration = duration,
       _preferredSize = preferredSize;

  VoidCallback _onLongPress;
  VoidCallback get onLongPress => _onLongPress;
  set onLongPress(VoidCallback value) => _onLongPress = value;

  void Function(Offset)? _onLongPressStart;
  void Function(Offset)? get onLongPressStart => _onLongPressStart;
  set onLongPressStart(void Function(Offset)? value) =>
      _onLongPressStart = value;

  VoidCallback? _onLongPressEnd;
  VoidCallback? get onLongPressEnd => _onLongPressEnd;
  set onLongPressEnd(VoidCallback? value) => _onLongPressEnd = value;

  Duration _duration;
  Duration get duration => _duration;
  set duration(Duration value) => _duration = value;

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    if (_preferredSize != value) {
      _preferredSize = value;
      markNeedsLayout();
    }
  }

  DateTime? _pressStartTime;
  Offset? _pressPosition;
  bool _longPressTriggered = false;

  @override
  void performLayout() {
    size = constraints.constrain(_preferredSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {}

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pressStartTime = DateTime.now();
      _pressPosition = event.localPosition;
      _longPressTriggered = false;
    } else if (event is PointerMoveEvent) {
      // Cancel if moved too far
      if (_pressPosition != null) {
        final moved = (event.localPosition - _pressPosition!).distance;
        if (moved > 18) {
          _pressStartTime = null;
          _pressPosition = null;
        }
      }
    } else if (event is PointerUpEvent) {
      if (_pressStartTime != null && !_longPressTriggered) {
        final elapsed = DateTime.now().difference(_pressStartTime!);
        if (elapsed >= _duration) {
          _onLongPress();
          _onLongPressEnd?.call();
        }
      }
      if (_longPressTriggered) {
        _onLongPressEnd?.call();
      }
      _pressStartTime = null;
      _pressPosition = null;
    } else if (event is PointerCancelEvent) {
      _pressStartTime = null;
      _pressPosition = null;
    }
  }

  /// Call periodically to check for long press
  void checkLongPress() {
    if (_pressStartTime != null && !_longPressTriggered) {
      final elapsed = DateTime.now().difference(_pressStartTime!);
      if (elapsed >= _duration) {
        _longPressTriggered = true;
        _onLongPressStart?.call(_pressPosition!);
        _onLongPress();
      }
    }
  }
}
