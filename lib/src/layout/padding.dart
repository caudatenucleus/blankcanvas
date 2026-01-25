import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// A widget that insets its child by the given padding.
class Padding extends SingleChildRenderObjectWidget {
  const Padding({super.key, required this.padding, super.child});

  final EdgeInsetsGeometry padding;

  @override
  RenderPadding createRenderObject(BuildContext context) {
    return RenderPadding(
      padding: padding,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPadding renderObject) {
    renderObject
      ..padding = padding
      ..textDirection = Directionality.maybeOf(context);
  }
}

/// A widget that aligns its child within itself and optionally sizes itself