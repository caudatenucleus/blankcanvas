// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// Logic for detaching tabs (tear-off) using lowest-level RenderObject APIs.
class TearOffTab extends SingleChildRenderObjectWidget {
  const TearOffTab({super.key, required super.child, this.onTearOff});

  final VoidCallback? onTearOff;

  @override
  RenderTearOffTab createRenderObject(BuildContext context) {
    return RenderTearOffTab(onTearOff: onTearOff);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTearOffTab renderObject) {
    renderObject.onTearOff = onTearOff;
  }
}

class RenderTearOffTab extends RenderProxyBox {
  RenderTearOffTab({VoidCallback? onTearOff}) : _onTearOff = onTearOff {
    _longPress = LongPressGestureRecognizer()..onLongPress = _handleLongPress;
  }

  VoidCallback? _onTearOff;
  set onTearOff(VoidCallback? value) => _onTearOff = value;

  late LongPressGestureRecognizer _longPress;

  void _handleLongPress() {
    _onTearOff?.call();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _longPress.addPointer(event);
    }
  }
}
