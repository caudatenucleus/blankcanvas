// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'dropdown.dart';
import 'render_dropdown_button.dart';
import 'dropdown_menu.dart';


class DropdownElement<T> extends MultiChildRenderObjectElement {
  DropdownElement(Dropdown<T> super.widget);

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as RenderDropdownButton).onTap = _toggleDropdown;
    (renderObject as RenderDropdownButton).layerLink = _layerLink;
  }

  @override
  void unmount() {
    _removeOverlay();
    super.unmount();
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
        final widget = this.widget as Dropdown<T>;

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 5),
            child: DropdownMenu<T>(
              items: widget.items,
              onSelected: (val) {
                widget.onChanged(val);
                _removeOverlay();
              },
            ),
          ),
        );
      },
    );

    Overlay.of(this).insert(_overlayEntry!);
    (renderObject as RenderDropdownButton).isOpen = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    (renderObject as RenderDropdownButton).isOpen = false;
  }
}
