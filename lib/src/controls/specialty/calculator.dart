// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_calculator.dart';


/// A basic calculator widget.
class Calculator extends LeafRenderObjectWidget {
  const Calculator({super.key, this.onResult, this.tag});

  final void Function(double result)? onResult;
  final String? tag;

  @override
  RenderCalculator createRenderObject(BuildContext context) {
    return RenderCalculator(onResult: onResult);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCalculator renderObject) {
    renderObject.onResult = onResult;
  }
}
