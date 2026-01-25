import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/blankcanvas.dart';

// Helper to pump a primitive
Future<void> pumpPrimitive(WidgetTester tester, w.Widget widget) async {
  await tester.pumpWidget(
    w.Directionality(textDirection: w.TextDirection.ltr, child: widget),
  );
}

void main() {
  testWidgets('Layout primitives create correct RenderObjects', (
    WidgetTester tester,
  ) async {
    await pumpPrimitive(tester, w.Row(children: []));
    expect(find.byType(w.Row), findsOneWidget);
    expect(tester.renderObject(find.byType(w.Row)), isA<RenderFlex>());

    await pumpPrimitive(tester, w.Column(children: []));
    expect(tester.renderObject(find.byType(w.Column)), isA<RenderFlex>());

    await pumpPrimitive(tester, w.Stack(children: []));
    expect(tester.renderObject(find.byType(w.Stack)), isA<RenderStack>());
  });

  testWidgets('w.Viewport primitives function correctly', (
    WidgetTester tester,
  ) async {
    // w.CustomScrollView requires a w.Directionality which we provided in helper
    // It also constructs a w.Viewport
    await pumpPrimitive(
      tester,
      w.CustomScrollView(
        slivers: [
          w.SliverToBoxAdapter(child: w.SizedBox(width: 100, height: 100)),
        ],
      ),
    );

    expect(find.byType(w.Viewport), findsOneWidget);
    expect(tester.renderObject(find.byType(w.Viewport)), isA<RenderViewport>());
  });

  testWidgets('SliverVisibility works with maintainState=false (default)', (
    WidgetTester tester,
  ) async {
    await pumpPrimitive(
      tester,
      w.CustomScrollView(
        slivers: [
          SliverVisibilityPrimitive(
            visible: false,
            child: w.SliverToBoxAdapter(
              child: w.SizedBox(width: 100, height: 100),
            ),
          ),
        ],
      ),
    );

    expect(find.byType(w.SliverToBoxAdapter), findsNothing);
  });

  testWidgets('Interaction primitives create RenderObjects', (
    WidgetTester tester,
  ) async {
    await pumpPrimitive(
      tester,
      w.Semantics(label: 'Test', child: const w.SizedBox()),
    );
    expect(
      tester.renderObject(find.byType(w.Semantics)),
      isA<RenderSemanticsAnnotations>(),
    );

    await pumpPrimitive(tester, w.IgnorePointer(child: const w.SizedBox()));
    expect(
      tester.renderObject(find.byType(w.IgnorePointer)),
      isA<RenderIgnorePointer>(),
    );
  });
}
