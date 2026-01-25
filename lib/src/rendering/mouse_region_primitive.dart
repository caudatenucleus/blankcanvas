// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

// =============================================================================
// RenderMouseRegion - Hover/Cursor-state engine
// =============================================================================

class MouseRegionPrimitive extends SingleChildRenderObjectWidget {
  const MouseRegionPrimitive({
    super.key,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.cursor = MouseCursor.defer,
    super.child,
  });

  final void Function(PointerEnterEvent)? onEnter;
  final void Function(PointerExitEvent)? onExit;
  final void Function(PointerHoverEvent)? onHover;
  final MouseCursor cursor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMouseRegionPrimitive(
      onEnter: onEnter,
      onExit: onExit,
      onHover: onHover,
      cursor: cursor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMouseRegionPrimitive renderObject,
  ) {
    renderObject
      ..onEnter = onEnter
      ..onExit = onExit
      ..onHover = onHover
      ..cursor = cursor;
  }
}

class RenderMouseRegionPrimitive extends RenderProxyBoxWithHitTestBehavior {
  RenderMouseRegionPrimitive({
    void Function(PointerEnterEvent)? onEnter,
    void Function(PointerExitEvent)? onExit,
    void Function(PointerHoverEvent)? onHover,
    MouseCursor cursor = MouseCursor.defer,
    super.child,
  }) : _onEnter = onEnter,
       _onExit = onExit,
       _onHover = onHover,
       _cursor = cursor,
       super(behavior: HitTestBehavior.opaque);

  void Function(PointerEnterEvent)? _onEnter;
  set onEnter(void Function(PointerEnterEvent)? value) => _onEnter = value;

  void Function(PointerExitEvent)? _onExit;
  set onExit(void Function(PointerExitEvent)? value) => _onExit = value;

  void Function(PointerHoverEvent)? _onHover;
  set onHover(void Function(PointerHoverEvent)? value) => _onHover = value;

  MouseCursor _cursor;
  MouseCursor get cursor => _cursor;
  set cursor(MouseCursor value) {
    if (_cursor != value) {
      _cursor = value;
      markNeedsPaint();
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerEnterEvent) {
      _onEnter?.call(event);
    } else if (event is PointerExitEvent) {
      _onExit?.call(event);
    } else if (event is PointerHoverEvent) {
      _onHover?.call(event);
    }
  }
}
