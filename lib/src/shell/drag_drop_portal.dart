// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A portal for handling OS drag and drop events, using lowest-level RenderObject APIs.
class DragDropPortal extends SingleChildRenderObjectWidget {
  const DragDropPortal({
    super.key,
    required super.child,
    this.onDragEnter,
    this.onDragLeave,
    this.onDragOver,
    this.onDrop,
    this.enabled = true,
  });

  final VoidCallback? onDragEnter;
  final VoidCallback? onDragLeave;
  final void Function(Offset position)? onDragOver;
  final void Function(List<String> paths)? onDrop;
  final bool enabled;

  @override
  RenderDragDropPortal createRenderObject(BuildContext context) {
    return RenderDragDropPortal(
      enabled: enabled,
      onDragEnter: onDragEnter,
      onDragLeave: onDragLeave,
      onDragOver: onDragOver,
      onDrop: onDrop,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDragDropPortal renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..onDragEnter = onDragEnter
      ..onDragLeave = onDragLeave
      ..onDragOver = onDragOver
      ..onDrop = onDrop;
  }
}

class RenderDragDropPortal extends RenderProxyBox {
  RenderDragDropPortal({
    required bool enabled,
    VoidCallback? onDragEnter,
    VoidCallback? onDragLeave,
    void Function(Offset position)? onDragOver,
    void Function(List<String> paths)? onDrop,
  }) : _enabled = enabled,
       _onDragEnter = onDragEnter,
       _onDragLeave = onDragLeave,
       _onDragOver = onDragOver,
       _onDrop = onDrop {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  bool _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
  }

  VoidCallback? _onDragEnter;
  set onDragEnter(VoidCallback? value) => _onDragEnter = value;

  VoidCallback? _onDragLeave;
  set onDragLeave(VoidCallback? value) => _onDragLeave = value;

  void Function(Offset position)? _onDragOver;
  set onDragOver(void Function(Offset position)? value) => _onDragOver = value;

  void Function(List<String> paths)? _onDrop;
  set onDrop(void Function(List<String> paths)? value) => _onDrop = value;

  bool _isDragging = false;

  static const MethodChannel _channel = MethodChannel('blankcanvas/drag_drop');

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (!_enabled) return;

    switch (call.method) {
      case 'onDragEnter':
        _isDragging = true;
        markNeedsPaint();
        _onDragEnter?.call();
        break;
      case 'onDragLeave':
        _isDragging = false;
        markNeedsPaint();
        _onDragLeave?.call();
        break;
      case 'onDragOver':
        final args = call.arguments as Map<dynamic, dynamic>;
        _onDragOver?.call(
          Offset((args['x'] as num).toDouble(), (args['y'] as num).toDouble()),
        );
        break;
      case 'onDrop':
        _isDragging = false;
        markNeedsPaint();
        final paths = (call.arguments as List<dynamic>).cast<String>();
        _onDrop?.call(paths);
        break;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    if (_isDragging) {
      final canvas = context.canvas;
      final rect = offset & size;

      // Overlay
      canvas.drawRect(rect, Paint()..color = const Color(0x30007AFF));

      // Text "Drop files here" (Placeholder using raw drawing or TextPainter)
      // For brevity, skipping text painting or using a simple Rect
    }
  }
}
