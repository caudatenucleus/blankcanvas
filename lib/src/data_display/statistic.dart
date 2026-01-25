import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../rendering/paragraph_primitive.dart';

class Statistic extends MultiChildRenderObjectWidget {
  Statistic({
    super.key,
    required this.label,
    required this.value,
    this.prefix,
    this.suffix,
    this.trend,
    this.valueStyle,
    this.labelStyle,
    this.tag,
  }) : super(
         children: _buildChildren(
           label,
           value,
           labelStyle,
           valueStyle,
           prefix,
           suffix,
           trend,
         ),
       );

  final String label;
  final String value;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? trend;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final String? tag;

  static List<Widget> _buildChildren(
    String label,
    String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Widget? prefix,
    Widget? suffix,
    Widget? trend,
  ) {
    final children = <Widget>[];

    // Label
    children.add(
      _StatisticSlot(
        type: _SlotType.label,
        child: ParagraphPrimitive(
          text: TextSpan(
            text: label,
            style:
                labelStyle ??
                const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ),
      ),
    );

    // Value
    children.add(
      _StatisticSlot(
        type: _SlotType.value,
        child: ParagraphPrimitive(
          text: TextSpan(
            text: value,
            style:
                valueStyle ??
                const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
          ),
        ),
      ),
    );

    if (prefix != null) {
      children.add(_StatisticSlot(type: _SlotType.prefix, child: prefix));
    }
    if (suffix != null) {
      children.add(_StatisticSlot(type: _SlotType.suffix, child: suffix));
    }
    if (trend != null) {
      children.add(_StatisticSlot(type: _SlotType.trend, child: trend));
    }
    return children;
  }

  @override
  RenderStatistic createRenderObject(BuildContext context) {
    return RenderStatistic();
  }

  @override
  void updateRenderObject(BuildContext context, RenderStatistic renderObject) {
    // No properties needed in RenderObject anymore as all state is in children
  }
}

enum _SlotType { label, value, prefix, suffix, trend }

class _StatisticParentData extends ContainerBoxParentData<RenderBox> {
  _SlotType? type;
}

class _StatisticSlot extends ParentDataWidget<_StatisticParentData> {
  const _StatisticSlot({required this.type, required super.child});

  final _SlotType type;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! _StatisticParentData) {
      renderObject.parentData = _StatisticParentData();
    }
    final pd = renderObject.parentData as _StatisticParentData;
    if (pd.type != type) {
      pd.type = type;
      final parent = renderObject.parent;
      if (parent is RenderObject) parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Statistic;
}

class RenderStatistic extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _StatisticParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _StatisticParentData> {
  RenderStatistic();

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _StatisticParentData) {
      child.parentData = _StatisticParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? label;
    RenderBox? value;
    RenderBox? prefix;
    RenderBox? suffix;
    RenderBox? trend;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _StatisticParentData;
      if (pd.type == _SlotType.label) label = child;
      if (pd.type == _SlotType.value) value = child;
      if (pd.type == _SlotType.prefix) prefix = child;
      if (pd.type == _SlotType.suffix) suffix = child;
      if (pd.type == _SlotType.trend) trend = child;
      child = childAfter(child);
    }

    double currentY = 0;

    // Layout Label
    if (label != null) {
      label.layout(
        BoxConstraints.loose(Size(constraints.maxWidth, double.infinity)),
        parentUsesSize: true,
      );
      final pd = label.parentData as _StatisticParentData;
      pd.offset = Offset(0, 0);
      currentY += label.size.height + 4;
    }

    // Layout Value row
    if (value != null) {
      value.layout(
        BoxConstraints.loose(Size(constraints.maxWidth, double.infinity)),
        parentUsesSize: true,
      );

      double rowHeight = value.size.height;
      if (prefix != null) {
        prefix.layout(
          BoxConstraints.loose(Size(constraints.maxWidth, double.infinity)),
          parentUsesSize: true,
        );
        rowHeight = rowHeight > prefix.size.height
            ? rowHeight
            : prefix.size.height;
      }
      if (suffix != null) {
        suffix.layout(
          BoxConstraints.loose(Size(constraints.maxWidth, double.infinity)),
          parentUsesSize: true,
        );
        rowHeight = rowHeight > suffix.size.height
            ? rowHeight
            : suffix.size.height;
      }

      double currentX = 0;
      if (prefix != null) {
        final pd = prefix.parentData as _StatisticParentData;
        pd.offset = Offset(
          currentX,
          currentY + (rowHeight - prefix.size.height) / 2,
        );
        currentX += prefix.size.width + 4;
      }

      final vpd = value.parentData as _StatisticParentData;
      vpd.offset = Offset(
        currentX,
        currentY + (rowHeight - value.size.height) / 2,
      );
      currentX += value.size.width + 4;

      if (suffix != null) {
        final pd = suffix.parentData as _StatisticParentData;
        pd.offset = Offset(
          currentX,
          currentY + (rowHeight - suffix.size.height) / 2,
        );
      }

      currentY += rowHeight;
    }

    // Layout Trend
    if (trend != null) {
      trend.layout(
        BoxConstraints.loose(Size(constraints.maxWidth, double.infinity)),
        parentUsesSize: true,
      );
      final pd = trend.parentData as _StatisticParentData;
      pd.offset = Offset(0, currentY + 4);
      currentY += 4 + trend.size.height;
    }

    size = constraints.constrain(Size(constraints.maxWidth, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
