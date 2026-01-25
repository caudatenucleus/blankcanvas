// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Accessibility channel wrapper
class AccessibilityChannelPrimitive {
  static const BasicMessageChannel<Object?> accessibility =
      SystemChannels.accessibility;

  static void setMessageHandler(
    Future<Object?> Function(Object? message)? handler,
  ) {
    accessibility.setMessageHandler(handler);
  }
}
