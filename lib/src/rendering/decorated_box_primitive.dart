// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderDecoratedBox - Decoration painting engine
// =============================================================================

class DecoratedBoxPrimitive extends SingleChildRenderObjectWidget {
  const DecoratedBoxPrimitive({
    super.key,
    required this.decoration,
    super.child,
    this.position = DecorationPosition.background,
  });

  final Decoration decoration;
  final DecorationPosition position;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDecoratedBoxPrimitive(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDecoratedBoxPrimitive renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..position = position
      ..configuration = createLocalImageConfiguration(context);
  }
}

class RenderDecoratedBoxPrimitive extends RenderProxyBox {
  RenderDecoratedBoxPrimitive({
    required Decoration decoration,
    DecorationPosition position = DecorationPosition.background,
    required ImageConfiguration configuration,
  }) : _decoration = decoration,
       _position = position,
       _configuration = configuration;

  Decoration _decoration;
  Decoration get decoration => _decoration;
  set decoration(Decoration value) {
    if (_decoration != value) {
      _painter?.dispose();
      _painter = null;
      _decoration = value;
      markNeedsPaint();
    }
  }

  DecorationPosition _position;
  DecorationPosition get position => _position;
  set position(DecorationPosition value) {
    if (_position != value) {
      _position = value;
      markNeedsPaint();
    }
  }

  ImageConfiguration _configuration;
  ImageConfiguration get configuration => _configuration;
  set configuration(ImageConfiguration value) {
    if (_configuration != value) {
      _configuration = value;
      markNeedsPaint();
    }
  }

  BoxPainter? _painter;

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _painter ??= _decoration.createBoxPainter(markNeedsPaint);
    final ImageConfiguration filledConfiguration = _configuration.copyWith(
      size: size,
    );

    if (_position == DecorationPosition.background) {
      _painter!.paint(context.canvas, offset, filledConfiguration);
      if (child != null) {
        context.paintChild(child!, offset);
      }
    } else {
      if (child != null) {
        context.paintChild(child!, offset);
      }
      _painter!.paint(context.canvas, offset, filledConfiguration);
    }
  }
}
