// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_segment_item.dart';

class SegmentItem<T> extends MultiChildRenderObjectWidget {
  SegmentItem({
    super.key,
    required this.value,
    this.label,
    this.icon,
    required this.isSelected,
    this.onTap,
  }) : super(children: _buildChildren(icon, label));

  static List<Widget> _buildChildren(Widget? icon, Widget? label) {
    final children = <Widget>[];
    if (icon != null) children.add(_SegmentItemSlot(slot: 0, child: icon));
    if (label != null) children.add(_SegmentItemSlot(slot: 1, child: label));
    return children;
  }

  final T value;
  final Widget? label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  RenderSegmentItem createRenderObject(BuildContext context) {
    return RenderSegmentItem(isSelected: isSelected, onTap: onTap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSegmentItem renderObject,
  ) {
    renderObject
      ..isSelected = isSelected
      ..onTap = onTap;
  }
}

class _SegmentItemSlot extends ParentDataWidget<SegmentItemParentData> {
  const _SegmentItemSlot({required this.slot, required super.child});

  final int slot;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is SegmentItemParentData);
    final pd = renderObject.parentData as SegmentItemParentData;
    if (pd.slot != slot) {
      pd.slot = slot;
      final parent = renderObject.parent;
      if (parent is RenderObject) parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SegmentItem;
}
