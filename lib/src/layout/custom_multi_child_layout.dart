// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that positions its children according to a delegate.
class CustomMultiChildLayout extends MultiChildRenderObjectWidget {
  const CustomMultiChildLayout({
    super.key,
    required this.delegate,
    super.children,
  });

  final MultiChildLayoutDelegate delegate;

  @override
  RenderCustomMultiChildLayoutBox createRenderObject(BuildContext context) {
    return RenderCustomMultiChildLayoutBox(delegate: delegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomMultiChildLayoutBox renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}
