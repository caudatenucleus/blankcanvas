import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// A vertical array of children.
class Column extends MultiChildRenderObjectWidget {
  const Column({
    super.key,
    super.children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
  }) : _mainAxisAlignment = mainAxisAlignment,
       _mainAxisSize = mainAxisSize,
       _crossAxisAlignment = crossAxisAlignment,
       _textDirection = textDirection,
       _verticalDirection = verticalDirection,
       _textBaseline = textBaseline;

  final MainAxisAlignment _mainAxisAlignment;
  final MainAxisSize _mainAxisSize;
  final CrossAxisAlignment _crossAxisAlignment;
  final TextDirection? _textDirection;
  final VerticalDirection _verticalDirection;
  final TextBaseline? _textBaseline;

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return RenderFlex(
      direction: Axis.vertical,
      mainAxisAlignment: _mainAxisAlignment,
      mainAxisSize: _mainAxisSize,
      crossAxisAlignment: _crossAxisAlignment,
      textDirection: _textDirection ?? Directionality.maybeOf(context),
      verticalDirection: _verticalDirection,
      textBaseline: _textBaseline,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlex renderObject) {
    renderObject
      ..direction = Axis.vertical
      ..mainAxisAlignment = _mainAxisAlignment
      ..mainAxisSize = _mainAxisSize
      ..crossAxisAlignment = _crossAxisAlignment
      ..textDirection = _textDirection ?? Directionality.maybeOf(context)
      ..verticalDirection = _verticalDirection
      ..textBaseline = _textBaseline;
  }
}
