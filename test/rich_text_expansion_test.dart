import 'package:cherrytree_flutter/l10n/app_localizations.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:cherrytree_flutter/widgets/node_editor.dart';
import 'package:cherrytree_flutter/widgets/special_characters_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_quill/flutter_quill.dart';

Widget _wrap(Widget child, {Size size = const Size(1200, 900)}) {
  return MaterialApp(
    localizationsDelegates: const [
      ...AppLocalizations.localizationsDelegates,
      FlutterQuillLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: child,
      ),
    ),
  );
}

void main() {
  group('SpecialCharactersDialog', () {
    testWidgets('renders all default upstream characters and selects a symbol',
        (tester) async {
      String? selectedChar;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                SpecialCharactersDialog.show(
                  ctx,
                  onSelectCharacter: (char) {
                    selectedChar = char;
                  },
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check header and dialog presence
      expect(find.byType(SpecialCharactersDialog), findsOneWidget);
      expect(find.text('Special Characters'), findsOneWidget);

      // Verify specific upstream glyphs are rendered
      expect(find.text('★'), findsOneWidget);
      expect(find.text('©'), findsOneWidget);
      expect(find.text('✔'), findsOneWidget);
      expect(find.text('∞'), findsOneWidget);

      // Tap on a character
      await tester.tap(find.text('★'));
      await tester.pumpAndSettle();

      // Dialog is dismissed and callback is invoked
      expect(find.byType(SpecialCharactersDialog), findsNothing);
      expect(selectedChar, '★');
    });

    testWidgets('closes on close button press', (tester) async {
      String? selectedChar;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                SpecialCharactersDialog.show(
                  ctx,
                  onSelectCharacter: (char) => selectedChar = char,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(SpecialCharactersDialog), findsOneWidget);

      // Tap close button (top right)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(SpecialCharactersDialog), findsNothing);
      expect(selectedChar, isNull);
    });
  });

  group('NodeEditor Rich Text Expansion', () {
    testWidgets('renders rich text toolbar with custom actions for editable note',
        (tester) async {
      tester.view.physicalSize = const Size(2200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final node = NoteNode(
        id: '1',
        parentId: null,
        title: 'Phase 4 Note',
        body: 'Hello World',
        sortIndex: 0,
      );

      await tester.pumpWidget(
        _wrap(
          NodeEditor(
            node: node,
            onChanged: () {},
          ),
          size: const Size(2200, 1200),
        ),
      );
      await tester.pumpAndSettle();

      // Custom buttons for Timestamp, Horizontal Rule, and Special Characters should be present
      expect(find.byIcon(Icons.access_time_outlined), findsOneWidget);
      expect(find.byIcon(Icons.horizontal_rule_outlined), findsOneWidget);
      expect(find.byIcon(Icons.emoji_symbols_outlined), findsOneWidget);
    });

    testWidgets('inserts timestamp YYYY/MM/DD - HH:mm into node body',
        (tester) async {
      tester.view.physicalSize = const Size(2200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final node = NoteNode(
        id: '1',
        parentId: null,
        title: 'Timestamp Note',
        body: '',
        sortIndex: 0,
      );

      var changedCount = 0;

      await tester.pumpWidget(
        _wrap(
          NodeEditor(
            node: node,
            onChanged: () => changedCount++,
          ),
          size: const Size(2200, 1200),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure button is visible and tap
      final button = find.byIcon(Icons.access_time_outlined);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(changedCount, greaterThanOrEqualTo(1));

      // The body should now contain a date string like 2026/09/28 - HH:mm
      final now = DateTime.now();
      final yearPrefix = '${now.year}/';
      expect(node.body.contains(yearPrefix), isTrue);
      // Regex check for upstream CherryTree timestamp pattern
      final timestampPattern = RegExp(r'\d{4}/\d{2}/\d{2} - \d{2}:\d{2}');
      expect(timestampPattern.hasMatch(node.body), isTrue);
    });

    testWidgets('inserts horizontal rule ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ into node body',
        (tester) async {
      tester.view.physicalSize = const Size(2200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final node = NoteNode(
        id: '1',
        parentId: null,
        title: 'Rule Note',
        body: 'Intro text',
        sortIndex: 0,
      );

      var changed = false;

      await tester.pumpWidget(
        _wrap(
          NodeEditor(
            node: node,
            onChanged: () => changed = true,
          ),
          size: const Size(2200, 1200),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure button is visible and tap
      final button = find.byIcon(Icons.horizontal_rule_outlined);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(changed, isTrue);
      expect(node.body.contains('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'), isTrue);
    });

    testWidgets('inserts special character through dialog into note body',
        (tester) async {
      tester.view.physicalSize = const Size(2200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final node = NoteNode(
        id: '1',
        parentId: null,
        title: 'Special Char Note',
        body: '',
        sortIndex: 0,
      );

      var changed = false;

      await tester.pumpWidget(
        _wrap(
          NodeEditor(
            node: node,
            onChanged: () => changed = true,
          ),
          size: const Size(2200, 1200),
        ),
      );
      await tester.pumpAndSettle();

      // Tap special characters button to open dialog
      final button = find.byIcon(Icons.emoji_symbols_outlined);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.byType(SpecialCharactersDialog), findsOneWidget);

      // Tap '✔'
      await tester.tap(find.text('✔'));
      await tester.pumpAndSettle();

      // Dialog closes and body contains the character
      expect(find.byType(SpecialCharactersDialog), findsNothing);
      expect(changed, isTrue);
      expect(node.body.contains('✔'), isTrue);
    });
  });
}
