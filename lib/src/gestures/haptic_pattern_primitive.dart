// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/services.dart';

// =============================================================================
// Haptic Feedback Primitives - Platform-independent patterns
// =============================================================================

enum HapticPatternType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
  success,
  warning,
  error,
}

class HapticPatternPrimitive {
  const HapticPatternPrimitive._();

  static Future<void> trigger(HapticPatternType pattern) async {
    switch (pattern) {
      case HapticPatternType.lightImpact:
        await HapticFeedback.lightImpact();
        break;
      case HapticPatternType.mediumImpact:
        await HapticFeedback.mediumImpact();
        break;
      case HapticPatternType.heavyImpact:
        await HapticFeedback.heavyImpact();
        break;
      case HapticPatternType.selectionClick:
        await HapticFeedback.selectionClick();
        break;
      case HapticPatternType.vibrate:
        await HapticFeedback.vibrate();
        break;
      case HapticPatternType.success:
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        break;
      case HapticPatternType.warning:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.mediumImpact();
        break;
      case HapticPatternType.error:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        break;
    }
  }
}
