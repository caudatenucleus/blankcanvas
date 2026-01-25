// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';


class DropdownItem<T> {
  const DropdownItem({required this.value, required this.label});
  final T value;
  final Widget label;
}
