// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'cascade_option.dart';
import 'cascade_select.dart';
import 'render_cascade_select.dart';
import 'cascade_select_popup.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;

class CascadeSelectElement<T> extends LeafRenderObjectElement {
  CascadeSelectElement(CascadeSelect<T> super.widget);

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<List<CascadeOption<T>>> _columns = [];
  List<T> _tempSelectedPath = [];

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final render = renderObject as RenderCascadeSelect<T>;
    render.layerLink = _layerLink;
    render.onTap = _toggle;
    _syncStateFromWidget();
  }

  @override
  void update(CascadeSelect<T> newWidget) {
    super.update(newWidget);
    _syncStateFromWidget();
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  void _syncStateFromWidget() {
    final widget = this.widget as CascadeSelect<T>;
    if (_overlayEntry == null) {
      _tempSelectedPath = List.from(widget.selectedPath);
      _buildColumns();
    }
  }

  void _buildColumns() {
    final widget = this.widget as CascadeSelect<T>;
    _columns = [widget.options];
    List<CascadeOption<T>> current = widget.options;

    for (final value in _tempSelectedPath) {
      final found = current.where((o) => o.value == value).toList();
      if (found.isNotEmpty && found.first.hasChildren) {
        current = found.first.children;
        _columns.add(current);
      }
    }
  }

  void _toggle() {
    if (_overlayEntry != null) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _syncStateFromWidget();
    final renderBox = renderObject as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 500,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: layout.Align(
              alignment: Alignment.topLeft,
              child: CascadeSelectPopup<T>(
                columns: _columns,
                selectedPath: _tempSelectedPath,
                onSelect: _handleSelection,
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(this).insert(_overlayEntry!);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleSelection(int colIndex, CascadeOption<T> option) {
    if (colIndex < _tempSelectedPath.length) {
      _tempSelectedPath = _tempSelectedPath.take(colIndex).toList();
    }
    _tempSelectedPath.add(option.value);

    _buildColumns();

    _overlayEntry?.markNeedsBuild();

    if (!option.hasChildren) {
      (widget as CascadeSelect<T>).onChanged(_tempSelectedPath);
      _close();
    }
  }

  @override
  void unmount() {
    _close();
    super.unmount();
  }
}
