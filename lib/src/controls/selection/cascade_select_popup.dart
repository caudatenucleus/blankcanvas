// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'cascade_option.dart';
import 'render_cascade_select_popup.dart';


class CascadeSelectPopup<T> extends LeafRenderObjectWidget {
  const CascadeSelectPopup({
    super.key,
    required this.columns,
    required this.selectedPath,
    required this.onSelect,
  });

  final List<List<CascadeOption<T>>> columns;
  final List<T> selectedPath;
  final void Function(int col, CascadeOption<T> option) onSelect;

  @override
  RenderCascadeSelectPopup<T> createRenderObject(BuildContext context) {
    return RenderCascadeSelectPopup<T>(
      columns: columns,
      selectedPath: selectedPath,
      onSelect: onSelect,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCascadeSelectPopup<T> renderObject,
  ) {
    renderObject
      ..columns = columns
      ..selectedPath = selectedPath
      ..onSelect = onSelect;
  }
}
