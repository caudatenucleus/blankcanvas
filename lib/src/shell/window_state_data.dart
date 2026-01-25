// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';


/// Data model for window state
class WindowStateData {
  const WindowStateData({
    required this.id,
    required this.title,
    required this.bounds,
    this.isActive = false,
    this.isMinimized = false,
  });

  final String id;
  final String title;
  final Rect bounds;
  final bool isActive;
  final bool isMinimized;
}
