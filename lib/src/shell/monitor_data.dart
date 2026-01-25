// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';


class MonitorData {
  const MonitorData({
    required this.index,
    required this.bounds,
    this.name,
    this.isPrimary = false,
  });

  final int index;
  final Rect bounds;
  final String? name;
  final bool isPrimary;
}
