// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// A preview pane for CAD/PDF/Image/Doc files, using lowest-level RenderObject APIs.
class FilePreview extends LeafRenderObjectWidget {
  const FilePreview({
    super.key,
    required this.filePath,
    this.previewType = 'image',
  });

  final String filePath;
  final String previewType;

  @override
  RenderFilePreview createRenderObject(BuildContext context) {
    return RenderFilePreview(filePath: filePath, previewType: previewType);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFilePreview renderObject,
  ) {
    renderObject
      ..filePath = filePath
      ..previewType = previewType;
  }
}

class RenderFilePreview extends RenderBox {
  RenderFilePreview({required String filePath, required String previewType})
    : _filePath = filePath,
      _previewType = previewType;

  String _filePath;
  set filePath(String value) {
    if (_filePath == value) return;
    _filePath = value;
    markNeedsPaint();
  }

  String _previewType;
  set previewType(String value) {
    if (_previewType == value) return;
    _previewType = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(300, 400));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFF252525));

    // Draw preview based on type (Placeholder)
    canvas.drawRect(
      (offset & size).deflate(20),
      Paint()..color = const Color(0xFF404040),
    );
  }
}
