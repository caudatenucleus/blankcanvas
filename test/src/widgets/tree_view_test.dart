import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('TreeView renders and expands nodes', (
    WidgetTester tester,
  ) async {
    final root = TreeNode<String>(
      data: 'Root',
      children: [
        TreeNode<String>(data: 'Child 1'),
        TreeNode<String>(data: 'Child 2'),
      ],
      isExpanded: false,
    );

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: CustomizedTheme(
          data: const ControlCustomizations(),
          child: w.StatefulBuilder(
            builder: (context, setState) {
              return w.Center(
                child: w.SizedBox(
                  width: 300,
                  height: 400,
                  child: TreeView<String>(
                    nodes: [root],
                    nodeBuilder: (context, data) => w.Text(data),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Root'), findsOneWidget);
    expect(find.text('Child 1'), findsNothing);

    // Tap toggle.
    // We look for TreeItemWidget.
    // But since nodeBuilder returns w.Text, we can locate 'Root' w.Text widget.
    // The TreeItemWidget is its ancestor.
    final rootTextFinder = find.text('Root');
    final treeItemFinder = find.ancestor(
      of: rootTextFinder,
      matching: find.byType(TreeItemWidget<String>),
    );

    final renderItem = tester.renderObject(treeItemFinder) as w.RenderBox;
    final itemLoc = renderItem.localToGlobal(w.Offset.zero);

    // Tap expanded icon. w.Icon is to left of content.
    // Indent 20. w.Padding left 8 default (from customization.dart or defaults in code).
    // _ToggleIconWidget is 16x16.
    // Its center is roughly at (8 + 16/2).
    // Tap at local (16, 12).
    await tester.tapAt(itemLoc + const w.Offset(16, 12));
    await tester.pump();

    // Check expanded
    expect(find.text('Child 1'), findsOneWidget);
    expect(find.text('Child 2'), findsOneWidget);

    // Tap Child 1.
    await tester.tap(find.text('Child 1'));
  });
}
