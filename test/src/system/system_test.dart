import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/src/system/design_system.dart';
import 'package:blankcanvas/src/system/input_system.dart';
import 'package:blankcanvas/src/system/system_state.dart';
import 'package:blankcanvas/src/system/colors.dart';
import 'package:blankcanvas/src/system/spacing.dart';
import 'package:blankcanvas/src/system/typography.dart';

// Helper Command
class MockCommand implements Command {
  MockCommand(this.onExecute, this.onUndo);
  final w.VoidCallback onExecute;
  final w.VoidCallback onUndo;

  @override
  String get name => 'MockCommand';

  @override
  void execute() => onExecute();

  @override
  void undo() => onUndo();
}

void main() {
  group('DesignSystem', () {
    testWidgets('DesignSystemProvider provides tokens', (tester) async {
      final data = DesignSystemData(tokens: {'color.primary': 0xFF00FF00});
      await tester.pumpWidget(
        DesignSystemProvider(
          data: data,
          child: w.Builder(
            builder: (context) {
              final val = DesignSystemProvider.of(
                context,
              ).resolve<int>('color.primary', context, defaultValue: 0);
              return w.Text('w.Color: $val', textDirection: w.TextDirection.ltr);
            },
          ),
        ),
      );
      expect(
        find.text('w.Color: 4278255360'),
        findsOneWidget,
      ); // 0xFF00FF00 as int
    });

    testWidgets('StaticThemeVariable resolves correctly', (tester) async {
      const v = StaticThemeVariable(10.0);
      await tester.pumpWidget(
        w.Builder(
          builder: (context) {
            expect(v.resolve(context), 10.0);
            return w.Container();
          },
        ),
      );
    });
  });

  group('InputSystem', () {
    test('ActionRegistry invokes callbacks', () {
      bool called = false;
      ActionRegistry.instance.register('test.action', (context, args) {
        called = true;
      });
      // Logic for unit test without context requires mocking, handled in testWidgets below.
      // Just ensure register works.
      ActionRegistry.instance.unregister('test.action');
      expect(called, isFalse); // Not called yet.
    });

    testWidgets('ActionRegistry integration', (tester) async {
      bool called = false;
      ActionRegistry.instance.register('test.action', (context, args) {
        called = true;
      });

      await tester.pumpWidget(
        w.Builder(
          builder: (context) {
            ActionRegistry.instance.invoke(context, 'test.action');
            return w.Container();
          },
        ),
      );

      expect(called, isTrue);
    });
  });

  group('SystemState', () {
    test('UndoRedoManager manages stack', () {
      final manager = UndoRedoManager();
      int value = 0;
      final command = MockCommand(() => value = 1, () => value = 0);

      // Execute
      manager.execute(command);
      expect(value, 1);
      expect(manager.canUndo, isTrue);

      // Undo
      manager.undo();
      expect(value, 0);
      expect(manager.canRedo, isTrue);

      // Redo
      manager.redo();
      expect(value, 1);
    });
  });

  group('SystemPrimitives', () {
    test('HSLColorProvider lightens color', () {
      const red = w.Color(0xFFFF0000); // HSL(0, 1.0, 0.5)
      final lighter = HSLColorProvider.lighten(red, 0.1);
      final hsl = HSLColorProvider.toHSL(lighter);
      expect(hsl.lightness, closeTo(0.6, 0.01));
    });

    test('DynamicSpacing scales values', () {
      const spacing = DynamicSpacing(scale: 2.0);
      expect(spacing.s, 16.0); // 8.0 * 2.0
    });

    testWidgets('FluidTypography scales with viewport', (tester) async {
      await tester.pumpWidget(
        w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: w.Builder(
            builder: (context) {
              // Default test viewport is 800x600
              // Fluid: min 320, max 1440. t = (800-320)/(1440-320) = 480/1120 = ~0.428
              // scale: 1.2
              // factor = 1.0 + 0.2 * 0.428 = 1.085
              // base 14 * 1.085 = 15.19
              final size = const FluidTypography().calculate(context);
              return w.Text('w.Size: ${size.toStringAsFixed(1)}');
            },
          ),
        ),
      );
      expect(find.text('w.Size: 15.2'), findsOneWidget);
    });

    testWidgets('AutoContrastLabel picks black on light', (tester) async {
      await tester.pumpWidget(
        const w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: AutoContrastLabel(
            text: 'Contrast',
            backgroundColor: w.Color(0xFFFFFFFF), // White
          ),
        ),
      );
      final text = tester.widget<w.Text>(find.byType(w.Text));
      expect(text.style?.color, const w.Color(0xFF000000));
    });

    testWidgets('AutoContrastLabel picks white on dark', (tester) async {
      await tester.pumpWidget(
        const w.Directionality(
          textDirection: w.TextDirection.ltr,
          child: AutoContrastLabel(
            text: 'Contrast',
            backgroundColor: w.Color(0xFF000000), // Black
          ),
        ),
      );
      final text = tester.widget<w.Text>(find.byType(w.Text));
      expect(text.style?.color, const w.Color(0xFFFFFFFF));
    });
  });
}
