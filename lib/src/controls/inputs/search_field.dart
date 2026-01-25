import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/controls/inputs/text_field.dart' as bc;
import 'package:blankcanvas/src/controls/buttons/button.dart' as bc_button;
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// A generic ParentData for SearchField slots.
class SearchFieldParentData extends ContainerBoxParentData<RenderBox> {
  // 0: input, 1: clear, 2: search
  int slot = 0;
}

class SearchFieldSlot extends ParentDataWidget<SearchFieldParentData> {
  const SearchFieldSlot({super.key, required this.slot, required super.child});
  final int slot;
  @override
  void applyParentData(RenderObject renderObject) {
    final pd = renderObject.parentData as SearchFieldParentData;
    if (pd.slot != slot) {
      pd.slot = slot;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SearchField;
}

/// A search field with clear and search action buttons using low-level primitives.
class SearchField extends MultiChildRenderObjectWidget {
  SearchField({
    super.key,
    this.controller,
    this.placeholder = 'Search...',
    this.onChanged,
    this.onSearchPressed,
    this.tag,
  }) : super(
         children: _buildChildren(
           controller,
           placeholder,
           tag,
           onChanged,
           onSearchPressed,
         ),
       );

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchPressed;
  final String? tag;

  static List<Widget> _buildChildren(
    TextEditingController? controller,
    String placeholder,
    String? tag,
    ValueChanged<String>? onChanged,
    VoidCallback? onSearchPressed,
  ) {
    return [
      SearchFieldSlot(
        slot: 0,
        child: bc.TextField(
          controller: controller,
          placeholder: placeholder,
          tag: tag,
          onChanged: onChanged,
        ),
      ),
      SearchFieldSlot(
        slot: 1,
        child: bc_button.Button(
          onPressed: () {
            controller?.clear();
            onChanged?.call('');
          },
          tag: 'icon',
          child: const ParagraphPrimitive(
            text: TextSpan(text: '✕', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
      SearchFieldSlot(
        slot: 2,
        child: bc_button.Button(
          onPressed: onSearchPressed,
          tag: 'primary',
          child: const ParagraphPrimitive(
            text: TextSpan(text: '🔍', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    ];
  }

  @override
  RenderSearchField createRenderObject(BuildContext context) {
    return RenderSearchField(controller: controller, onChanged: onChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSearchField renderObject,
  ) {
    renderObject.controller = controller;
    renderObject.onChanged = onChanged;
  }
}

class RenderSearchField extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SearchFieldParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SearchFieldParentData> {
  RenderSearchField({
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) : _controller = controller,
       _onChanged = onChanged;

  TextEditingController? _controller;
  set controller(TextEditingController? val) {
    if (_controller != val) {
      _controller?.removeListener(markNeedsLayout);
      _controller = val;
      _controller?.addListener(markNeedsLayout);
      markNeedsLayout();
    }
  }

  // ignore: unused_field
  ValueChanged<String>? _onChanged;
  set onChanged(ValueChanged<String>? value) {
    _onChanged = value;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller?.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _controller?.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SearchFieldParentData) {
      child.parentData = SearchFieldParentData();
    }
  }

  @override
  void performLayout() {
    final double spacing = 8.0;
    double widthUsed = 0;
    double maxHeight = 0;

    RenderBox? input;
    RenderBox? clear;
    RenderBox? search;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as SearchFieldParentData;
      if (pd.slot == 0) input = child;
      if (pd.slot == 1) clear = child;
      if (pd.slot == 2) search = child;
      child = childAfter(child);
    }

    if (search != null) {
      search.layout(constraints.loosen(), parentUsesSize: true);
      widthUsed += search.size.width + spacing;
      maxHeight = search.size.height;
    }

    bool showClear = _controller != null && _controller!.text.isNotEmpty;
    if (clear != null) {
      if (showClear) {
        clear.layout(constraints.loosen(), parentUsesSize: true);
        widthUsed += clear.size.width + spacing;
        if (clear.size.height > maxHeight) maxHeight = clear.size.height;
      } else {
        clear.layout(BoxConstraints.tight(Size.zero));
      }
    }

    if (input != null) {
      final remainingWidth = (constraints.maxWidth - widthUsed).clamp(
        0.0,
        double.infinity,
      );
      input.layout(
        BoxConstraints(
          minWidth: remainingWidth,
          maxWidth: remainingWidth,
          minHeight: 0,
        ),
        parentUsesSize: true,
      );
      if (input.size.height > maxHeight) maxHeight = input.size.height;
    }

    double currentX = 0;
    if (input != null) {
      final pd = input.parentData as SearchFieldParentData;
      pd.offset = Offset(currentX, (maxHeight - input.size.height) / 2);
      currentX += input.size.width + spacing;
    }

    if (showClear && clear != null) {
      final pd = clear.parentData as SearchFieldParentData;
      pd.offset = Offset(currentX, (maxHeight - clear.size.height) / 2);
      currentX += clear.size.width + spacing;
    }

    if (search != null) {
      final pd = search.parentData as SearchFieldParentData;
      pd.offset = Offset(currentX, (maxHeight - search.size.height) / 2);
    }

    size = constraints.constrain(Size(constraints.maxWidth, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
