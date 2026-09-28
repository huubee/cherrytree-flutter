import 'package:cherrytree_flutter/l10n/app_localizations.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:cherrytree_flutter/widgets/bookmarks_dialog.dart';
import 'package:cherrytree_flutter/widgets/find_in_nodes_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Size size = const Size(1000, 800)}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
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
  group('FindInNodesDialog', () {
    late NoteDocument doc;

    setUp(() {
      doc = NoteDocument(
        nodes: [
          NoteNode(
            id: '1',
            parentId: null,
            title: 'Flutter Architecture',
            body: 'Clean architecture and state management with Flutter.',
            sortIndex: 0,
            tags: 'flutter dart architecture',
          ),
          NoteNode(
            id: '2',
            parentId: '1',
            title: 'Riverpod Provider Guide',
            body: 'Dependency injection and reactive state.',
            sortIndex: 0,
            tags: 'state',
          ),
        ],
      );
    });

    testWidgets('searches notes and navigates on result selection', (tester) async {
      String? selectedId;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                FindInNodesDialog.show(
                  ctx,
                  doc: doc,
                  onSelectNode: (id) => selectedId = id,
                );
              },
              child: const Text('Open Search'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      expect(find.text('Find in Nodes'), findsOneWidget);
      expect(find.text('Type to search notes in this document'), findsOneWidget);

      // Enter query 'Riverpod'
      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'Riverpod');
      await tester.pumpAndSettle();

      // Results should show 1 matching node
      expect(find.text('Riverpod Provider Guide'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);

      // Tap on the result
      await tester.tap(find.text('Riverpod Provider Guide'));
      await tester.pumpAndSettle();

      expect(selectedId, '2');
      // Dialog should be dismissed
      expect(find.text('Find in Nodes'), findsNothing);
    });

    testWidgets('updates results when filter chips are toggled', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                FindInNodesDialog.show(
                  ctx,
                  doc: doc,
                  onSelectNode: (_) {},
                );
              },
              child: const Text('Open Search'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      // Enter query 'state'
      await tester.enterText(find.byType(TextField), 'state');
      await tester.pumpAndSettle();

      // Both notes contain 'state' (note 1 in body, note 2 in tags and body)
      expect(find.text('Flutter Architecture'), findsOneWidget);
      expect(find.text('Riverpod Provider Guide'), findsOneWidget);

      // Disable 'Content' search chip
      final contentChip = find.widgetWithText(FilterChip, 'Content');
      await tester.ensureVisible(contentChip);
      await tester.tap(contentChip);
      await tester.pumpAndSettle();

      // Now only note 2 matches because only note 2 has 'state' in tags
      expect(find.text('Flutter Architecture'), findsNothing);
      expect(find.text('Riverpod Provider Guide'), findsOneWidget);
    });
  });

  group('BookmarksDialog', () {
    testWidgets('displays bookmarked nodes and supports navigation and removal', (tester) async {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: '1',
            parentId: null,
            title: 'Important Note',
            body: '',
            sortIndex: 0,
          ),
          NoteNode(
            id: '2',
            parentId: null,
            title: 'Second Bookmark',
            body: '',
            sortIndex: 1,
          ),
        ],
        bookmarks: ['1', '2'],
      );

      String? selectedId;
      String? removedId;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                BookmarksDialog.show(
                  ctx,
                  doc: doc,
                  onSelectNode: (id) => selectedId = id,
                  onRemoveBookmark: (id) => removedId = id,
                );
              },
              child: const Text('Open Bookmarks'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Bookmarks'));
      await tester.pumpAndSettle();

      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // badge count
      expect(find.text('Important Note'), findsOneWidget);
      expect(find.text('Second Bookmark'), findsOneWidget);

      // Tap remove on first bookmark
      final removeButtons = find.byIcon(Icons.bookmark_remove_outlined);
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();
      expect(removedId, '1');

      // Tap on second bookmark to select
      await tester.tap(find.text('Second Bookmark'));
      await tester.pumpAndSettle();
      expect(selectedId, '2');

      // Dialog dismissed
      expect(find.text('Bookmarks'), findsNothing);
    });

    testWidgets('shows empty state when no bookmarks exist', (tester) async {
      final doc = NoteDocument(nodes: []);

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                BookmarksDialog.show(
                  ctx,
                  doc: doc,
                  onSelectNode: (_) {},
                  onRemoveBookmark: (_) {},
                );
              },
              child: const Text('Open Bookmarks'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Bookmarks'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.textContaining('No bookmarks yet'), findsOneWidget);
    });
  });
}
