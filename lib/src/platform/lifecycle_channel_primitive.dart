// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Lifecycle channel wrapper
class LifecycleChannelPrimitive {
  static const BasicMessageChannel<String?> lifecycle =
      SystemChannels.lifecycle;

  static void setMessageHandler(
    Future<String?> Function(String? message)? handler,
  ) {
    lifecycle.setMessageHandler(handler);
  }
}
