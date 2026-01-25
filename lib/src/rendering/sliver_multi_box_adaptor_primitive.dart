// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverMultiBoxAdaptor - Multi-box orchestration (base class wrapper)
// =============================================================================

// Note: RenderSliverMultiBoxAdaptor is abstract in Flutter.
// We provide a thin wrapper for the element/child manager pattern.

abstract class SliverMultiBoxAdaptorPrimitive
    extends SliverMultiBoxAdaptorWidget {
  const SliverMultiBoxAdaptorPrimitive({super.key, required super.delegate});
}
