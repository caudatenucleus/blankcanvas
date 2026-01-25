// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// A side-by-side file comparison diff view, using lowest-level RenderObject APIs.
class FileDiffView extends LeafRenderObjectWidget {
  const FileDiffView({
    super.key,
    required this.leftPath,
    required this.rightPath,
  });

  final String leftPath;
  final String rightPath;

  @override
  RenderFileDiffView createRenderObject(BuildContext context) {
    return RenderFileDiffView(leftPath: leftPath, rightPath: rightPath);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFileDiffView renderObject,
  ) {
    renderObject
      ..leftPath = leftPath
      ..rightPath = rightPath;
  }
}

class RenderFileDiffView extends RenderBox {
  RenderFileDiffView({required String leftPath, required String rightPath})
    : _leftPath = leftPath,
      _rightPath = rightPath;

  String _leftPath;
  set leftPath(String value) {
    if (_leftPath == value) return;
    _leftPath = value;
    markNeedsPaint();
  }

  String _rightPath;
  set rightPath(String value) {
    if (_rightPath == value) return;
    _rightPath = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(600, 400));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFF1E1E1E));

    final halfWidth = size.width / 2;
    // Left pane
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, halfWidth, size.height).deflate(8),
      Paint()..color = const Color(0xFF252525),
    );
    // Right pane
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + halfWidth,
        offset.dy,
        halfWidth,
        size.height,
      ).deflate(8),
      Paint()..color = const Color(0xFF252525),
    );
  }
}
