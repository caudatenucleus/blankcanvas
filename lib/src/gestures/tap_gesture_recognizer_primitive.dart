// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

// =============================================================================
// Tap Gesture Recognizer Primitive - Touch signature detection
// =============================================================================

class TapGestureData {
  const TapGestureData({
    required this.globalPosition,
    required this.localPosition,
    this.buttons = 0,
  });

  final Offset globalPosition;
  final Offset localPosition;
  final int buttons;
}

class TapGestureRecognizerPrimitive extends LeafRenderObjectWidget {
  const TapGestureRecognizerPrimitive({
    super.key,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.size = const Size(100, 100),
  });

  final void Function(TapGestureData) onTapDown;
  final void Function(TapGestureData) onTapUp;
  final VoidCallback onTap;
  final VoidCallback? onTapCancel;
  final VoidCallback? onSecondaryTap;
  final Size size;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTapGestureRecognizer(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTap: onTap,
      onTapCancel: onTapCancel,
      onSecondaryTap: onSecondaryTap,
      preferredSize: size,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTapGestureRecognizer renderObject,
  ) {
    renderObject
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTap = onTap
      ..onTapCancel = onTapCancel
      ..onSecondaryTap = onSecondaryTap
      ..preferredSize = size;
  }
}

class RenderTapGestureRecognizer extends RenderBox {
  RenderTapGestureRecognizer({
    required void Function(TapGestureData) onTapDown,
    required void Function(TapGestureData) onTapUp,
    required VoidCallback onTap,
    VoidCallback? onTapCancel,
    VoidCallback? onSecondaryTap,
    required Size preferredSize,
  }) : _onTapDown = onTapDown,
       _onTapUp = onTapUp,
       _onTap = onTap,
       _onTapCancel = onTapCancel,
       _onSecondaryTap = onSecondaryTap,
       _preferredSize = preferredSize;

  void Function(TapGestureData) _onTapDown;
  void Function(TapGestureData) get onTapDown => _onTapDown;
  set onTapDown(void Function(TapGestureData) value) => _onTapDown = value;

  void Function(TapGestureData) _onTapUp;
  void Function(TapGestureData) get onTapUp => _onTapUp;
  set onTapUp(void Function(TapGestureData) value) => _onTapUp = value;

  VoidCallback _onTap;
  VoidCallback get onTap => _onTap;
  set onTap(VoidCallback value) => _onTap = value;

  VoidCallback? _onTapCancel;
  VoidCallback? get onTapCancel => _onTapCancel;
  set onTapCancel(VoidCallback? value) => _onTapCancel = value;

  VoidCallback? _onSecondaryTap;
  VoidCallback? get onSecondaryTap => _onSecondaryTap;
  set onSecondaryTap(VoidCallback? value) => _onSecondaryTap = value;

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    if (_preferredSize != value) {
      _preferredSize = value;
      markNeedsLayout();
    }
  }

  Offset? _pendingTapPosition;
  int _pendingButtons = 0;

  @override
  void performLayout() {
    size = constraints.constrain(_preferredSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // This is a hit-test-only primitive, no painting needed
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pendingTapPosition = event.localPosition;
      _pendingButtons = event.buttons;
      _onTapDown(
        TapGestureData(
          globalPosition: event.position,
          localPosition: event.localPosition,
          buttons: event.buttons,
        ),
      );
    } else if (event is PointerUpEvent) {
      if (_pendingTapPosition != null) {
        _onTapUp(
          TapGestureData(
            globalPosition: event.position,
            localPosition: event.localPosition,
            buttons: _pendingButtons,
          ),
        );

        // Check if secondary button
        if (_pendingButtons & kSecondaryButton != 0) {
          _onSecondaryTap?.call();
        } else {
          _onTap();
        }
      }
      _pendingTapPosition = null;
    } else if (event is PointerCancelEvent) {
      _onTapCancel?.call();
      _pendingTapPosition = null;
    }
  }
}
