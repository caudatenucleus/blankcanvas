// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A box with a specified size.
class SizedBox extends SingleChildRenderObjectWidget {
  const SizedBox({super.key, this.width, this.height, super.child});

  const SizedBox.shrink({super.key}) : width = 0.0, height = 0.0;
  const SizedBox.expand({super.key, super.child})
    : width = double.infinity,
      height = double.infinity;

  final double? width;
  final double? height;

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(additionalConstraints: _additionalConstraints);
  }

  BoxConstraints get _additionalConstraints {
    return BoxConstraints.tightFor(width: width, height: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedBox renderObject,
  ) {
    renderObject.additionalConstraints = _additionalConstraints;
  }
}

/// A widget that imposes different constraints on its child than it gets