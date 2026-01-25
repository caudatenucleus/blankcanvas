// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// State restoration channel wrapper
class RestorationChannelPrimitive {
  static const MethodChannel restoration = SystemChannels.restoration;

  static void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    restoration.setMethodCallHandler(handler);
  }
}
