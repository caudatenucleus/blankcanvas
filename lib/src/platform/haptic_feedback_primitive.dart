// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Haptic feedback wrapper
class HapticFeedbackPrimitive {
  static Future<void> lightImpact() => HapticFeedback.lightImpact();
  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();
  static Future<void> heavyImpact() => HapticFeedback.heavyImpact();
  static Future<void> selectionClick() => HapticFeedback.selectionClick();
  static Future<void> vibrate() => HapticFeedback.vibrate();
}
