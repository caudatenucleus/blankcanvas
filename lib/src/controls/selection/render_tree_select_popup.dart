// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'tree_select_node.dart';
import 'tree_item.dart';

class RenderTreeSelectPopup<T> extends RenderBox {
  RenderTreeSelectPopup({
    required List<TreeSelectNode<T>> nodes,
    required List<T> selectedValues,
    required T? selectedValue,
    required bool multiSelect,
    required ValueChanged<TreeSelectNode<T>> onNodeTap,
    required ValueChanged<TreeSelectNode<T>> onExpandTap,
  }) : _nodes = nodes,
       _selectedValues = selectedValues,
       _selectedValue = selectedValue,
       _multiSelect = multiSelect,
       _onNodeTap = onNodeTap,
       _onExpandTap = onExpandTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _drag = PanGestureRecognizer()..onUpdate = _handleDragUpdate;
  }

  List<TreeSelectNode<T>> _nodes;
  set nodes(List<TreeSelectNode<T>> val) {
    if (_nodes != val) {
      _nodes = val;
      markNeedsLayout();
    }
  }

  List<T> _selectedValues;
  set selectedValues(List<T> val) {
    if (_selectedValues != val) {
      _selectedValues = val;
      markNeedsPaint();
    }
  }

  T? _selectedValue;
  set selectedValue(T? val) {
    if (_selectedValue != val) {
      _selectedValue = val;
      markNeedsPaint();
    }
  }

  bool _multiSelect;
  set multiSelect(bool val) {
    if (_multiSelect != val) {
      _multiSelect = val;
      markNeedsLayout();
    }
  } // Might change items if we show checkboxes

  ValueChanged<TreeSelectNode<T>> _onNodeTap;
  set onNodeTap(ValueChanged<TreeSelectNode<T>> val) => _onNodeTap = val;

  ValueChanged<TreeSelectNode<T>> _onExpandTap;
  set onExpandTap(ValueChanged<TreeSelectNode<T>> val) => _onExpandTap = val;

  late TapGestureRecognizer _tap;
  late PanGestureRecognizer _drag;

  double _scrollY = 0;
  List<TreeItem<T>> _flattened = [];

  void _flatten(List<TreeSelectNode<T>> list, int depth) {
    for (var node in list) {
      _flattened.add(TreeItem(node, depth));
      if (node.isExpanded && node.hasChildren) {
        _flatten(node.children, depth + 1);
      }
    }
  }

  @override
  void performLayout() {
    _flattened = [];
    _flatten(_nodes, 0);

    double h = _flattened.length * 40.0;
    size = Size(constraints.maxWidth, math.min(h, 250.0).clamp(40.0, 250.0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Bg
    final Rect rect = offset & size;
    context.canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
    context.canvas.drawShadow(
      Path()..addRect(rect),
      const Color(0x33000000),
      4,
      true,
    );

    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      ctx,
      off,
    ) {
      for (int i = 0; i < _flattened.length; i++) {
        final item = _flattened[i];
        final double y = i * 40.0 - _scrollY;

        if (y + 40 < 0 || y > size.height) continue;

        final bool isSelected = _multiSelect
            ? _selectedValues.contains(item.node.value)
            : _selectedValue == item.node.value;

        if (isSelected) {
          ctx.canvas.drawRect(
            Rect.fromLTWH(off.dx, off.dy + y, size.width, 40),
            Paint()..color = const Color(0xFFE3F2FD),
          );
        }

        // Expand Icon / Checkbox / Label
        double x = off.dx + 12 + item.depth * 16.0;

        // Expand Icon
        if (item.node.hasChildren) {
          // Chevron
          final bool exp = item.node.isExpanded;
          final double cx = x + 8; // Center of 16px area
          final double cy = off.dy + y + 20;
          final Paint cPaint = Paint()
            ..color = const Color(0xFF999999)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          final Path p = Path();
          if (exp) {
            // Down
            p.moveTo(cx - 3, cy - 2);
            p.lineTo(cx, cy + 1);
            p.lineTo(cx + 3, cy - 2);
          } else {
            // Right
            p.moveTo(cx - 2, cy - 3);
            p.lineTo(cx + 1, cy);
            p.lineTo(cx - 2, cy + 3);
          }
          ctx.canvas.drawPath(p, cPaint);
        }

        x += 20;

        // Checkbox if multi
        if (_multiSelect) {
          final cbRect = Rect.fromLTWH(x, off.dy + y + 12, 16, 16);
          final Paint boxPaint = Paint()
            ..color = isSelected ? Color(0xFF2196F3) : Color(0xFFBDBDBD)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          ctx.canvas.drawRect(cbRect, boxPaint);
          if (isSelected) {
            ctx.canvas.drawRect(cbRect, Paint()..color = Color(0xFF2196F3));
            // check
            final cp = Path();
            cp.moveTo(cbRect.left + 4, cbRect.top + 8);
            cp.lineTo(cbRect.left + 6, cbRect.top + 12);
            cp.lineTo(cbRect.left + 12, cbRect.top + 5);
            ctx.canvas.drawPath(
              cp,
              Paint()
                ..color = Color(0xFFFFFFFF)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5,
            );
          }
          x += 24;
        }

        // Labels
        final tp = TextPainter(
          text: TextSpan(
            text: item.node.label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.width - x - 12);

        tp.paint(ctx.canvas, Offset(x, off.dy + y + (40 - tp.height) / 2));
      }
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _scrollY -= details.delta.dy;
    final contentHeight = _flattened.length * 40.0;
    _scrollY = _scrollY.clamp(0.0, math.max(0.0, contentHeight - size.height));
    markNeedsPaint();
  }

  void _handleTapUp(TapUpDetails details) {
    final pos = details.localPosition;
    final vy = pos.dy + _scrollY;
    final index = (vy / 40.0).floor();

    if (index >= 0 && index < _flattened.length) {
      final item = _flattened[index];
      final double itemBaseX = 12 + item.depth * 16.0;

      // Check if tap on expand icon
      if (item.node.hasChildren) {
        // touch target for expand: 0 to itemBaseX+20
        if (pos.dx < itemBaseX + 20) {
          _onExpandTap(item.node);
          return;
        }
      }

      // Else select
      _onNodeTap(item.node);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
      _drag.addPointer(event);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    _drag.dispose();
    super.detach();
  }
}
