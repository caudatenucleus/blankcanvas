// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.



/// Cascading select widget with hierarchical options.
class CascadeOption<T> {
  const CascadeOption({
    required this.value,
    required this.label,
    this.children = const [],
  });

  final T value;
  final String label;
  final List<CascadeOption<T>> children;

  bool get hasChildren => children.isNotEmpty;
}
