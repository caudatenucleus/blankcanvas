import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// This test ensures all blankcanvas widgets use the lowest-level Flutter APIs.
/// Widgets should extend RenderObjectWidget subclasses, NOT StatelessWidget/StatefulWidget.
void main() {
  group('Lowest-Level API Enforcement', () {
    late List<File> widgetFiles;

    setUpAll(() {
      final srcDir = Directory('lib/src');
      widgetFiles = srcDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.contains('lib/src/foundation'))
          .where((f) => !f.path.contains('lib/src/core'))
          .where((f) => !f.path.contains('.g.dart'))
          .toList();
    });

    test('No public widgets extend StatefulWidget/StatelessWidget', () {
      final violations = <String>[];

      for (final file in widgetFiles) {
        final content = file.readAsStringSync();
        final filename = file.path.split('lib/src/').last;

        final pattern = RegExp(
          r'class\s+([A-Z]\w+)\s+extends\s+(?:w\.)?(StatefulWidget|StatelessWidget)',
          multiLine: true,
        );

        final matches = pattern.allMatches(content);
        for (final match in matches) {
          final className = match.group(1);
          if (className != null && !className.startsWith('_')) {
            violations.add('$filename: $className extends ${match.group(2)}');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Public widgets must use RenderObjectWidget variants.\n'
            'Violations found:\n${violations.join('\n')}',
      );
    });

    test('Primary widgets use RenderObjectWidget or its subclasses', () {
      final allowedBases = [
        'RenderObjectWidget',
        'SingleChildRenderObjectWidget',
        'MultiChildRenderObjectWidget',
        'LeafRenderObjectWidget',
        'ParentDataWidget',
        'SliverMultiBoxAdaptorWidget',
        'ListWheelViewport',
        'Align', // Our own Align is allowed
      ];

      final violations = <String>[];

      for (final file in widgetFiles) {
        final content = file.readAsStringSync();
        final filename = file.path.split('lib/src/').last;

        if (!content.contains('class ')) continue;

        final classPattern = RegExp(
          r'class\s+([A-Z]\w+)\s+extends\s+(?:[\w\d]+\.)?(\w+)',
          multiLine: true,
        );

        final matches = classPattern.allMatches(content);
        for (final match in matches) {
          final className = match.group(1);
          final baseClass = match.group(2);

          if (className == null || baseClass == null) {
            continue;
          }
          if (className.startsWith('_') || className.startsWith('Render')) {
            continue;
          }
          if (className.endsWith('Data') ||
              className.endsWith('Context') ||
              className.endsWith('Registry')) {
            continue;
          }
          if (className.endsWith('Action') ||
              className.endsWith('Item') ||
              className.endsWith('Status')) {
            continue;
          }

          if (content.contains('createRenderObject') ||
              content.contains('extends SingleChildRenderObjectWidget') ||
              content.contains('extends MultiChildRenderObjectWidget') ||
              content.contains('extends LeafRenderObjectWidget') ||
              content.contains(
                'extends layout.SingleChildRenderObjectWidget',
              ) ||
              content.contains('extends layout.MultiChildRenderObjectWidget') ||
              content.contains('extends layout.LeafRenderObjectWidget')) {
            if (!allowedBases.contains(baseClass) &&
                !baseClass.startsWith('Render')) {
              violations.add('$filename: $className extends $baseClass');
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Widgets should extend RenderObjectWidget subclasses.\n'
            'Violations found:\n${violations.join('\n')}',
      );
    });

    test('No high-level widgets used in widget implementation', () {
      final bannedWidgets = [
        'Column',
        'Row',
        'Stack',
        'ListView',
        'GridView',
        'Wrap',
        'GestureDetector',
        'InkWell',
        'Scaffold',
        'AppBar',
        'Material',
        'Text',
        'RichText',
        'Icon',
        'Image',
        'Padding',
        'SizedBox',
        'Container',
        'Align',
        'Center',
        'Opacity',
        'AnimatedOpacity',
        'FadeTransition',
        'ScaleTransition',
        'SlideTransition',
        'RotationTransition',
        'SizeTransition',
      ];

      final violations = <String>[];

      for (final file in widgetFiles) {
        final path = file.path;
        // Skip layout files and display primitives
        if (path.contains('lib/src/layout/') ||
            path.contains('lib/src/rendering/')) {
          continue;
        }

        String content = file.readAsStringSync();
        final filename = file.path.split('lib/src/').last;

        // Strip comments to avoid false positives
        content = content.replaceAll(RegExp(r'//.*'), '');
        content = content.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

        for (final banned in bannedWidgets) {
          // Exceptions for self-definitions and internal usage
          if (filename.endsWith('transitions.dart') &&
              banned.endsWith('Transition')) {
            continue;
          }
          if (filename.endsWith('page_transition.dart') &&
              banned.endsWith('Transition')) {
            continue;
          }
          if (filename.endsWith('image_gallery.dart') && banned == 'Image') {
            continue;
          }

          // Look for widget instantiation: BannedWidget(
          // and exclude if it's layout or internal prefixed
          final regex = RegExp(r'(?<!layout\.|w\.|bc\.)\b' + banned + r'\(');
          if (content.contains(regex)) {
            violations.add('$filename: Uses high-level widget $banned');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Internal library logic should favor RenderObjects or raw primitives.\n'
            'Violations found:\n${violations.join('\n')}',
      );
    });

    test('No Material or Cupertino imports', () {
      final bannedImports = [
        "import 'package:flutter/material.dart'",
        "import 'package:flutter/cupertino.dart'",
      ];

      final violations = <String>[];

      for (final file in widgetFiles) {
        final content = file.readAsStringSync();
        final filename = file.path.split('lib/src/').last;

        for (final banned in bannedImports) {
          if (content.contains(banned)) {
            violations.add('$filename: Uses banned import: $banned');
          }
        }
      }

      expect(violations, isEmpty);
    });
  });
}
