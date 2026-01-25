// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// A bulk renamer widget for file system entities, using lowest-level RenderObject APIs.
class BatchRenamer extends LeafRenderObjectWidget {
  const BatchRenamer({
    super.key,
    required this.filePaths,
    required this.renamePattern,
  });

  final List<String> filePaths;
  final String renamePattern;

  @override
  RenderBatchRenamer createRenderObject(BuildContext context) {
    return RenderBatchRenamer(
      filePaths: filePaths,
      renamePattern: renamePattern,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBatchRenamer renderObject,
  ) {
    renderObject
      ..filePaths = filePaths
      ..renamePattern = renamePattern;
  }
}

class RenderBatchRenamer extends RenderBox {
  RenderBatchRenamer({
    required List<String> filePaths,
    required String renamePattern,
  }) : _filePaths = filePaths,
       _renamePattern = renamePattern;

  List<String> _filePaths;
  set filePaths(List<String> value) {
    if (_filePaths == value) return;
    _filePaths = value;
    markNeedsPaint();
  }

  String _renamePattern;
  set renamePattern(String value) {
    if (_renamePattern == value) return;
    _renamePattern = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(400, 300));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFF2D2D2D));

    // Draw list of renames (Placeholder)
    for (int i = 0; i < _filePaths.length && i < 10; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          offset.dx + 4,
          offset.dy + 4 + i * 20,
          size.width - 8,
          16,
        ),
        Paint()..color = const Color(0xFF3D3D3D),
      );
    }
  }
}
