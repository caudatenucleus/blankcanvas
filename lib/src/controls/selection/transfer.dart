// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'transfer_state.dart';


class Transfer<T> extends StatefulWidget {
  const Transfer({
    super.key,
    required this.sourceItems,
    required this.targetItems,
    required this.onChanged,
    required this.itemBuilder,
    this.sourceTitle = 'Available',
    this.targetTitle = 'Selected',
    this.tag,
  });

  final List<T> sourceItems;
  final List<T> targetItems;
  final void Function(List<T> source, List<T> target) onChanged;
  final Widget Function(T item) itemBuilder;
  final String sourceTitle;
  final String targetTitle;
  final String? tag;

  @override
  State<Transfer<T>> createState() => TransferState<T>();
}
