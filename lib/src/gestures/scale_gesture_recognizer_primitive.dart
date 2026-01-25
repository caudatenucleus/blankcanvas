// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// Scale Gesture Recognizer Primitive - Pinch/Spread transformation
// =============================================================================

class ScaleGestureData {
  const ScaleGestureData({
    required this.focalPoint,
    required this.localFocalPoint,
    required this.scale,
    required this.rotation,
    required this.pointerCount,
  });

  final Offset focalPoint;
  final Offset localFocalPoint;
  final double scale;
  final double rotation;
  final int pointerCount;
}

class ScaleGestureRecognizerPrimitive extends LeafRenderObjectWidget {
  const ScaleGestureRecognizerPrimitive({
    super.key,
    this.onScaleStart,
    required this.onScaleUpdate,
    this.onScaleEnd,
    this.size = const Size(100, 100),
  });

  final void Function(ScaleGestureData)? onScaleStart;
  final void Function(ScaleGestureData) onScaleUpdate;
  final void Function(ScaleGestureData)? onScaleEnd;
  final Size size;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScaleGestureRecognizer(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      preferredSize: size,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderScaleGestureRecognizer renderObject,
  ) {
    renderObject
      ..onScaleStart = onScaleStart
      ..onScaleUpdate = onScaleUpdate
      ..onScaleEnd = onScaleEnd
      ..preferredSize = size;
  }
}

class RenderScaleGestureRecognizer extends RenderBox {
  RenderScaleGestureRecognizer({
    void Function(ScaleGestureData)? onScaleStart,
    required void Function(ScaleGestureData) onScaleUpdate,
    void Function(ScaleGestureData)? onScaleEnd,
    required Size preferredSize,
  }) : _onScaleStart = onScaleStart,
       _onScaleUpdate = onScaleUpdate,
       _onScaleEnd = onScaleEnd,
       _preferredSize = preferredSize;

  void Function(ScaleGestureData)? _onScaleStart;
  void Function(ScaleGestureData)? get onScaleStart => _onScaleStart;
  set onScaleStart(void Function(ScaleGestureData)? value) =>
      _onScaleStart = value;

  void Function(ScaleGestureData) _onScaleUpdate;
  void Function(ScaleGestureData) get onScaleUpdate => _onScaleUpdate;
  set onScaleUpdate(void Function(ScaleGestureData) value) =>
      _onScaleUpdate = value;

  void Function(ScaleGestureData)? _onScaleEnd;
  void Function(ScaleGestureData)? get onScaleEnd => _onScaleEnd;
  set onScaleEnd(void Function(ScaleGestureData)? value) => _onScaleEnd = value;

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    if (_preferredSize != value) {
      _preferredSize = value;
      markNeedsLayout();
    }
  }

  final Map<int, Offset> _pointers = {};
  double _initialSpan = 0;
  Offset _initialFocalPoint = Offset.zero;
  bool _isScaling = false;

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
      _pointers[event.pointer] = event.localPosition;
      if (_pointers.length == 2) {
        _startScaling();
      }
    } else if (event is PointerMoveEvent) {
      _pointers[event.pointer] = event.localPosition;
      if (_isScaling && _pointers.length >= 2) {
        _updateScaling(event.position, event.localPosition);
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointers.remove(event.pointer);
      if (_isScaling && _pointers.length < 2) {
        _endScaling(event.position, event.localPosition);
      }
    }
  }

  void _startScaling() {
    final positions = _pointers.values.toList();
    _initialFocalPoint = (positions[0] + positions[1]) / 2;
    _initialSpan = (positions[0] - positions[1]).distance;
    _isScaling = true;

    _onScaleStart?.call(
      ScaleGestureData(
        focalPoint: _initialFocalPoint,
        localFocalPoint: _initialFocalPoint,
        scale: 1.0,
        rotation: 0.0,
        pointerCount: _pointers.length,
      ),
    );
  }

  void _updateScaling(Offset globalPosition, Offset localPosition) {
    final positions = _pointers.values.toList();
    final focalPoint = (positions[0] + positions[1]) / 2;
    final span = (positions[0] - positions[1]).distance;
    final scale = _initialSpan > 0 ? span / _initialSpan : 1.0;

    _onScaleUpdate(
      ScaleGestureData(
        focalPoint: globalPosition,
        localFocalPoint: focalPoint,
        scale: scale,
        rotation: 0.0, // TODO: Calculate rotation
        pointerCount: _pointers.length,
      ),
    );
  }

  void _endScaling(Offset globalPosition, Offset localPosition) {
    _isScaling = false;

    _onScaleEnd?.call(
      ScaleGestureData(
        focalPoint: globalPosition,
        localFocalPoint: localPosition,
        scale: 1.0,
        rotation: 0.0,
        pointerCount: _pointers.length,
      ),
    );
  }
}
