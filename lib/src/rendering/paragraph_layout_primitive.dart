// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderParagraphLayout - Multi-pass text sizing engine
// =============================================================================

class ParagraphLayoutPrimitive extends SingleChildRenderObjectWidget {
  const ParagraphLayoutPrimitive({
    super.key,
    required this.text,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.strutStyle,
    super.child,
  });

  final InlineSpan text;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final TextScaler textScaler;
  final int? maxLines;
  final StrutStyle? strutStyle;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParagraphLayoutPrimitive(
      text: text,
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      strutStyle: strutStyle,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderParagraphLayoutPrimitive renderObject,
  ) {
    renderObject
      ..text = text
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..softWrap = softWrap
      ..overflow = overflow
      ..textScaler = textScaler
      ..maxLines = maxLines
      ..strutStyle = strutStyle;
  }
}

class RenderParagraphLayoutPrimitive extends RenderParagraph {
  RenderParagraphLayoutPrimitive({
    required InlineSpan text,
    TextAlign textAlign = TextAlign.start,
    required TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    TextScaler textScaler = TextScaler.noScaling,
    int? maxLines,
    StrutStyle? strutStyle,
  }) : super(
         text,
         textAlign: textAlign,
         textDirection: textDirection,
         softWrap: softWrap,
         overflow: overflow,
         textScaler: textScaler,
         maxLines: maxLines,
         strutStyle: strutStyle,
       );
}
