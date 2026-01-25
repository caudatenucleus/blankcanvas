// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that positions its child according to the child's baseline.
class Baseline extends SingleChildRenderObjectWidget {
  const Baseline({
    super.key,
    required this.baseline,
    required this.baselineType,
    super.child,
  });

  final double baseline;
  final TextBaseline baselineType;

  @override
  RenderBaseline createRenderObject(BuildContext context) {
    return RenderBaseline(baseline: baseline, baselineType: baselineType);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBaseline renderObject) {
    renderObject
      ..baseline = baseline
      ..baselineType = baselineType;
  }
}
