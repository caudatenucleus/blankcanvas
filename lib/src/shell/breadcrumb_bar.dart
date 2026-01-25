// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A breadcrumb bar for file system paths, using lowest-level RenderObject APIs.
class BreadcrumbBar extends MultiChildRenderObjectWidget {
  BreadcrumbBar({super.key, required this.path, this.onSegmentTap})
    : super(children: const []);

  final String path;
  final void Function(String)? onSegmentTap;

  @override
  RenderBreadcrumbBar createRenderObject(BuildContext context) {
    return RenderBreadcrumbBar(path: path);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBreadcrumbBar renderObject,
  ) {
    renderObject.path = path;
  }
}

class BreadcrumbBarParentData extends ContainerBoxParentData<RenderBox> {}

class RenderBreadcrumbBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BreadcrumbBarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BreadcrumbBarParentData> {
  RenderBreadcrumbBar({required String path}) : _path = path;

  String _path;
  set path(String value) {
    if (_path == value) return;
    _path = value;
    markNeedsLayout();
  }

  // void Function(String)? _onSegmentTap;
  // set onSegmentTap(void Function(String)? value) => _onSegmentTap = value;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BreadcrumbBarParentData) {
      child.parentData = BreadcrumbBarParentData();
    }
  }

  @override
  void performLayout() {
    final double width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 300.0;
    size = constraints.constrain(Size(width, 32));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFF1E1E1E));

    // Split path and paint segments
    final segments = _path.split('/').where((s) => s.isNotEmpty).toList();
    double x = offset.dx + 8;
    for (final _ in segments) {
      // Paint segment text (Placeholder)
      canvas.drawRect(
        Rect.fromLTWH(x, offset.dy + 4, 40, 24),
        Paint()..color = const Color(0xFF333333),
      );
      x += 50;
    }
  }
}
