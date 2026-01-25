// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderPointerListener - Raw event propagation engine
// =============================================================================

class PointerListenerPrimitive extends SingleChildRenderObjectWidget {
  const PointerListenerPrimitive({
    super.key,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerCancel,
    super.child,
  });

  final void Function(PointerDownEvent)? onPointerDown;
  final void Function(PointerMoveEvent)? onPointerMove;
  final void Function(PointerUpEvent)? onPointerUp;
  final void Function(PointerCancelEvent)? onPointerCancel;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPointerListenerPrimitive(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      onPointerCancel: onPointerCancel,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPointerListenerPrimitive renderObject,
  ) {
    renderObject
      ..onPointerDown = onPointerDown
      ..onPointerMove = onPointerMove
      ..onPointerUp = onPointerUp
      ..onPointerCancel = onPointerCancel;
  }
}

class RenderPointerListenerPrimitive extends RenderProxyBoxWithHitTestBehavior {
  RenderPointerListenerPrimitive({
    void Function(PointerDownEvent)? onPointerDown,
    void Function(PointerMoveEvent)? onPointerMove,
    void Function(PointerUpEvent)? onPointerUp,
    void Function(PointerCancelEvent)? onPointerCancel,
    super.child,
  }) : _onPointerDown = onPointerDown,
       _onPointerMove = onPointerMove,
       _onPointerUp = onPointerUp,
       _onPointerCancel = onPointerCancel,
       super(behavior: HitTestBehavior.deferToChild);

  void Function(PointerDownEvent)? _onPointerDown;
  set onPointerDown(void Function(PointerDownEvent)? value) =>
      _onPointerDown = value;

  void Function(PointerMoveEvent)? _onPointerMove;
  set onPointerMove(void Function(PointerMoveEvent)? value) =>
      _onPointerMove = value;

  void Function(PointerUpEvent)? _onPointerUp;
  set onPointerUp(void Function(PointerUpEvent)? value) => _onPointerUp = value;

  void Function(PointerCancelEvent)? _onPointerCancel;
  set onPointerCancel(void Function(PointerCancelEvent)? value) =>
      _onPointerCancel = value;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _onPointerDown?.call(event);
    } else if (event is PointerMoveEvent) {
      _onPointerMove?.call(event);
    } else if (event is PointerUpEvent) {
      _onPointerUp?.call(event);
    } else if (event is PointerCancelEvent) {
      _onPointerCancel?.call(event);
    }
  }
}
