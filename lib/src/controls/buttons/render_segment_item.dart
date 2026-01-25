// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;


class SegmentItemParentData extends ContainerBoxParentData<RenderBox> {
  int slot = 0;
}

class RenderSegmentItem extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SegmentItemParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SegmentItemParentData>
    implements TickerProvider {
  RenderSegmentItem({required bool isSelected, VoidCallback? onTap})
    : _isSelected = isSelected,
      _onTap = onTap {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  bool _isSelected;
  set isSelected(bool val) {
    if (_isSelected != val) {
      _isSelected = val;
      markNeedsPaint();
    }
  }

  VoidCallback? _onTap;
  set onTap(VoidCallback? val) => _onTap = val;

  late TapGestureRecognizer _tap;

  Ticker? _ticker;
  double _hoverVal = 0;
  bool _isHovered = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SegmentItemParentData) {
      child.parentData = SegmentItemParentData();
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _isHovered = true;
      _startAnim();
    } else if (event is PointerExitEvent) {
      _isHovered = false;
      _startAnim();
    }
  }

  void _startAnim() {
    if (_ticker == null) {
      _ticker = createTicker((elapsed) {
        double target = _isHovered ? 1.0 : 0.0;
        if ((_hoverVal - target).abs() > 0.01) {
          _hoverVal += (target - _hoverVal) * 0.2;
          markNeedsPaint();
        } else {
          _hoverVal = target;
          _ticker?.stop();
        }
      })..start();
    } else if (!_ticker!.isActive) {
      _ticker!.start();
    }
  }

  void _handleTap() {
    _onTap?.call();
  }

  @override
  void performLayout() {
    double w = 0;
    double h = 0;

    RenderBox? icon;
    RenderBox? label;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as SegmentItemParentData;
      if (pd.slot == 0) icon = child;
      if (pd.slot == 1) label = child;
      child = childAfter(child);
    }

    if (icon != null) {
      icon.layout(constraints.loosen(), parentUsesSize: true);
      w += icon.size.width + 8;
      h = math.max(h, icon.size.height);
    }

    if (label != null) {
      label.layout(constraints.loosen(), parentUsesSize: true);
      w += label.size.width;
      h = math.max(h, label.size.height);
    }

    // Padding
    w += 32;
    h += 20;

    // Layout children
    double cx = 16;
    if (icon != null) {
      final pd = icon.parentData as SegmentItemParentData;
      pd.offset = Offset(cx, (h - icon.size.height) / 2);
      cx += icon.size.width + 8;
    }
    if (label != null) {
      final pd = label.parentData as SegmentItemParentData;
      pd.offset = Offset(cx, (h - label.size.height) / 2);
    }

    size = constraints.constrain(Size(w, h));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Rect rect = offset & size;
    if (_isSelected) {
      context.canvas.drawRect(rect, Paint()..color = const Color(0xFFE0E0E0));
    } else if (_hoverVal > 0) {
      context.canvas.drawRect(
        rect,
        Paint()
          ..color = Color.lerp(
            const Color(0x00000000),
            const Color(0x11000000),
            _hoverVal,
          )!,
      );
    }

    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void detach() {
    _ticker?.dispose();
    _tap.dispose();
    super.detach();
  }
}
