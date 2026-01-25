// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Clipboard wrapper
class ClipboardPrimitive {
  static Future<void> setData(ClipboardData data) => Clipboard.setData(data);
  static Future<ClipboardData?> getData(String format) =>
      Clipboard.getData(format);
  static Future<bool> hasStrings() => Clipboard.hasStrings();

  // Convenience methods
  static Future<void> setText(String text) =>
      Clipboard.setData(ClipboardData(text: text));
  static Future<String?> getText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
