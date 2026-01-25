// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// System navigator wrapper
class SystemNavigatorPrimitive {
  static Future<void> pop({bool? animated}) =>
      SystemNavigator.pop(animated: animated);

  static Future<void> setFrameworkHandlesBack(bool handlesBack) =>
      SystemNavigator.setFrameworkHandlesBack(handlesBack);
}

// =============================================================================
// SECTION B: System Channels
// =============================================================================
