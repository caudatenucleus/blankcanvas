// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFlowDelegate - Manual paint-matrix control
// =============================================================================

// Note: FlowDelegate is already abstract in Flutter.
// This primitive wraps it for explicit use in the primitive layer.

abstract class FlowDelegatePrimitive extends FlowDelegate {
  const FlowDelegatePrimitive({super.repaint});
}
