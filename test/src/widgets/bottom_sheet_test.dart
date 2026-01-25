import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('BottomSheet shows content', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Navigator(
          onGenerateRoute: (settings) {
            return w.PageRouteBuilder(
              pageBuilder: (context, _, __) => w.Center(
                child: w.GestureDetector(
                  onTap: () {
                    BottomSheet.show(
                      context: context,
                      builder: (c) => const w.Text('Sheet Content'),
                    );
                  },
                  child: const w.Text('Show'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // w.Animation

    expect(find.text('Sheet Content'), findsOneWidget);
  });
}
