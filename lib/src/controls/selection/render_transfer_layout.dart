// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'transfer_layout_parent_data.dart';

class RenderTransferLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TransferLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TransferLayoutParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TransferLayoutParentData) {
      child.parentData = TransferLayoutParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? source = firstChild;
    RenderBox? controls = source != null ? childAfter(source) : null;
    RenderBox? target = controls != null ? childAfter(controls) : null;

    // Controls width fixed approx 48
    double controlsWidth = 0;
    if (controls != null) {
      controls.layout(
        BoxConstraints.loose(Size(64, constraints.maxHeight)),
        parentUsesSize: true,
      );
      controlsWidth = controls.size.width;
    }

    double available = constraints.maxWidth - controlsWidth;
    double listWidth = available / 2;

    if (source != null) {
      source.layout(
        BoxConstraints(
          minWidth: listWidth,
          maxWidth: listWidth,
          minHeight: constraints.maxHeight,
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true,
      );
      final pd = source.parentData as TransferLayoutParentData;
      pd.offset = Offset(0, 0);
    }

    if (controls != null) {
      final pd = controls.parentData as TransferLayoutParentData;
      pd.offset = Offset(
        listWidth,
        (constraints.maxHeight - controls.size.height) / 2,
      );
    }

    if (target != null) {
      target.layout(
        BoxConstraints(
          minWidth: listWidth,
          maxWidth: listWidth,
          minHeight: constraints.maxHeight,
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true,
      );
      final pd = target.parentData as TransferLayoutParentData;
      pd.offset = Offset(listWidth + controlsWidth, 0);
    }

    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxHeight),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
