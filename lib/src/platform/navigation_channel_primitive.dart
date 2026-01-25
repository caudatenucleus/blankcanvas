// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Navigation channel wrapper
class NavigationChannelPrimitive {
  static const MethodChannel navigation = SystemChannels.navigation;

  static void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    navigation.setMethodCallHandler(handler);
  }
}
