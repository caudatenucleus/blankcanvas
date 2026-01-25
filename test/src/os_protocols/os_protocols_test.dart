import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/src/os_protocols/x11_atoms.dart';
import 'package:blankcanvas/src/os_protocols/wayland_atoms.dart';
import 'package:blankcanvas/src/os_protocols/windowing_atoms.dart';

void main() {
  group('X11 Atoms', () {
    test('X11AtomRegistry interns and retrieves atoms', () {
      final registry = X11AtomRegistry.instance;
      final id1 = registry.internAtom('WM_PROTOCOLS');
      final id2 = registry.internAtom('WM_DELETE_WINDOW');
      final id3 = registry.internAtom('WM_PROTOCOLS');

      expect(id1, isPositive);
      expect(id2, isNotNull);
      expect(id1, equals(id3));
      expect(id1, isNot(equals(id2)));
      expect(registry.getAtomName(id1), 'WM_PROTOCOLS');
    });

    testWidgets('X11EventCapture captures pointer events', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Center(
            child: X11EventCapture(
              onEvent: (e) => events.add(e),
              child: w.ColoredBox(
                color: const w.Color(0xFF00FF00),
                child: const w.SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(w.SizedBox), warnIfMissed: false);
      expect(events, anyElement(contains('ButtonPress')));
      expect(events, anyElement(contains('ButtonRelease')));
    });
  });

  group('Wayland Atoms', () {
    test('WaylandSurfaceDamage holds rect', () {
      const damage = WaylandSurfaceDamage(w.Rect.fromLTWH(0, 0, 10, 10));
      expect(damage.rect.width, 10);
    });

    testWidgets('WaylandPointerConstraint renders', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Center(
            child: WaylandPointerConstraint(
              locked: true,
              confinedRegion: const w.Rect.fromLTWH(0, 0, 100, 100),
              child: const w.SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(WaylandPointerConstraint)),
        const w.Size(50, 50),
      );
    });
  });

  group('Windowing Atoms', () {
    test('WindowZOrderManager manages stack', () {
      final manager = WindowZOrderManager();
      manager.raise(1);
      manager.raise(2);
      expect(manager.snapshot, [1, 2]);

      manager.lower(2);
      expect(manager.snapshot, [2, 1]); // Lower 2 to bottom

      manager.raise(2);
      expect(manager.snapshot, [1, 2]); // Raise 2 to top
    });

    testWidgets('WindowTransparencyMask paints child', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Center(
            child: WindowTransparencyMask(
              transparent: true,
              child: const w.Text('Masked'),
            ),
          ),
        ),
      );
      expect(find.text('Masked'), findsOneWidget);
    });

    testWidgets('InputEventRoutingNode hit tests', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Center(
            child: InputEventRoutingNode(
              windowId: 99,
              child: w.ColoredBox(
                color: const w.Color(0xFF0000FF),
                child: const w.SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(w.SizedBox), warnIfMissed: false);
    });
  });
}
