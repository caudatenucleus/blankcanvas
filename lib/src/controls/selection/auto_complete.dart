// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'auto_complete_element.dart';
import 'render_auto_complete.dart';


/// A text field with autocomplete suggestions.
class AutoComplete<T> extends LeafRenderObjectWidget {
  const AutoComplete({
    super.key,
    required this.suggestions,
    required this.onSelected,
    required this.itemBuilder,
    this.controller,
    this.placeholder,
    this.filter,
    this.debounceMs = 300,
    this.maxSuggestions = 5,
    this.tag,
  });

  final List<T> suggestions;
  final void Function(T item) onSelected;
  final Widget Function(T item, bool isHighlighted) itemBuilder;
  final TextEditingController? controller;
  final String? placeholder;
  final bool Function(T item, String query)? filter;
  final int debounceMs;
  final int maxSuggestions;
  final String? tag;

  @override
  AutoCompleteElement<T> createElement() => AutoCompleteElement<T>(this);

  @override
  RenderAutoComplete createRenderObject(BuildContext context) {
    return RenderAutoComplete(
      controller: controller,
      placeholder: placeholder,
      tag: tag,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAutoComplete renderObject,
  ) {
    renderObject
      ..controller = controller
      ..placeholder = placeholder
      ..tag = tag;
  }
}
