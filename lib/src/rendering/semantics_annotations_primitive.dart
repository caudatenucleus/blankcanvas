// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSemanticsAnnotations - AX-tree integration engine
// =============================================================================

class SemanticsAnnotationsPrimitive extends SingleChildRenderObjectWidget {
  const SemanticsAnnotationsPrimitive({
    super.key,
    super.child,
    required this.properties,
    this.textDirection,
  });
  final SemanticsProperties properties;
  final TextDirection? textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSemanticsAnnotationsPrimitive(
      properties: properties,
      textDirection: textDirection ?? Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSemanticsAnnotationsPrimitive renderObject,
  ) {
    renderObject
      ..properties = properties
      ..textDirection = textDirection ?? Directionality.maybeOf(context);
  }
}

class RenderSemanticsAnnotationsPrimitive extends RenderProxyBox {
  RenderSemanticsAnnotationsPrimitive({
    required SemanticsProperties properties,
    TextDirection? textDirection,
    RenderBox? child,
  }) : _properties = properties,
       _textDirection = textDirection,
       super(child);

  SemanticsProperties _properties;
  SemanticsProperties get properties => _properties;
  set properties(SemanticsProperties value) {
    if (_properties != value) {
      _properties = value;
      markNeedsSemanticsUpdate();
    }
  }

  TextDirection? _textDirection;
  TextDirection? get textDirection => _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    // Apply key properties
    if (_properties.label != null) config.label = _properties.label!;
    if (_properties.value != null) config.value = _properties.value!;
    if (_properties.hint != null) config.hint = _properties.hint!;
    if (_textDirection != null) config.textDirection = _textDirection;
  }
}
