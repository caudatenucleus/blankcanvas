// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// Double Tap Gesture Recognizer Primitive
// =============================================================================

class DoubleTapGestureRecognizerPrimitive extends LeafRenderObjectWidget {
  const DoubleTapGestureRecognizerPrimitive({
    super.key,
    required this.onDoubleTap,
    this.doubleTapTimeout = const Duration(milliseconds: 300),
    this.size = const Size(100, 100),
  });

  final VoidCallback onDoubleTap;
  final Duration doubleTapTimeout;
  final Size size;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDoubleTapGestureRecognizer(
      onDoubleTap: onDoubleTap,
      doubleTapTimeout: doubleTapTimeout,
      preferredSize: size,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDoubleTapGestureRecognizer renderObject,
  ) {
    renderObject
      ..onDoubleTap = onDoubleTap
      ..doubleTapTimeout = doubleTapTimeout
      ..preferredSize = size;
  }
}

class RenderDoubleTapGestureRecognizer extends RenderBox {
  RenderDoubleTapGestureRecognizer({
    required VoidCallback onDoubleTap,
    required Duration doubleTapTimeout,
    required Size preferredSize,
  }) : _onDoubleTap = onDoubleTap,
       _doubleTapTimeout = doubleTapTimeout,
       _preferredSize = preferredSize;

  VoidCallback _onDoubleTap;
  VoidCallback get onDoubleTap => _onDoubleTap;
  set onDoubleTap(VoidCallback value) => _onDoubleTap = value;

  Duration _doubleTapTimeout;
  Duration get doubleTapTimeout => _doubleTapTimeout;
  set doubleTapTimeout(Duration value) => _doubleTapTimeout = value;

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    if (_preferredSize != value) {
      _preferredSize = value;
      markNeedsLayout();
    }
  }

  DateTime? _lastTapTime;
  Offset? _lastTapPosition;

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
    if (event is PointerUpEvent) {
      final now = DateTime.now();

      if (_lastTapTime != null && _lastTapPosition != null) {
        final elapsed = now.difference(_lastTapTime!);
        final distance = (event.localPosition - _lastTapPosition!).distance;

        if (elapsed <= _doubleTapTimeout && distance < 40) {
          _onDoubleTap();
          _lastTapTime = null;
          _lastTapPosition = null;
          return;
        }
      }

      _lastTapTime = now;
      _lastTapPosition = event.localPosition;
    }
  }
}
