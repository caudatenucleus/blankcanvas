// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A window manager overlay primitive using lowest-level RenderObject APIs.
class WindowOverlay extends SingleChildRenderObjectWidget {
  const WindowOverlay({super.key, required super.child});

  @override
  RenderWindowOverlay createRenderObject(BuildContext context) {
    return RenderWindowOverlay();
  }
}

class RenderWindowOverlay extends RenderProxyBox {
  // Logic for managing overlay entries and stacking order
}
