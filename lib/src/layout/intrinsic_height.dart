// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that forces its child's height to be the child's intrinsic height.
class IntrinsicHeight extends SingleChildRenderObjectWidget {
  const IntrinsicHeight({super.key, super.child});

  @override
  RenderIntrinsicHeight createRenderObject(BuildContext context) {
    return RenderIntrinsicHeight();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIntrinsicHeight renderObject,
  ) {
    // No properties to update
  }
}
