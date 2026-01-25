// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that delegates the layout of its single child to a [SingleChildLayoutDelegate].
class CustomSingleChildLayout extends SingleChildRenderObjectWidget {
  const CustomSingleChildLayout({
    super.key,
    required this.delegate,
    super.child,
  });

  final SingleChildLayoutDelegate delegate;

  @override
  RenderCustomSingleChildLayoutBox createRenderObject(BuildContext context) {
    return RenderCustomSingleChildLayoutBox(delegate: delegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomSingleChildLayoutBox renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}
