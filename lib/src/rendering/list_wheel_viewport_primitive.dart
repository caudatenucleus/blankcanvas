// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderListWheelViewport - 3D cylindrical scroll layout engine
// =============================================================================

class ListWheelViewportPrimitive extends ListWheelViewport {
  const ListWheelViewportPrimitive({
    super.key,
    required super.childDelegate,
    required super.itemExtent,
    required super.offset,
    super.diameterRatio = RenderListWheelViewport.defaultDiameterRatio,
    super.perspective = RenderListWheelViewport.defaultPerspective,
    super.offAxisFraction = 0.0,
    super.useMagnifier = false,
    super.magnification = 1.0,
    super.overAndUnderCenterOpacity = 1.0,
    super.squeeze = 1.0,
    super.renderChildrenOutsideViewport = false,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  RenderListWheelViewport createRenderObject(BuildContext context) {
    final element = context as ListWheelElement;
    return RenderListWheelViewportPrimitive(
      childManager: element,
      offset: offset,
      itemExtent: itemExtent,
      diameterRatio: diameterRatio,
      perspective: perspective,
      offAxisFraction: offAxisFraction,
      useMagnifier: useMagnifier,
      magnification: magnification,
      overAndUnderCenterOpacity: overAndUnderCenterOpacity,
      squeeze: squeeze,
      renderChildrenOutsideViewport: renderChildrenOutsideViewport,
      clipBehavior: clipBehavior,
    );
  }
}

class RenderListWheelViewportPrimitive extends RenderListWheelViewport {
  RenderListWheelViewportPrimitive({
    required super.childManager,
    required super.offset,
    required super.itemExtent,
    super.diameterRatio,
    super.perspective,
    super.offAxisFraction,
    super.useMagnifier,
    super.magnification,
    super.overAndUnderCenterOpacity,
    super.squeeze,
    super.renderChildrenOutsideViewport,
    super.clipBehavior,
  });
}
