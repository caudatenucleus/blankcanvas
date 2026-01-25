// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A professional file tree widget using lowest-level RenderObject APIs.
class FileTree extends MultiChildRenderObjectWidget {
  FileTree({
    super.key,
    required this.rootNode,
    this.onNodeTap,
    this.itemHeight = 24.0,
  }) : super(children: const []);

  final FileNode rootNode;
  final void Function(FileNode)? onNodeTap;
  final double itemHeight;

  @override
  RenderFileTree createRenderObject(BuildContext context) {
    return RenderFileTree(rootNode: rootNode, itemHeight: itemHeight);
  }

  @override
  void updateRenderObject(BuildContext context, RenderFileTree renderObject) {
    renderObject
      ..rootNode = rootNode
      ..itemHeight = itemHeight;
  }
}

class FileNode {
  FileNode({
    required this.name,
    required this.path,
    this.isDirectory = false,
    this.children = const [],
    this.isExpanded = false,
  });

  final String name;
  final String path;
  final bool isDirectory;
  List<FileNode> children;
  bool isExpanded;
}

class FileTreeParentData extends ContainerBoxParentData<RenderBox> {}

class RenderFileTree extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FileTreeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FileTreeParentData> {
  RenderFileTree({required FileNode rootNode, required double itemHeight})
    : _rootNode = rootNode,
      _itemHeight = itemHeight;

  FileNode _rootNode;
  set rootNode(FileNode value) {
    if (_rootNode == value) return;
    _rootNode = value;
    markNeedsLayout();
  }

  // Placeholder for node selection logic
  // void Function(FileNode)? _onNodeTap;
  // set onNodeTap(void Function(FileNode)? value) => _onNodeTap = value;

  double _itemHeight;
  set itemHeight(double value) {
    if (_itemHeight == value) return;
    _itemHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FileTreeParentData) {
      child.parentData = FileTreeParentData();
    }
  }

  @override
  void performLayout() {
    final double width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 300.0;
    size = constraints.constrain(Size(width, _calculateTotalHeight(_rootNode)));
    // Real implementation would layout visible nodes only (viewport management)
  }

  double _calculateTotalHeight(FileNode node) {
    double h = _itemHeight;
    if (node.isExpanded) {
      for (final child in node.children) {
        h += _calculateTotalHeight(child);
      }
    }
    return h;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintNode(context, offset, _rootNode, 0);
  }

  void _paintNode(
    PaintingContext context,
    Offset offset,
    FileNode node,
    int depth,
  ) {
    final canvas = context.canvas;
    // final rowRect = offset & Size(size.width, _itemHeight);

    // Draw row background if hovered/selected (skipped for brevity)

    // Draw indent
    final double indent = depth * 16.0;

    // Draw icon & text (Placeholder)
    final iconColor = node.isDirectory
        ? const Color(0xFFFFA000)
        : const Color(0xFF90A4AE);
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + indent + 4, offset.dy + 4, 16, 16),
      Paint()..color = iconColor,
    );

    // Text would be painted here

    double yOffset = _itemHeight;
    if (node.isExpanded) {
      for (final child in node.children) {
        _paintNode(context, offset + Offset(0, yOffset), child, depth + 1);
        yOffset += _calculateTotalHeight(child);
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      // Logic to find node at position and call _onNodeTap
    }
  }
}
