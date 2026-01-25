// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';


class LayoutStateData {
  const LayoutStateData({
    required this.elementId,
    required this.bounds,
    this.label,
  });

  final String elementId;
  final Rect bounds;
  final String? label;
}
