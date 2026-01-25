// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFlowRepaintSignal - Optimization boundary signal
// =============================================================================

class FlowRepaintSignalPrimitive extends ChangeNotifier {
  void triggerRepaint() {
    notifyListeners();
  }
}
