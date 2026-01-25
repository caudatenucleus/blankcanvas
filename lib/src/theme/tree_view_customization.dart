// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';
import 'tree_item_customization.dart';


/// Customization for TreeView.
class TreeViewCustomization extends ControlCustomization<TreeControlStatus> {
  const TreeViewCustomization({
    required super.decoration,
    required super.textStyle,
    required this.itemCustomization,
  });

  final TreeItemCustomization itemCustomization;

  factory TreeViewCustomization.simple({
    TreeItemCustomization? itemCustomization,
  }) {
    return TreeViewCustomization(
      itemCustomization: itemCustomization ?? TreeItemCustomization.simple(),
      decoration: (_) => const BoxDecoration(),
      textStyle: (_) => const TextStyle(),
    );
  }
}
