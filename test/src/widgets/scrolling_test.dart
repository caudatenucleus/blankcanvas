import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('InfiniteScroll renders items', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: InfiniteScroll(
          itemCount: 2,
          hasMore: true,
          onLoadMore: () async {},
        ),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
  });

  testWidgets('VirtualList renders items', (WidgetTester tester) async {
    final items = List.generate(20, (i) => 'Item $i');

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: VirtualList<String>(
          items: items,
          itemBuilder: (context, item, index) => w.Text(item),
        ),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
  });

  testWidgets('LazyLoad shows placeholder initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.ListView(children: [LazyLoad(child: const w.Text('Content'))]),
      ),
    );

    // After first frame callback, should be visible since it's at top
    await tester.pump();
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('PullToRefresh renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: PullToRefresh(
          onRefresh: () async {},
          child: const w.Text('Content'),
        ),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
  });
}
