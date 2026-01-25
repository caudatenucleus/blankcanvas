import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// A widget that positions its children relative to the edges of its box.
class Stack extends MultiChildRenderObjectWidget {
  const Stack({
    super.key,
    super.children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) : _alignment = alignment,
       _textDirection = textDirection,
       _fit = fit,
       _clipBehavior = clipBehavior;

  final AlignmentGeometry _alignment;
  final TextDirection? _textDirection;
  final StackFit _fit;
  final Clip _clipBehavior;

  @override
  RenderStack createRenderObject(BuildContext context) {
    return RenderStack(
      alignment: _alignment,
      textDirection: _textDirection ?? Directionality.maybeOf(context),
      fit: _fit,
      clipBehavior: _clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    renderObject
      ..alignment = _alignment
      ..textDirection = _textDirection ?? Directionality.maybeOf(context)
      ..fit = _fit
      ..clipBehavior = _clipBehavior;
  }
}
