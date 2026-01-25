// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Deferred component channel wrapper
class DeferredComponentChannelPrimitive {
  static const MethodChannel deferredComponent =
      SystemChannels.deferredComponent;

  static Future<void> installDeferredComponent({
    required int loadingUnitId,
  }) async {
    await deferredComponent.invokeMethod(
      'installDeferredComponent',
      <String, dynamic>{'loadingUnitId': loadingUnitId},
    );
  }

  static Future<void> uninstallDeferredComponent({
    required int loadingUnitId,
  }) async {
    await deferredComponent.invokeMethod(
      'uninstallDeferredComponent',
      <String, dynamic>{'loadingUnitId': loadingUnitId},
    );
  }
}

// =============================================================================
// SECTION C: Platform Communication
// =============================================================================
