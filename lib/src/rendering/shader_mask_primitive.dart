// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderShaderMask - Fragment-shader composition engine
// =============================================================================

typedef ShaderCallbackPrimitive = Shader Function(Rect bounds);

class ShaderMaskPrimitive extends SingleChildRenderObjectWidget {
  const ShaderMaskPrimitive({
    super.key,
    required this.shaderCallback,
    this.blendMode = BlendMode.modulate,
    super.child,
  });
  final ShaderCallbackPrimitive shaderCallback;
  final BlendMode blendMode;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderShaderMaskPrimitive(
      shaderCallback: shaderCallback,
      blendMode: blendMode,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderShaderMaskPrimitive renderObject,
  ) {
    renderObject
      ..shaderCallback = shaderCallback
      ..blendMode = blendMode;
  }
}

class RenderShaderMaskPrimitive extends RenderProxyBox {
  RenderShaderMaskPrimitive({
    required ShaderCallbackPrimitive shaderCallback,
    BlendMode blendMode = BlendMode.modulate,
    RenderBox? child,
  }) : _shaderCallback = shaderCallback,
       _blendMode = blendMode,
       super(child);

  ShaderCallbackPrimitive _shaderCallback;
  set shaderCallback(ShaderCallbackPrimitive value) {
    _shaderCallback = value;
    markNeedsPaint();
  }

  BlendMode _blendMode;
  set blendMode(BlendMode value) {
    if (_blendMode != value) {
      _blendMode = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.canvas.saveLayer(offset & size, Paint());
    context.paintChild(child!, offset);
    context.canvas.drawRect(
      offset & size,
      Paint()
        ..blendMode = _blendMode
        ..shader = _shaderCallback(offset & size),
    );
    context.canvas.restore();
  }
}
