// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A draggable overlay panel (absolute positioning).
class FloatingPanel extends SingleChildRenderObjectWidget {
  const FloatingPanel({
    super.key,
    required super.child,
    required this.offset,
    required this.size,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final Offset offset;
  final Size size;
  final ValueChanged<Offset>? onDragUpdate;
  final ValueChanged<Offset>? onDragEnd;

  @override
  RenderFloatingPanel createRenderObject(BuildContext context) {
    return RenderFloatingPanel(
      offset: offset,
      panelSize: size,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFloatingPanel renderObject,
  ) {
    renderObject
      ..offset = offset
      ..panelSize = size
      ..onDragUpdate = onDragUpdate
      ..onDragEnd = onDragEnd;
  }
}

class RenderFloatingPanel extends RenderProxyBox {
  RenderFloatingPanel({
    RenderBox? child,
    Offset offset = Offset.zero,
    Size panelSize = Size.zero,
    ValueChanged<Offset>? onDragUpdate,
    ValueChanged<Offset>? onDragEnd,
  }) : _offset = offset,
       _panelSize = panelSize,
       _onDragUpdate = onDragUpdate,
       _onDragEnd = onDragEnd,
       super(child) {
    _drag = PanGestureRecognizer()
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  Offset _offset;
  set offset(Offset val) {
    if (_offset != val) {
      _offset = val;
      markNeedsLayout();
    }
  }

  Size _panelSize;
  set panelSize(Size val) {
    if (_panelSize != val) {
      _panelSize = val;
      markNeedsLayout();
    }
  }

  ValueChanged<Offset>? _onDragUpdate;
  set onDragUpdate(ValueChanged<Offset>? val) => _onDragUpdate = val;

  ValueChanged<Offset>? _onDragEnd;
  set onDragEnd(ValueChanged<Offset>? val) => _onDragEnd = val;

  late PanGestureRecognizer _drag;

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_onDragUpdate != null) {
      _onDragUpdate!(details.delta);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_onDragEnd != null) {
      _onDragEnd!(_offset);
    }
  }

  @override
  void performLayout() {
    BoxConstraints innerConstraints = BoxConstraints.tight(_panelSize);
    child?.layout(innerConstraints, parentUsesSize: true);
    size = _panelSize;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }
}
