import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/controls/specialty/form_schema.dart';
import 'package:blankcanvas/src/controls/inputs/text_field.dart' as bc;
import 'package:blankcanvas/src/layout/layout.dart' as layout;
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// A form builder using lowest-level RenderObject APIs.
class FormBuilder extends MultiChildRenderObjectWidget {
  FormBuilder({super.key, required this.schema, required this.onSubmit})
    : super(children: _buildChildren(schema));

  final FormSchema schema;
  final void Function(Map<String, dynamic>) onSubmit;

  static List<Widget> _buildChildren(FormSchema schema) {
    final children = <Widget>[];

    for (final field in schema.fields) {
      children.add(
        layout.Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: layout.Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParagraphPrimitive(
                text: TextSpan(
                  text: field.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
              const layout.SizedBox(height: 4),
              bc.TextField(placeholder: field.placeholder),
            ],
          ),
        ),
      );
    }

    // Submit button
    children.add(
      layout.Padding(
        padding: const EdgeInsets.only(top: 8),
        child: layout.Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ParagraphPrimitive(
            text: TextSpan(
              text: schema.submitLabel ?? 'Submit',
              style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
            ),
          ),
        ),
      ),
    );

    return children;
  }

  @override
  RenderFormBuilder createRenderObject(BuildContext context) {
    return RenderFormBuilder();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFormBuilder renderObject,
  ) {
    // Basic update
  }
}

class RenderFormBuilder extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  @override
  void performLayout() {
    double currentY = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final pd = child.parentData! as FlexParentData;
      pd.offset = Offset(0, currentY);
      currentY += child.size.height;
      child = pd.nextSibling;
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
