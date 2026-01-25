// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'auto_complete.dart';
import 'render_auto_complete.dart';
import 'auto_complete_list.dart';

class AutoCompleteElement<T> extends LeafRenderObjectElement {
  AutoCompleteElement(AutoComplete<T> super.widget);

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  // State
  List<T> _filteredSuggestions = [];
  int _highlightedIndex = -1;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final render = renderObject as RenderAutoComplete;
    render.layerLink = _layerLink;
    render.onChanged = _onTextChanged;
    render.focusNode = FocusNode()
      ..addListener(_onFocusChanged); // Internal focus node if not provided?
    // Wait, AutoComplete didn't take focusNode param in new Widget?
    // Old one didn't expose it in constructor but managed one internally.
    // RenderTextField manages one if null.
    // We need to listen to it.
    // RenderTextField exposes 'focusNode' setter but we didn't pass one.
    // It creates one internally. We need to access it?
    // RenderTextField doesn't expose the getter for internal node easily if not set.
    // We should pass one to be safe.
  }

  void _onFocusChanged() {
    final render = renderObject as RenderAutoComplete;
    if (!render.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged(String text) {
    final widget = this.widget as AutoComplete<T>;
    if (text.isEmpty) {
      _removeOverlay();
      return;
    }

    final filter =
        widget.filter ??
        (item, q) => item.toString().toLowerCase().contains(q.toLowerCase());

    _filteredSuggestions = widget.suggestions
        .where((item) => filter(item, text))
        .take(widget.maxSuggestions)
        .toList();

    if (_filteredSuggestions.isEmpty) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final renderBox = renderObject as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final widget = this.widget as AutoComplete<T>;

        // Build children here based on _filteredSuggestions
        final children = _filteredSuggestions.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return widget.itemBuilder(item, index == _highlightedIndex);
        }).toList();

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: AutoCompleteList<T>(
              children: children,
              onItemTap: (index) {
                _selectItem(_filteredSuggestions[index]);
              },
              onHover: (index) {
                if (_highlightedIndex != index) {
                  _highlightedIndex = index;
                  _overlayEntry?.markNeedsBuild();
                }
              },
            ),
          ),
        );
      },
    );

    Overlay.of(this).insert(_overlayEntry!);
  }

  void _selectItem(T item) {
    final widget = this.widget as AutoComplete<T>;
    final render = renderObject as RenderAutoComplete;

    // Update text
    render.controller.text = item.toString(); // This triggers listener?
    // Move cursor to end
    render.controller.selection = TextSelection.collapsed(
      offset: render.controller.text.length,
    );

    widget.onSelected(item);
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _highlightedIndex = -1;
  }

  @override
  void unmount() {
    _removeOverlay();
    super.unmount();
  }
}
