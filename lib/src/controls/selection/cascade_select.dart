// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'cascade_option.dart';
import 'cascade_select_element.dart';
import 'render_cascade_select.dart';


class CascadeSelect<T> extends LeafRenderObjectWidget {
  const CascadeSelect({
    super.key,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Select...',
    this.selectedPath = const [],
    this.tag,
  });

  final List<CascadeOption<T>> options;
  final void Function(List<T> path) onChanged;
  final String placeholder;
  final List<T> selectedPath;
  final String? tag;

  @override
  CascadeSelectElement<T> createElement() => CascadeSelectElement<T>(this);

  @override
  RenderCascadeSelect<T> createRenderObject(BuildContext context) {
    return RenderCascadeSelect<T>(
      placeholder: placeholder,
      selectedPath: selectedPath,
      options: options,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCascadeSelect<T> renderObject,
  ) {
    renderObject
      ..placeholder = placeholder
      ..selectedPath = selectedPath
      ..options = options;
  }
}
