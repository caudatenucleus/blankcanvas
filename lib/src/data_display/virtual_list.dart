// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'virtual_list_state.dart';


/// viewport culling.
class VirtualList<T> extends StatefulWidget {
  const VirtualList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.padding,
    this.separatorBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;
  final Axis scrollDirection;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  State<VirtualList<T>> createState() => VirtualListState<T>();
}
