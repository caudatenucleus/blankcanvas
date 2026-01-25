import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/theme/workstation_theme.dart';

/// A tabbed container for dock panels using lowest-level RenderObject APIs.
class TabbedDock extends MultiChildRenderObjectWidget {
  TabbedDock({
    super.key,
    required this.tabs,
    required this.content,
    this.selectedIndex = 0,
    this.onTabChanged,
  }) : super(children: [...tabs, ...content]);

  final List<Widget> tabs;
  final List<Widget> content;
  final int selectedIndex;
  final ValueChanged<int>? onTabChanged;

  @override
  RenderTabbedDock createRenderObject(BuildContext context) {
    return RenderTabbedDock(
      selectedIndex: selectedIndex,
      theme: WorkstationTheme.of(context),
      onTabChanged: onTabChanged,
      tabCount: tabs.length,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTabbedDock renderObject) {
    renderObject
      ..selectedIndex = selectedIndex
      ..theme = WorkstationTheme.of(context)
      ..onTabChanged = onTabChanged
      ..tabCount = tabs.length;
  }
}

class TabbedDockParentData extends ContainerBoxParentData<RenderBox> {
  bool isContent = false;
  int? tabIndex;
}

class RenderTabbedDock extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TabbedDockParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TabbedDockParentData> {
  RenderTabbedDock({
    required int selectedIndex,
    required WorkstationThemeData theme,
    required ValueChanged<int>? onTabChanged,
    required int tabCount,
  }) : _selectedIndex = selectedIndex,
       _theme = theme,
       _onTabChanged = onTabChanged,
       _tabCount = tabCount;

  int _selectedIndex;
  set selectedIndex(int value) {
    if (_selectedIndex == value) return;
    _selectedIndex = value;
    markNeedsLayout();
  }

  int _tabCount;
  set tabCount(int value) {
    if (_tabCount == value) return;
    _tabCount = value;
    markNeedsLayout();
  }

  WorkstationThemeData _theme;
  set theme(WorkstationThemeData value) {
    if (_theme == value) return;
    _theme = value;
    markNeedsPaint();
  }

  ValueChanged<int>? _onTabChanged;
  set onTabChanged(ValueChanged<int>? value) {
    _onTabChanged = value;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TabbedDockParentData) {
      child.parentData = TabbedDockParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    if (childCount == 0) return;

    final double tabWidth = _tabCount > 0 ? size.width / _tabCount : 0;

    RenderBox? child = firstChild;
    int index = 0;

    // Layout Tab Widgets
    while (child != null && index < _tabCount) {
      final pd = child.parentData! as TabbedDockParentData;
      pd.isContent = false;
      pd.tabIndex = index;
      child.layout(
        BoxConstraints.tightFor(width: tabWidth, height: 32),
        parentUsesSize: true,
      );
      pd.offset = Offset(index * tabWidth, 0);
      child = pd.nextSibling;
      index++;
    }

    // Layout Content Widgets (only the selected one is visible/laid out properly)
    int contentIndex = 0;
    while (child != null) {
      final pd = child.parentData! as TabbedDockParentData;
      pd.isContent = true;
      if (contentIndex == _selectedIndex) {
        child.layout(
          BoxConstraints.tightFor(width: size.width, height: size.height - 32),
          parentUsesSize: true,
        );
        pd.offset = const Offset(0, 32);
      } else {
        child.layout(BoxConstraints.tight(Size.zero));
        pd.offset = Offset.zero;
      }
      child = pd.nextSibling;
      contentIndex++;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (position.dy < 32) {
      var child = firstChild;
      int index = 0;
      while (child != null && index < _tabCount) {
        final pd = child.parentData! as TabbedDockParentData;
        if (Rect.fromLTWH(
          pd.offset.dx,
          pd.offset.dy,
          child.size.width,
          child.size.height,
        ).contains(position)) {
          _onTabChanged?.call(index);
          return true;
        }
        child = pd.nextSibling;
        index++;
      }
    }
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, 32),
      Paint()..color = _theme.tabInactive,
    );
    if (_tabCount > 0) {
      final double tabWidth = size.width / _tabCount;
      canvas.drawRect(
        Rect.fromLTWH(
          offset.dx + _selectedIndex * tabWidth,
          offset.dy,
          tabWidth,
          32,
        ),
        Paint()..color = _theme.tabActive,
      );
    }
    defaultPaint(context, offset);
  }
}
