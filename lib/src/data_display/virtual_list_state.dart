// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'virtual_list.dart';
import 'virtual_list_layout.dart';


class VirtualListState<T> extends State<VirtualList<T>> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.separatorBuilder != null) {
      for (int i = 0; i < widget.items.length; i++) {
        children.add(widget.itemBuilder(context, widget.items[i], i));
        if (i < widget.items.length - 1) {
          children.add(widget.separatorBuilder!(context, i));
        }
      }
    } else {
      children = List.generate(
        widget.items.length,
        (index) => widget.itemBuilder(context, widget.items[index], index),
      );
    }

    return VirtualListLayout(
      scrollDirection: widget.scrollDirection,
      padding: widget.padding ?? EdgeInsets.zero,
      itemExtent: widget.itemExtent,
      controller: widget.controller,
      children: children,
    );
  }
}
