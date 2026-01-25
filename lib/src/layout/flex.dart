import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// A widget that displays its children in a one-dimensional array.
class Flex extends MultiChildRenderObjectWidget {
  const Flex({
    super.key,
    required this.direction,
    super.children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Clip clipBehavior = Clip.none,
  }) : _mainAxisAlignment = mainAxisAlignment,
       _mainAxisSize = mainAxisSize,
       _crossAxisAlignment = crossAxisAlignment,
       _textDirection = textDirection,
       _verticalDirection = verticalDirection,
       _textBaseline = textBaseline,
       _clipBehavior = clipBehavior;

  final Axis direction;
  final MainAxisAlignment _mainAxisAlignment;
  final MainAxisSize _mainAxisSize;
  final CrossAxisAlignment _crossAxisAlignment;
  final TextDirection? _textDirection;
  final VerticalDirection _verticalDirection;
  final TextBaseline? _textBaseline;
  final Clip _clipBehavior;

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return RenderFlex(
      direction: direction,
      mainAxisAlignment: _mainAxisAlignment,
      mainAxisSize: _mainAxisSize,
      crossAxisAlignment: _crossAxisAlignment,
      textDirection: _textDirection ?? Directionality.maybeOf(context),
      verticalDirection: _verticalDirection,
      textBaseline: _textBaseline,
      clipBehavior: _clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlex renderObject) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = _mainAxisAlignment
      ..mainAxisSize = _mainAxisSize
      ..crossAxisAlignment = _crossAxisAlignment
      ..textDirection = _textDirection ?? Directionality.maybeOf(context)
      ..verticalDirection = _verticalDirection
      ..textBaseline = _textBaseline
      ..clipBehavior = _clipBehavior;
  }
}
