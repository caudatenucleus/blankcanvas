// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import '../inputs/text_field.dart';

class RenderAutoComplete extends RenderTextField {
  RenderAutoComplete({super.controller, super.placeholder, super.tag});

  LayerLink? layerLink;

  // Expose hasFocus for Element
  bool get hasFocus => super.focusNode.hasFocus;
  // Super class RenderTextField (in my previous view) had `_focusNode` and local `_userFocusNode`.
  // It didn't expose `focusNode` getter publicly?
  // Checking previous code: `late FocusNode _focusNode;`. It's private logic?
  // Wait, `RenderTextField` didn't have a public getter.
  // I should fix `RenderTextField` or just use `inputConnection`?
  // Actually `attach` adds listener: `_focusNode.addListener(_onFocusChanged)`.
  // I can pass my own focusNode in `createRenderObject` (via element creating one).
  // The Element can create a FocusNode and pass it to RenderAutoComplete.
  // Yes, Element should manage FocusNode lifecycle if Widget didn't provide one.

  @override
  void paint(PaintingContext context, Offset offset) {
    if (layerLink != null) {
      context.pushLayer(
        LeaderLayer(link: layerLink!, offset: Offset.zero),
        super.paint,
        offset,
      );
    } else {
      super.paint(context, offset);
    }
  }
}

// Helper Widget for the list
