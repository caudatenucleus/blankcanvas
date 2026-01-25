// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'tree_select_node.dart';


class RenderTreeSelect<T> extends RenderBox {
  RenderTreeSelect({
    required String placeholder,
    required T? selectedValue,
    required List<T> selectedValues,
    required bool multiSelect,
    required List<TreeSelectNode<T>> nodes,
  }) : _placeholder = placeholder,
       _selectedValue = selectedValue,
       _selectedValues = selectedValues,
       _multiSelect = multiSelect,
       _nodes = nodes {
    _tap = TapGestureRecognizer()..onTap = () => onTap?.call();
  }

  String _placeholder;
  set placeholder(String val) {
    if (_placeholder != val) {
      _placeholder = val;
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

  List<T> _selectedValues;
  set selectedValues(List<T> val) {
    if (_selectedValues != val) {
      _selectedValues = val;
      markNeedsPaint();
    }
  }

  bool _multiSelect;
  set multiSelect(bool val) {
    if (_multiSelect != val) {
      _multiSelect = val;
      markNeedsPaint();
    }
  }

  List<TreeSelectNode<T>> _nodes;
  set nodes(List<TreeSelectNode<T>> val) {
    _nodes = val;
    markNeedsPaint();
  }

  LayerLink? layerLink;
  VoidCallback? onTap;
  late TapGestureRecognizer _tap;

  String? _findLabel(List<TreeSelectNode<T>> nodes, T value) {
    for (final node in nodes) {
      if (node.value == value) return node.label;
      if (node.hasChildren) {
        final found = _findLabel(node.children, value);
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(double.infinity, 44));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint bg = Paint()..color = const Color(0xFFFFFFFF);
    final Paint border = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      bg,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      border,
    );

    String displayText = _placeholder;
    bool isActive = false;

    if (_multiSelect) {
      if (_selectedValues.isNotEmpty) {
        displayText = '${_selectedValues.length} selected';
        isActive = true;
      }
    } else {
      if (_selectedValue != null) {
        displayText = _findLabel(_nodes, _selectedValue as T) ?? _placeholder;
        isActive = true;
      }
    }

    final tp = TextPainter(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: isActive ? Color(0xFF000000) : Color(0xFF999999),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 32);

    tp.paint(
      context.canvas,
      offset + Offset(12, (size.height - tp.height) / 2),
    );

    // Arrow
    final double arrowX = offset.dx + size.width - 16;
    final double arrowY = offset.dy + size.height / 2;
    final Paint arrowPaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.moveTo(arrowX - 4, arrowY - 2);
    path.lineTo(arrowX, arrowY + 2);
    path.lineTo(arrowX + 4, arrowY - 2);
    context.canvas.drawPath(path, arrowPaint);

    if (layerLink != null) {
      context.pushLayer(
        LeaderLayer(link: layerLink!, offset: Offset.zero),
        (c, o) {},
        offset,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }
}
