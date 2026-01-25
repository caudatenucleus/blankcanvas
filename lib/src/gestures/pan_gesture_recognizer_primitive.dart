// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'velocity_tracker_primitive.dart';

// =============================================================================
// Pan Gesture Recognizer Primitive - Continuous movement tracking
// =============================================================================

class PanGestureData {
  const PanGestureData({
    required this.globalPosition,
    required this.localPosition,
    required this.delta,
    required this.velocity,
  });

  final Offset globalPosition;
  final Offset localPosition;
  final Offset delta;
  final Velocity velocity;
}

class PanGestureRecognizerPrimitive extends LeafRenderObjectWidget {
  const PanGestureRecognizerPrimitive({
    super.key,
    this.onPanStart,
    required this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.minFlingVelocity = 50.0,
    this.size = const Size(100, 100),
  });

  final void Function(PanGestureData)? onPanStart;
  final void Function(PanGestureData) onPanUpdate;
  final void Function(PanGestureData)? onPanEnd;
  final VoidCallback? onPanCancel;
  final double minFlingVelocity;
  final Size size;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPanGestureRecognizer(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      minFlingVelocity: minFlingVelocity,
      preferredSize: size,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPanGestureRecognizer renderObject,
  ) {
    renderObject
      ..onPanStart = onPanStart
      ..onPanUpdate = onPanUpdate
      ..onPanEnd = onPanEnd
      ..onPanCancel = onPanCancel
      ..minFlingVelocity = minFlingVelocity
      ..preferredSize = size;
  }
}

class RenderPanGestureRecognizer extends RenderBox {
  RenderPanGestureRecognizer({
    void Function(PanGestureData)? onPanStart,
    required void Function(PanGestureData) onPanUpdate,
    void Function(PanGestureData)? onPanEnd,
    VoidCallback? onPanCancel,
    required double minFlingVelocity,
    required Size preferredSize,
  }) : _onPanStart = onPanStart,
       _onPanUpdate = onPanUpdate,
       _onPanEnd = onPanEnd,
       _onPanCancel = onPanCancel,
       _minFlingVelocity = minFlingVelocity,
       _preferredSize = preferredSize;

  void Function(PanGestureData)? _onPanStart;
  void Function(PanGestureData)? get onPanStart => _onPanStart;
  set onPanStart(void Function(PanGestureData)? value) => _onPanStart = value;

  void Function(PanGestureData) _onPanUpdate;
  void Function(PanGestureData) get onPanUpdate => _onPanUpdate;
  set onPanUpdate(void Function(PanGestureData) value) => _onPanUpdate = value;

  void Function(PanGestureData)? _onPanEnd;
  void Function(PanGestureData)? get onPanEnd => _onPanEnd;
  set onPanEnd(void Function(PanGestureData)? value) => _onPanEnd = value;

  VoidCallback? _onPanCancel;
  VoidCallback? get onPanCancel => _onPanCancel;
  set onPanCancel(VoidCallback? value) => _onPanCancel = value;

  double _minFlingVelocity;
  double get minFlingVelocity => _minFlingVelocity;
  set minFlingVelocity(double value) => _minFlingVelocity = value;

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    if (_preferredSize != value) {
      _preferredSize = value;
      markNeedsLayout();
    }
  }

  final VelocityTrackerPrimitive _velocityTracker = VelocityTrackerPrimitive();
  Offset? _lastPosition;
  bool _isPanning = false;

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
      _lastPosition = event.localPosition;
      _velocityTracker.reset();
      _velocityTracker.addPosition(event.timeStamp, event.localPosition);
    } else if (event is PointerMoveEvent) {
      _velocityTracker.addPosition(event.timeStamp, event.localPosition);

      if (!_isPanning && _lastPosition != null) {
        // Check if movement exceeds threshold
        final delta = event.localPosition - _lastPosition!;
        if (delta.distance > 10) {
          _isPanning = true;
          _onPanStart?.call(
            PanGestureData(
              globalPosition: event.position,
              localPosition: event.localPosition,
              delta: Offset.zero,
              velocity: Velocity.zero,
            ),
          );
        }
      }

      if (_isPanning) {
        final delta =
            event.localPosition - (_lastPosition ?? event.localPosition);
        _lastPosition = event.localPosition;

        _onPanUpdate(
          PanGestureData(
            globalPosition: event.position,
            localPosition: event.localPosition,
            delta: delta,
            velocity: _velocityTracker.getVelocity(),
          ),
        );
      }
    } else if (event is PointerUpEvent) {
      if (_isPanning) {
        final velocity = _velocityTracker.getVelocity();
        _onPanEnd?.call(
          PanGestureData(
            globalPosition: event.position,
            localPosition: event.localPosition,
            delta: Offset.zero,
            velocity: velocity,
          ),
        );
      }
      _isPanning = false;
      _lastPosition = null;
    } else if (event is PointerCancelEvent) {
      if (_isPanning) {
        _onPanCancel?.call();
      }
      _isPanning = false;
      _lastPosition = null;
    }
  }
}
