// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

// =============================================================================
// RenderImage - Bitmap rendering & scaling logic
// =============================================================================

class ImagePrimitive extends LeafRenderObjectWidget {
  const ImagePrimitive({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });
  final ui.Image image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderImagePrimitive(
      image: image,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderImagePrimitive renderObject,
  ) {
    renderObject
      ..image = image
      ..width = width
      ..height = height
      ..fit = fit
      ..alignment = alignment;
  }
}

class RenderImagePrimitive extends RenderBox {
  RenderImagePrimitive({
    required ui.Image image,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
  }) : _image = image,
       _width = width,
       _height = height,
       _fit = fit,
       _alignment = alignment;

  ui.Image _image;
  ui.Image get image => _image;
  set image(ui.Image value) {
    _image = value;
    markNeedsPaint();
  }

  double? _width;
  set width(double? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  double? _height;
  set height(double? value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  BoxFit _fit;
  set fit(BoxFit value) {
    if (_fit != value) {
      _fit = value;
      markNeedsPaint();
    }
  }

  Alignment _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(
        _width ?? _image.width.toDouble(),
        _height ?? _image.height.toDouble(),
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect src = Rect.fromLTWH(
      0,
      0,
      _image.width.toDouble(),
      _image.height.toDouble(),
    );
    final FittedSizes sizes = applyBoxFit(_fit, src.size, size);
    final Rect dst = _alignment.inscribe(sizes.destination, offset & size);
    final Rect srcFitted = _alignment.inscribe(sizes.source, src);
    context.canvas.drawImageRect(_image, srcFitted, dst, Paint());
  }
}
