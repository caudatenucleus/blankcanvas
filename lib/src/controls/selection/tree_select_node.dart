// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.



class TreeSelectNode<T> {
  const TreeSelectNode({
    required this.value,
    required this.label,
    this.children = const [],
    this.isExpanded = false,
  });

  final T value;
  final String label;
  final List<TreeSelectNode<T>> children;
  final bool isExpanded;

  bool get hasChildren => children.isNotEmpty;

  TreeSelectNode<T> copyWith({bool? isExpanded}) => TreeSelectNode(
    value: value,
    label: label,
    children: children,
    isExpanded: isExpanded ?? this.isExpanded,
  );
}
