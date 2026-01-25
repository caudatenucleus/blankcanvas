// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Mouse cursor channel wrapper
class MouseCursorChannelPrimitive {
  static const MethodChannel mouseCursor = MethodChannel('flutter/mousecursor');

  static Future<void> activateSystemCursor({required String kind}) async {
    await mouseCursor.invokeMethod('activateSystemCursor', <String, dynamic>{
      'kind': kind,
    });
  }
}
