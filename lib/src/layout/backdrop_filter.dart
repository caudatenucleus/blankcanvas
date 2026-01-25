// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;


/// A widget that applies a filter to the existing painted content.
class BackdropFilter extends SingleChildRenderObjectWidget {
  const BackdropFilter({
    super.key,
    required this.filter,
    this.blendMode =
        BlendMode.srcOver, // Default varies, usually srcOver or srcInOut
    super.child,
  });

  final ui.ImageFilter filter;
  final BlendMode blendMode;

  @override
  RenderBackdropFilter createRenderObject(BuildContext context) {
    return RenderBackdropFilter(filter: filter, blendMode: blendMode);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBackdropFilter renderObject,
  ) {
    renderObject
      ..filter = filter
      ..blendMode = blendMode;
  }
}

/// A widget that lays the child out as if it was in the tree, but without painting anything,