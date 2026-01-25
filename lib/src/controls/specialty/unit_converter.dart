// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_unit_converter.dart';


/// A unit converter widget.
class UnitConverter extends LeafRenderObjectWidget {
  const UnitConverter({
    super.key,
    this.category = 'length',
    this.onConvert,
    this.tag,
  });

  final String category;
  final void Function(double result, String fromUnit, String toUnit)? onConvert;
  final String? tag;

  @override
  RenderUnitConverter createRenderObject(BuildContext context) {
    return RenderUnitConverter(category: category, onConvert: onConvert);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderUnitConverter renderObject,
  ) {
    renderObject
      ..category = category
      ..onConvert = onConvert;
  }
}
