// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Text input channel wrapper
class TextInputChannelPrimitive {
  static const MethodChannel textInput = SystemChannels.textInput;

  static Future<void> hide() async {
    await textInput.invokeMethod('TextInput.hide');
  }

  static Future<void> show() async {
    await textInput.invokeMethod('TextInput.show');
  }

  static Future<void> clearClient() async {
    await textInput.invokeMethod('TextInput.clearClient');
  }
}
