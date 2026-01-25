// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/theme/customization.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

class RenderToggleIcon extends RenderBox {
  RenderToggleIcon({
    required bool isExpanded,
    required TreeItemCustomization customization,
  }) : _isExpanded = isExpanded,
       _customization = customization;

  bool _isExpanded;
  set isExpanded(bool value) {
    if (_isExpanded == value) return;
    _isExpanded = value;
    markNeedsPaint();
  }

  TreeItemCustomization _customization;
  set customization(TreeItemCustomization value) {
    _customization = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(16, 16));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final status = TreeItemControlStatus()..expanded = _isExpanded ? 1.0 : 0.0;
    final textStyle = _customization.textStyle(status);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _isExpanded ? "▼" : "▶",
        style: textStyle.copyWith(fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      context.canvas,
      offset +
          (size.center(Offset.zero) -
              Offset(textPainter.width / 2, textPainter.height / 2)),
    );
  }
}
