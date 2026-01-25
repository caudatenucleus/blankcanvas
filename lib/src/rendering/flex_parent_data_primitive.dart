// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';

// =============================================================================
// MULTI-CHILD PRIMITIVES
// =============================================================================

// ParentData for flex children
class FlexParentDataPrimitive extends ContainerBoxParentData<RenderBox> {
  int flex = 0;
  FlexFit fit = FlexFit.tight;
}
