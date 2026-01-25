// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that implements the flow layout algorithm.
class Flow extends MultiChildRenderObjectWidget {
  const Flow({
    super.key,
    required this.delegate,
    super.children,
    this.clipBehavior = Clip.hardEdge,
  });

  final FlowDelegate delegate;
  final Clip clipBehavior;

  @override
  RenderFlow createRenderObject(BuildContext context) {
    return RenderFlow(delegate: delegate, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlow renderObject) {
    renderObject
      ..delegate = delegate
      ..clipBehavior = clipBehavior;
  }
}
