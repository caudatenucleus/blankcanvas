// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'tree_select_node.dart';
import 'tree_select.dart';
import 'render_tree_select.dart';
import 'tree_select_popup.dart';


class TreeSelectElement<T> extends LeafRenderObjectElement {
  TreeSelectElement(TreeSelect<T> super.widget);

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<TreeSelectNode<T>> _localNodes = [];

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final render = renderObject as RenderTreeSelect<T>;
    render.layerLink = _layerLink;
    render.onTap = _toggle;
    _localNodes = (widget as TreeSelect<T>).nodes;
  }

  @override
  void update(TreeSelect<T> newWidget) {
    super.update(newWidget);
    // If external nodes change, we might reset?
    // Or try to preserve expansion?
    // For now, reset if reference changes.
    if ((widget as TreeSelect<T>).nodes != newWidget.nodes) {
      _localNodes = newWidget.nodes;
      // Or map expansion? simplified: reset.
    }

    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  void _toggle() {
    if (_overlayEntry != null) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final renderBox = renderObject as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: TreeSelectPopup<T>(
              nodes: _localNodes,
              selectedValues: (widget as TreeSelect<T>).selectedValues,
              selectedValue: (widget as TreeSelect<T>).selectedValue,
              multiSelect: (widget as TreeSelect<T>).multiSelect,
              onNodeTap: _handleNodeTap,
              onExpandTap: _handleExpandTap,
            ),
          ),
        );
      },
    );

    Overlay.of(this).insert(_overlayEntry!);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleNodeTap(TreeSelectNode<T> node) {
    final widget = this.widget as TreeSelect<T>;
    if (widget.multiSelect) {
      final newValues = List<T>.from(widget.selectedValues);
      if (newValues.contains(node.value)) {
        newValues.remove(node.value);
      } else {
        newValues.add(node.value);
      }
      widget.onMultiSelect?.call(newValues);
      _overlayEntry?.markNeedsBuild();
    } else {
      widget.onSelected(node.value);
      _close();
    }
  }

  void _handleExpandTap(TreeSelectNode<T> node) {
    // Toggle expansion in _localNodes
    final newVal = !node.isExpanded;
    _localNodes = _updateNodeExpansion(_localNodes, node.value, newVal);
    _overlayEntry?.markNeedsBuild();
  }

  List<TreeSelectNode<T>> _updateNodeExpansion(
    List<TreeSelectNode<T>> list,
    T val,
    bool expanded,
  ) {
    return list.map((n) {
      if (n.value == val) return n.copyWith(isExpanded: expanded);
      if (n.hasChildren) {
        return TreeSelectNode(
          value: n.value,
          label: n.label,
          children: _updateNodeExpansion(n.children, val, expanded),
          isExpanded: n.isExpanded,
        );
      }
      return n;
    }).toList();
  }

  @override
  void unmount() {
    _close();
    super.unmount();
  }
}
