// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart'; // Core structural widgets allowed for implementation of RenderObjectWidget
import 'segment_item.dart';
import 'render_segmented_button.dart';

/// A segmented button control.
class SegmentedButton<T> extends MultiChildRenderObjectWidget {
  SegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    this.onChanged,
    this.multiSelect = false,
  }) : super(
         children: _buildChildren(segments, selected, multiSelect, onChanged),
       );

  final List<Segment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onChanged;
  final bool multiSelect;

  static List<Widget> _buildChildren<T>(
    List<Segment<T>> segments,
    Set<T> selected,
    bool multiSelect,
    ValueChanged<Set<T>>? onChanged,
  ) {
    return segments.map((segment) {
      final isSelected = selected.contains(segment.value);
      return SegmentItem(
        value: segment.value,
        label: segment.label,
        icon: segment.icon,
        isSelected: isSelected,
        onTap: () {
          if (onChanged == null) return;
          final newSelection = Set<T>.of(selected);
          if (multiSelect) {
            if (isSelected) {
              newSelection.remove(segment.value);
            } else {
              newSelection.add(segment.value);
            }
          } else {
            newSelection.clear();
            newSelection.add(segment.value!);
          }
          onChanged(newSelection);
        },
      );
    }).toList();
  }

  @override
  RenderSegmentedButton createRenderObject(BuildContext context) {
    return RenderSegmentedButton();
  }
}

class Segment<T> {
  const Segment({required this.value, this.label, this.icon});

  final T value;
  final Widget? label;
  final Widget? icon;
}
