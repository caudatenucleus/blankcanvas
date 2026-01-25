// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that attempts to size the child to a specific aspect ratio.
class AspectRatio extends SingleChildRenderObjectWidget {
  const AspectRatio({super.key, required this.aspectRatio, super.child});

  final double aspectRatio;

  @override
  RenderAspectRatio createRenderObject(BuildContext context) {
    return RenderAspectRatio(aspectRatio: aspectRatio);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAspectRatio renderObject,
  ) {
    renderObject.aspectRatio = aspectRatio;
  }
}
