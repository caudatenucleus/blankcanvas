// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// A utility for mounting virtual disks/ISOs, using lowest-level RenderObject APIs.
class VirtualDiskMounter extends LeafRenderObjectWidget {
  const VirtualDiskMounter({super.key, required this.sourcePath});

  final String sourcePath;

  @override
  RenderVirtualDiskMounter createRenderObject(BuildContext context) {
    return RenderVirtualDiskMounter(sourcePath: sourcePath);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderVirtualDiskMounter renderObject,
  ) {
    renderObject.sourcePath = sourcePath;
  }
}

class RenderVirtualDiskMounter extends RenderBox {
  RenderVirtualDiskMounter({required String sourcePath})
    : _sourcePath = sourcePath;

  String _sourcePath;
  set sourcePath(String value) {
    if (_sourcePath == value) return;
    _sourcePath = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(400, 150));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFF2D2D2D));
    // Implementation for mounter UI
  }
}
