// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// System sound wrapper
class SystemSoundPrimitive {
  static Future<void> play(SystemSoundType type) => SystemSound.play(type);
  static Future<void> click() => SystemSound.play(SystemSoundType.click);
  static Future<void> alert() => SystemSound.play(SystemSoundType.alert);
}
