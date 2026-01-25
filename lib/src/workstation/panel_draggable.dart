// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A drag handle primitive using lowest-level RenderObject APIs.
class PanelDraggable extends SingleChildRenderObjectWidget {
  const PanelDraggable({super.key, required super.child, this.onDrag});

  final ValueChanged<Offset>? onDrag;

  @override
  RenderPanelDraggable createRenderObject(BuildContext context) {
    return RenderPanelDraggable(onDrag: onDrag);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPanelDraggable renderObject,
  ) {
    renderObject.onDrag = onDrag;
  }
}

class RenderPanelDraggable extends RenderProxyBox {
  RenderPanelDraggable({ValueChanged<Offset>? onDrag}) : _onDrag = onDrag {
    _pan = PanGestureRecognizer()..onUpdate = _handlePanUpdate;
  }

  ValueChanged<Offset>? _onDrag;
  set onDrag(ValueChanged<Offset>? value) => _onDrag = value;

  late PanGestureRecognizer _pan;

  void _handlePanUpdate(DragUpdateDetails details) {
    _onDrag?.call(details.delta);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pan.addPointer(event);
    }
  }
}
