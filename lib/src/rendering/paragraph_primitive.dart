// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

// =============================================================================
// RenderParagraph - Text geometry and painting engine
// =============================================================================

class ParagraphPrimitive extends LeafRenderObjectWidget {
  const ParagraphPrimitive({
    super.key,
    required this.text,
    this.textDirection = TextDirection.ltr,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });
  final InlineSpan text;
  final TextDirection textDirection;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParagraphPrimitive(
      text: text,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderParagraphPrimitive renderObject,
  ) {
    renderObject
      ..text = text
      ..textDirection = textDirection
      ..maxLines = maxLines
      ..overflow = overflow;
  }
}

class RenderParagraphPrimitive extends RenderBox {
  RenderParagraphPrimitive({
    required InlineSpan text,
    TextDirection textDirection = TextDirection.ltr,
    int? maxLines,
    TextOverflow overflow = TextOverflow.clip,
  }) : _textPainter = TextPainter(
         text: text,
         textDirection: textDirection,
         maxLines: maxLines,
         ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
       );

  final TextPainter _textPainter;

  InlineSpan get text => _textPainter.text!;
  set text(InlineSpan value) {
    if (_textPainter.text != value) {
      _textPainter.text = value;
      markNeedsLayout();
    }
  }

  TextDirection get textDirection => _textPainter.textDirection!;
  set textDirection(TextDirection value) {
    if (_textPainter.textDirection != value) {
      _textPainter.textDirection = value;
      markNeedsLayout();
    }
  }

  int? get maxLines => _textPainter.maxLines;
  set maxLines(int? value) {
    if (_textPainter.maxLines != value) {
      _textPainter.maxLines = value;
      markNeedsLayout();
    }
  }

  TextOverflow _overflow = TextOverflow.clip;
  set overflow(TextOverflow value) {
    if (_overflow != value) {
      _overflow = value;
      _textPainter.ellipsis = value == TextOverflow.ellipsis ? '\u2026' : null;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    _textPainter.layout(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
    );
    size = constraints.constrain(Size(_textPainter.width, _textPainter.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _textPainter.layout();
    return _textPainter.minIntrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _textPainter.layout();
    return _textPainter.maxIntrinsicWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _textPainter.layout(maxWidth: width);
    return _textPainter.height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _textPainter.layout(maxWidth: width);
    return _textPainter.height;
  }
}
