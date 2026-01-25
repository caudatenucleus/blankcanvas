// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

class RenderTransferList<T> extends RenderBox {
  RenderTransferList({
    required String title,
    required List<T> items,
    required Set<int> selectedIndices,
    required ValueChanged<Set<int>> onSelectionChanged,
  }) : _title = title,
       _items = items,
       _selectedIndices = selectedIndices,
       _onSelectionChanged = onSelectionChanged {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _drag = PanGestureRecognizer()..onUpdate = _handleDragUpdate;
  }

  String _title;
  set title(String val) {
    if (_title != val) {
      _title = val;
      markNeedsPaint();
    }
  }

  List<T> _items;
  set items(List<T> val) {
    if (_items != val) {
      _items = val;
      markNeedsPaint();
    }
  }

  Set<int> _selectedIndices;
  set selectedIndices(Set<int> val) {
    if (_selectedIndices != val) {
      _selectedIndices = val;
      markNeedsPaint();
    }
  }

  ValueChanged<Set<int>> _onSelectionChanged;
  set onSelectionChanged(ValueChanged<Set<int>> val) =>
      _onSelectionChanged = val;

  late TapGestureRecognizer _tap;
  late PanGestureRecognizer _drag;
  double _scrollY = 0;

  static const double _headerHeight = 40.0;
  static const double _itemHeight = 36.0;

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint borderPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke;
    context.canvas.drawRect(rect, borderPaint);

    // Header
    final Rect headerRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _headerHeight,
    );
    context.canvas.drawRect(
      headerRect,
      Paint()..color = const Color(0xFFF5F5F5),
    );
    context.canvas.drawLine(
      headerRect.bottomLeft,
      headerRect.bottomRight,
      borderPaint,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '$_title (${_selectedIndices.length}/${_items.length})',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Color(0xFF000000),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      context.canvas,
      offset + Offset(12, (_headerHeight - tp.height) / 2),
    );

    // Items
    context.pushClipRect(
      needsCompositing,
      offset,
      Rect.fromLTWH(0, _headerHeight, size.width, size.height - _headerHeight),
      (ctx, off) {
        for (int i = 0; i < _items.length; i++) {
          final double y = _headerHeight + i * _itemHeight - _scrollY;
          if (y + _itemHeight < _headerHeight || y > size.height) continue;

          final bool isSelected = _selectedIndices.contains(i);
          final Rect itemRect = Rect.fromLTWH(
            off.dx,
            off.dy + y,
            size.width,
            _itemHeight,
          );

          if (isSelected) {
            ctx.canvas.drawRect(
              itemRect,
              Paint()..color = const Color(0xFFE3F2FD),
            );
          }

          // Checkbox
          double cx = off.dx + 12;
          double cy = off.dy + y + 10;
          final Rect cbRect = Rect.fromLTWH(cx, cy, 16, 16);
          final Paint cbPaint = Paint()
            ..color = isSelected ? Color(0xFF2196F3) : Color(0xFFBDBDBD)
            ..style = PaintingStyle.stroke;
          ctx.canvas.drawRect(cbRect, cbPaint);
          if (isSelected) {
            ctx.canvas.drawRect(cbRect, Paint()..color = Color(0xFF2196F3));
            // check
            final p = Path();
            p.moveTo(cx + 4, cy + 8);
            p.lineTo(cx + 6, cy + 12);
            p.lineTo(cx + 12, cy + 5);
            ctx.canvas.drawPath(
              p,
              Paint()
                ..color = Color(0xFFFFFFFF)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5,
            );
          }

          final label = _items[i].toString();
          final tpItem = TextPainter(
            text: TextSpan(
              text: label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
            ),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: size.width - 40);

          tpItem.paint(
            ctx.canvas,
            Offset(cx + 24, off.dy + y + (_itemHeight - tpItem.height) / 2),
          );
        }
      },
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _scrollY -= details.delta.dy;
    final contentHeight = _items.length * _itemHeight;
    final maxScroll = math.max(
      0.0,
      contentHeight - (size.height - _headerHeight),
    );
    _scrollY = _scrollY.clamp(0.0, maxScroll);
    markNeedsPaint();
  }

  void _handleTapUp(TapUpDetails details) {
    if (details.localPosition.dy < _headerHeight) return;

    final double y = details.localPosition.dy - _headerHeight + _scrollY;
    final int index = (y / _itemHeight).floor();

    if (index >= 0 && index < _items.length) {
      final newSet = Set<int>.from(_selectedIndices);
      if (newSet.contains(index)) {
        newSet.remove(index);
      } else {
        newSet.add(index);
      }
      _onSelectionChanged(newSet);
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
