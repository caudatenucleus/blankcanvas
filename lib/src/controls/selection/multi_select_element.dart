// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'multi_select.dart';
import 'render_multi_select.dart';
import 'multi_select_popup.dart';

class MultiSelectElement<T> extends MultiChildRenderObjectElement {
  MultiSelectElement(MultiSelect<T> super.widget);

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as RenderMultiSelect).layerLink = _layerLink;
    (renderObject as RenderMultiSelect).onTap = _toggleDropdown;
  }

  @override
  void unmount() {
    _removeOverlay();
    super.unmount();
  }

  @override
  void update(MultiSelect<T> newWidget) {
    super.update(newWidget);
    if (_overlayEntry != null) {
      // Defer rebuild to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox renderBox = renderObject as RenderBox;
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final widget = this.widget as MultiSelect<T>;
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: MultiSelectPopup<T>(
              options: widget.options,
              selectedValues: widget.selectedValues,
              labelBuilder: widget.labelBuilder,
              onSelect: (item) {
                // Toggle logic
                List<T> current = List.from(widget.selectedValues);
                if (current.contains(item)) {
                  current.remove(item);
                } else {
                  if (widget.maxSelections == null ||
                      current.length < widget.maxSelections!) {
                    current.add(item);
                  }
                }
                widget.onChanged(current);
                // Need to rebuild overlay?
                _overlayEntry?.markNeedsBuild();
              },
            ),
          ),
        );
      },
    );
    Overlay.of(this).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

// Internal Chip Widget
