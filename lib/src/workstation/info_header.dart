// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/theme/workstation_theme.dart';

/// Strict-height header info layout using lowest-level RenderObject APIs.
class InfoHeader extends LeafRenderObjectWidget {
  const InfoHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  RenderInfoHeader createRenderObject(BuildContext context) {
    return RenderInfoHeader(
      title: title,
      subtitle: subtitle,
      theme: WorkstationTheme.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderInfoHeader renderObject) {
    renderObject
      ..title = title
      ..subtitle = subtitle
      ..theme = WorkstationTheme.of(context);
  }
}

class RenderInfoHeader extends RenderBox {
  RenderInfoHeader({
    required String title,
    String? subtitle,
    required WorkstationThemeData theme,
  }) : _title = title,
       _subtitle = subtitle,
       _theme = theme;

  String _title;
  set title(String value) {
    if (_title == value) return;
    _title = value;
    markNeedsPaint();
  }

  String? _subtitle;
  set subtitle(String? value) {
    if (_subtitle == value) return;
    _subtitle = value;
    markNeedsPaint();
  }

  WorkstationThemeData _theme;
  set theme(WorkstationThemeData value) {
    if (_theme == value) return;
    _theme = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(double.infinity, 48));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = _theme.toolBarBackground);

    // Paint title and subtitle (Placeholder using TextPainter)
  }
}
