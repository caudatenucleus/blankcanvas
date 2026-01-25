// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Platform channel wrapper
class PlatformChannelPrimitive {
  static const MethodChannel platform = SystemChannels.platform;

  static Future<void> setSystemUIOverlayStyle(
    SystemUiOverlayStyle style,
  ) async {
    await platform
        .invokeMethod('SystemChrome.setSystemUIOverlayStyle', <String, dynamic>{
          'statusBarColor': style.statusBarColor?.value,
          'statusBarBrightness': style.statusBarBrightness?.name,
          'statusBarIconBrightness': style.statusBarIconBrightness?.name,
          'systemNavigationBarColor': style.systemNavigationBarColor?.value,
          'systemNavigationBarDividerColor':
              style.systemNavigationBarDividerColor?.value,
          'systemNavigationBarIconBrightness':
              style.systemNavigationBarIconBrightness?.name,
        });
  }
}
