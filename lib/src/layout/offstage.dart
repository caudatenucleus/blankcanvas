// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// without the child being available for hit testing, and without it taking up any room in the parent.
class Offstage extends SingleChildRenderObjectWidget {
  const Offstage({super.key, this.offstage = true, super.child});

  final bool offstage;

  @override
  RenderOffstage createRenderObject(BuildContext context) {
    return RenderOffstage(offstage: offstage);
  }

  @override
  void updateRenderObject(BuildContext context, RenderOffstage renderObject) {
    renderObject.offstage = offstage;
  }
}
