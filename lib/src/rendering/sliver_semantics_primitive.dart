// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverSemantics - AX-subtree sliver integration
// =============================================================================

class SliverSemanticsPrimitive extends SingleChildRenderObjectWidget {
  const SliverSemanticsPrimitive({
    super.key,
    required this.properties,
    super.child,
  });

  final SemanticsProperties properties;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverSemanticsPrimitive(properties: properties);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverSemanticsPrimitive renderObject,
  ) {
    renderObject.properties = properties;
  }
}

class RenderSliverSemanticsPrimitive extends RenderProxySliver {
  RenderSliverSemanticsPrimitive({required SemanticsProperties properties})
    : _properties = properties;

  SemanticsProperties _properties;
  SemanticsProperties get properties => _properties;
  set properties(SemanticsProperties value) {
    if (_properties != value) {
      _properties = value;
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    if (_properties.label != null) config.label = _properties.label!;
    if (_properties.value != null) config.value = _properties.value!;
    if (_properties.hint != null) config.hint = _properties.hint!;
  }
}
