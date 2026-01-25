// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// Force Press Gesture Recognizer Primitive
// =============================================================================

class ForcePressGestureData {
  const ForcePressGestureData({
    required this.globalPosition,
    required this.localPosition,
    required this.pressure,
  });

  final Offset globalPosition;
  final Offset localPosition;
  final double pressure;
}

class ForcePressGestureRecognizerPrimitive extends LeafRenderObjectWidget {
  const ForcePressGestureRecognizerPrimitive({
    super.key,
    required this.onForcePress,
    this.onForcePressStart,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.startPressure = 0.4,
    this.peakPressure = 0.85,
    this.size = const Size(100, 100),
  });

  final VoidCallback onForcePress;
  final void Function(ForcePressGestureData)? onForcePressStart;
  final void Function(ForcePressGestureData)? onForcePressUpdate;
  final VoidCallback? onForcePressEnd;
  final double startPressure;
  final double peakPressure;
  final Size size;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderForcePressGestureRecognizer(
      onForcePress: onForcePress,
      onForcePressStart: onForcePressStart,
      onForcePressUpdate: onForcePressUpdate,
      onForcePressEnd: onForcePressEnd,
      startPressure: startPressure,
      peakPressure: peakPressure,
      preferredSize: size,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderForcePressGestureRecognizer renderObject,
  ) {
    renderObject
      ..onForcePress = onForcePress
      ..onForcePressStart = onForcePressStart
      ..onForcePressUpdate = onForcePressUpdate
      ..onForcePressEnd = onForcePressEnd
      ..startPressure = startPressure
      ..peakPressure = peakPressure
      ..preferredSize = size;
  }
}

class RenderForcePressGestureRecognizer extends RenderBox {
  RenderForcePressGestureRecognizer({
    required VoidCallback onForcePress,
    void Function(ForcePressGestureData)? onForcePressStart,
    void Function(ForcePressGestureData)? onForcePressUpdate,
    VoidCallback? onForcePressEnd,
    required double startPressure,
    required double peakPressure,
    required Size preferredSize,
  }) : _onForcePress = onForcePress,
       _onForcePressStart = onForcePressStart,
       _onForcePressUpdate = onForcePressUpdate,
       _onForcePressEnd = onForcePressEnd,
       _startPressure = startPressure,
       _peakPressure = peakPressure,
       _preferredSize = preferredSize;

  VoidCallback _onForcePress;
  VoidCallback get onForcePress => _onForcePress;
  set onForcePress(VoidCallback value) => _onForcePress = value;

  void Function(ForcePressGestureData)? _onForcePressStart;
  void Function(ForcePressGestureData)? get onForcePressStart =>
      _onForcePressStart;
  set onForcePressStart(void Function(ForcePressGestureData)? value) =>
      _onForcePressStart = value;

  void Function(ForcePressGestureData)? _onForcePressUpdate;
  void Function(ForcePressGestureData)? get onForcePressUpdate =>
      _onForcePressUpdate;
  set onForcePressUpdate(void Function(ForcePressGestureData)? value) =>
      _onForcePressUpdate = value;

  VoidCallback? _onForcePressEnd;
  VoidCallback? get onForcePressEnd => _onForcePressEnd;
  set onForcePressEnd(VoidCallback? value) => _onForcePressEnd = value;

  double _startPressure;
  double get startPressure => _startPressure;
  set startPressure(double value) => _startPressure = value;

  double _peakPressure;
  double get peakPressure => _peakPressure;
  set peakPressure(double value) => _peakPressure = value;

  Size _preferredSize;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    if (_preferredSize != value) {
      _preferredSize = value;
      markNeedsLayout();
    }
  }

  bool _forceStarted = false;
  bool _peakReached = false;

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
    if (event is PointerMoveEvent || event is PointerDownEvent) {
      final pressure = event.pressure;

      if (!_forceStarted && pressure >= _startPressure) {
        _forceStarted = true;
        _onForcePressStart?.call(
          ForcePressGestureData(
            globalPosition: event.position,
            localPosition: event.localPosition,
            pressure: pressure,
          ),
        );
      }

      if (_forceStarted) {
        _onForcePressUpdate?.call(
          ForcePressGestureData(
            globalPosition: event.position,
            localPosition: event.localPosition,
            pressure: pressure,
          ),
        );

        if (!_peakReached && pressure >= _peakPressure) {
          _peakReached = true;
          _onForcePress();
        }
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (_forceStarted) {
        _onForcePressEnd?.call();
      }
      _forceStarted = false;
      _peakReached = false;
    }
  }
}
