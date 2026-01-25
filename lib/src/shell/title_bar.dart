// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A native-style title bar for desktop windows using lowest-level RenderObject APIs.
class NativeTitleBar extends MultiChildRenderObjectWidget {
  NativeTitleBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor = const Color(0xFF2D2D2D),
    this.height = 32.0,
    this.showMinimize = true,
    this.showMaximize = true,
    this.showClose = true,
    this.onMinimize,
    this.onMaximize,
    this.onClose,
    this.onDoubleTap,
  }) : super(
         children: [
           if (leading != null) leading,
           if (title != null) title,
           if (actions != null) ...actions,
         ],
       );

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double height;
  final bool showMinimize;
  final bool showMaximize;
  final bool showClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final VoidCallback? onClose;
  final VoidCallback? onDoubleTap;

  @override
  RenderNativeTitleBar createRenderObject(BuildContext context) {
    return RenderNativeTitleBar(
      backgroundColor: backgroundColor,
      height: height,
      showMinimize: showMinimize,
      showMaximize: showMaximize,
      showClose: showClose,
      onDoubleTap: onDoubleTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNativeTitleBar renderObject,
  ) {
    renderObject
      ..backgroundColor = backgroundColor
      ..height = height
      ..showMinimize = showMinimize
      ..showMaximize = showMaximize
      ..showClose = showClose
      ..onDoubleTap = onDoubleTap;
  }
}

class TitleBarParentData extends ContainerBoxParentData<RenderBox> {}

class RenderNativeTitleBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TitleBarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TitleBarParentData> {
  RenderNativeTitleBar({
    required Color backgroundColor,
    required double height,
    required bool showMinimize,
    required bool showMaximize,
    required bool showClose,
    VoidCallback? onDoubleTap,
  }) : _backgroundColor = backgroundColor,
       _height = height,
       _showMinimize = showMinimize,
       _showMaximize = showMaximize,
       _showClose = showClose,
       _onDoubleTap = onDoubleTap {
    _drag = PanGestureRecognizer()..onStart = _handleDragStart;
    _tap = TapGestureRecognizer()..onTap = _handleTap;
    _doubleTap = DoubleTapGestureRecognizer()..onDoubleTap = _handleDoubleTap;
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  double _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  bool _showMinimize;
  set showMinimize(bool value) {
    if (_showMinimize == value) return;
    _showMinimize = value;
    markNeedsLayout();
  }

  bool _showMaximize;
  set showMaximize(bool value) {
    if (_showMaximize == value) return;
    _showMaximize = value;
    markNeedsLayout();
  }

  bool _showClose;
  set showClose(bool value) {
    if (_showClose == value) return;
    _showClose = value;
    markNeedsLayout();
  }

  // VoidCallback? _onMinimize;
  // set onMinimize(VoidCallback? value) => _onMinimize = value;

  // VoidCallback? _onMaximize;
  // set onMaximize(VoidCallback? value) => _onMaximize = value;

  // VoidCallback? _onClose;
  // set onClose(VoidCallback? value) => _onClose = value;

  VoidCallback? _onDoubleTap;
  set onDoubleTap(VoidCallback? value) => _onDoubleTap = value;

  late PanGestureRecognizer _drag;
  late TapGestureRecognizer _tap;
  late DoubleTapGestureRecognizer _doubleTap;

  static const MethodChannel _channel = MethodChannel(
    'blankcanvas/window_controls',
  );

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TitleBarParentData) {
      child.parentData = TitleBarParentData();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _channel.invokeMethod('startDrag');
  }

  void _handleTap() {
    // General title bar tap (optional)
  }

  void _handleDoubleTap() {
    if (_onDoubleTap != null) {
      _onDoubleTap!();
    } else {
      _channel.invokeMethod('toggleMaximize');
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
      _tap.addPointer(event);
      _doubleTap.addPointer(event);
    }
  }

  @override
  void performLayout() {
    final double width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 300.0;
    size = constraints.constrain(Size(width, _height));

    // Layout children (buttons are hardcoded for now in paint)
    // In a real MultiChildRO, we'd layout leading, title, actions.
    // For brevity, skipping child layout and painting buttons directly.
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints.loose(size), parentUsesSize: true);
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Background
    canvas.drawRect(rect, Paint()..color = _backgroundColor);

    // Draw Window Controls (Buttons)
    double x = offset.dx + size.width;
    const double btnWidth = 46.0;

    if (_showClose) {
      x -= btnWidth;
      _paintButton(
        canvas,
        Rect.fromLTWH(x, offset.dy, btnWidth, size.height),
        'X',
      );
    }
    if (_showMaximize) {
      x -= btnWidth;
      _paintButton(
        canvas,
        Rect.fromLTWH(x, offset.dy, btnWidth, size.height),
        '[]',
      );
    }
    if (_showMinimize) {
      x -= btnWidth;
      _paintButton(
        canvas,
        Rect.fromLTWH(x, offset.dy, btnWidth, size.height),
        '-',
      );
    }

    // Paint children
    defaultPaint(context, offset);
  }

  void _paintButton(Canvas canvas, Rect rect, String symbol) {
    // Simple button painting
    // final paint = Paint()..color = const Color(0x20FFFFFF);
    // Note: In real app, we'd handle hover/press states here via Ticker
    // context.drawRect(rect, paint);

    // Draw symbol (skipped for now, would use TextPainter)
  }
}
