// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_multi_select_chip.dart';

class MultiSelectChip extends LeafRenderObjectWidget {
  const MultiSelectChip({
    super.key,
    required this.label,
    required this.onRemove,
  });
  final String label;
  final VoidCallback onRemove;

  @override
  RenderMultiSelectChip createRenderObject(BuildContext context) {
    return RenderMultiSelectChip(label: label, onRemove: onRemove);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMultiSelectChip renderObject,
  ) {
    renderObject
      ..label = label
      ..onRemove = onRemove;
  }
}
