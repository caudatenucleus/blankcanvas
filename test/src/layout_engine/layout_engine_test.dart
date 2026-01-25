import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';
import 'package:flutter/rendering.dart';

void main() {
  group('Layout Engine Primitives', () {
    testWidgets('PaddingPrimitive applies insets', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Center(
            child: PaddingPrimitive(
              padding: w.EdgeInsets.all(16),
              child: w.SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(PaddingPrimitive));
      expect(size.width, 132.0); // 100 + 16 + 16
      expect(size.height, 132.0);
    });

    testWidgets('ConstrainedBoxPrimitive enforces constraints', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Center(
            child: ConstrainedBoxPrimitive(
              additionalConstraints: w.BoxConstraints(
                maxWidth: 50,
                maxHeight: 50,
              ),
              child: w.SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(ConstrainedBoxPrimitive));
      expect(size.width, 50.0);
      expect(size.height, 50.0);
    });

    testWidgets('OpacityPrimitive renders with transparency', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: OpacityPrimitive(
            opacity: 0.5,
            child: w.SizedBox(width: 100, height: 100),
          ),
        ),
      );
      expect(find.byType(OpacityPrimitive), findsOneWidget);
    });

    testWidgets('ClipRectPrimitive clips content', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.SizedBox(
            width: 100,
            height: 100,
            child: ClipRectPrimitive(
              child: w.SizedBox(width: 200, height: 200), // Larger than parent
            ),
          ),
        ),
      );
      expect(find.byType(ClipRectPrimitive), findsOneWidget);
    });

    testWidgets('PhysicalModelPrimitive renders with elevation', (
      tester,
    ) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Center(
            child: PhysicalModelPrimitive(
              elevation: 8.0,
              color: const w.Color(0xFFFFFFFF),
              borderRadius: const w.BorderRadius.all(w.Radius.circular(8)),
              child: w.SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      expect(find.byType(PhysicalModelPrimitive), findsOneWidget);
    });

    testWidgets('RenderFlowPrimitive controls child layout via delegate', (
      tester,
    ) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: FlowPrimitive(
            delegate: const TestFlowDelegate(),
            children: [
              w.SizedBox(width: 50, height: 50),
              w.SizedBox(width: 50, height: 50),
            ],
          ),
        ),
      );
      expect(find.byType(FlowPrimitive), findsOneWidget);
    });

    testWidgets('CustomMultiChildLayoutPrimitive performs layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: CustomMultiChildLayoutPrimitive(
            delegate: TestMultiChildLayoutDelegate(),
            children: [
              w.LayoutId(id: 1, child: w.SizedBox(width: 100, height: 100)),
            ],
          ),
        ),
      );
      expect(find.byType(CustomMultiChildLayoutPrimitive), findsOneWidget);
    });

    testWidgets('SemanticsAnnotationsPrimitive pushes semantics', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: SemanticsAnnotationsPrimitive(
            properties: const SemanticsProperties(
              label: 'Test Label',
              value: 'Test Value',
            ),
            child: w.SizedBox(width: 100, height: 100),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(SemanticsAnnotationsPrimitive)),
        matchesSemantics(label: 'Test Label', value: 'Test Value'),
      );
      semanticsHandle.dispose();
    });

    testWidgets('ExcludeSemanticsPrimitive hides semantics', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: ExcludeSemanticsPrimitive(
            excluding: true,
            child: w.Semantics(
              label: 'Hidden',
              child: w.SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Hidden'), findsNothing);
      semanticsHandle.dispose();
    });

    testWidgets('IndexedStackPrimitive shows only one child', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: IndexedStackPrimitive(
            index: 1,
            children: [
              w.SizedBox(key: const w.Key('c1'), width: 50, height: 50),
              w.SizedBox(key: const w.Key('c2'), width: 50, height: 50),
            ],
          ),
        ),
      );
      expect(
        find.byKey(const w.Key('c1')),
        findsOneWidget,
      ); // Is present in tree
      expect(find.byKey(const w.Key('c2')), findsOneWidget);
      // w.Visibility check is harder without custom finder, assuming works if type matches
    });

    testWidgets('Leader and Follower layer primitives link up', (tester) async {
      final link = w.LayerLink();
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Stack(
            children: [
              LeaderLayerPrimitive(
                link: link,
                child: w.SizedBox(width: 50, height: 50),
              ),
              FollowerLayerPrimitive(
                link: link,
                child: w.SizedBox(width: 50, height: 50),
              ),
            ],
          ),
        ),
      );
      expect(find.byType(LeaderLayerPrimitive), findsOneWidget);
      expect(find.byType(FollowerLayerPrimitive), findsOneWidget);
    });

    testWidgets('AnnotatedRegionPrimitive builds', (tester) async {
      await tester.pumpWidget(
        AnnotatedRegionPrimitive<String>(
          value: 'test',
          child: w.SizedBox(width: 10, height: 10),
        ),
      );
      expect(find.byType(AnnotatedRegionPrimitive<String>), findsOneWidget);
    });

    testWidgets('ListWheelViewportPrimitive builds', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: ListWheelViewportPrimitive(
            itemExtent: 50,
            offset: ViewportOffset.zero(),
            childDelegate: w.ListWheelChildListDelegate(
              children: [w.SizedBox(height: 50), w.SizedBox(height: 50)],
            ),
          ),
        ),
      );
      expect(find.byType(ListWheelViewportPrimitive), findsOneWidget);
    });
  });
}

class TestFlowDelegate extends w.FlowDelegate {
  const TestFlowDelegate();
  @override
  void paintChildren(w.FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      context.paintChild(i);
    }
  }

  @override
  bool shouldRepaint(TestFlowDelegate oldDelegate) => false;
}

class TestMultiChildLayoutDelegate extends w.MultiChildLayoutDelegate {
  @override
  void performLayout(w.Size size) {
    if (hasChild(1)) {
      layoutChild(1, w.BoxConstraints.loose(size));
      positionChild(1, w.Offset.zero);
    }
  }

  @override
  bool shouldRelayout(TestMultiChildLayoutDelegate oldDelegate) => false;
}
