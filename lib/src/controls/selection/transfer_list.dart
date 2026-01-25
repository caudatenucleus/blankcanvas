// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_transfer_list.dart';

class TransferList<T> extends LeafRenderObjectWidget {
  const TransferList({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndices,
    required this.onSelectionChanged,
  });

  final String title;
  final List<T> items;
  final Set<int> selectedIndices;
  final ValueChanged<Set<int>> onSelectionChanged;

  @override
  RenderTransferList<T> createRenderObject(BuildContext context) {
    return RenderTransferList<T>(
      title: title,
      items: items,
      selectedIndices: selectedIndices,
      onSelectionChanged: onSelectionChanged,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTransferList<T> renderObject,
  ) {
    renderObject
      ..title = title
      ..items = items
      ..selectedIndices = selectedIndices
      ..onSelectionChanged = onSelectionChanged;
  }
}
