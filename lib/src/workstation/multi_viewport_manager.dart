// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// Registry/Manager for multiple rendering contexts (multi-viewport).
class MultiViewportManager {
  final Map<String, TransformationController> _viewports = {};

  void registerViewport(String id, TransformationController controller) {
    _viewports[id] = controller;
  }

  void disposeViewport(String id) {
    _viewports.remove(id);
  }

  TransformationController? getViewport(String id) => _viewports[id];

  void resetAll() {
    for (var controller in _viewports.values) {
      controller.value = Matrix4.identity();
    }
  }
}
