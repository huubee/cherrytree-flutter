import 'package:cherrytree_flutter/l10n/app_localizations.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:cherrytree_flutter/widgets/node_editor.dart';
import 'package:cherrytree_flutter/widgets/node_properties_dialog.dart';
import 'package:cherrytree_flutter/widgets/tree_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {double width = 360}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SizedBox(width: width, child: child)),
  );
}

void main() {
  group('TreePanel widget', () {
    testWidgets('renders node title and responds to select', (tester) async {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'Note 1', body: '', sortIndex: 0),
          NoteNode(id: '2', parentId: null, title: 'Note 2', body: '', sortIndex: 1),
        ],
      );

      String? selected;
      await tester.pumpWidget(
        _wrap(
          TreePanel(
            doc: doc,
            selectedId: '1',
            onSelect: (id) => selected = id,
            onAddChild: (_) {},
            onDelete: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Note 1'), findsOneWidget);
      expect(find.text('Note 2'), findsOneWidget);

      await tester.tap(find.text('Note 2'));
      await tester.pumpAndSettle();

      expect(selected, '2');
    });

    testWidgets('shows bookmark badge and lock icon on nodes', (tester) async {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: '1',
            parentId: null,
            title: 'Bookmarked and Locked',
            body: '',
            sortIndex: 0,
            isReadOnly: true,
          ),
        ],
        bookmarks: ['1'],
      );

      await tester.pumpWidget(
        _wrap(
          TreePanel(
            doc: doc,
            selectedId: '1',
            onSelect: (_) {},
            onAddChild: (_) {},
            onDelete: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('expand all and collapse all buttons toggle subtree visibility', (tester) async {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: 'root', parentId: null, title: 'Root Node', body: '', sortIndex: 0),
          NoteNode(id: 'child', parentId: 'root', title: 'Child Node', body: '', sortIndex: 0),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          TreePanel(
            doc: doc,
            selectedId: 'root',
            onSelect: (_) {},
            onAddChild: (_) {},
            onDelete: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // By default all parents are expanded
      expect(find.text('Child Node'), findsOneWidget);

      // Tap Collapse all
      await tester.tap(find.byIcon(Icons.unfold_less));
      await tester.pumpAndSettle();

      // Child node should now be hidden
      expect(find.text('Child Node'), findsNothing);

      // Tap Expand all
      await tester.tap(find.byIcon(Icons.unfold_more));
      await tester.pumpAndSettle();

      // Child node should reappear
      expect(find.text('Child Node'), findsOneWidget);
    });

    testWidgets('triggers popup actions: move up, down, bookmark, properties', (tester) async {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'Node A', body: '', sortIndex: 0),
        ],
      );

      String? movedUpId;
      String? toggledBmId;
      String? propsId;

      await tester.pumpWidget(
        _wrap(
          TreePanel(
            doc: doc,
            selectedId: '1',
            onSelect: (_) {},
            onAddChild: (_) {},
            onDelete: (_) {},
            onMoveUp: (id) => movedUpId = id,
            onToggleBookmark: (id) => toggledBmId = id,
            onNodeProperties: (id) => propsId = id,
          ),
          width: 320,
        ),
      );
      await tester.pumpAndSettle();

      // Tap the node popup menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap "Move up"
      await tester.tap(find.text('Move up'));
      await tester.pumpAndSettle();
      expect(movedUpId, '1');

      // Re-open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap "Toggle bookmark"
      await tester.tap(find.text('Toggle bookmark'));
      await tester.pumpAndSettle();
      expect(toggledBmId, '1');

      // Re-open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap "Node properties"
      await tester.tap(find.text('Node properties'));
      await tester.pumpAndSettle();
      expect(propsId, '1');
    });
  });

  group('NodeEditor read-only', () {
    testWidgets('locks editing and hides quill toolbar when isReadOnly is true', (tester) async {
      final node = NoteNode(
        id: '1',
        parentId: null,
        title: 'Locked Note',
        body: '',
        sortIndex: 0,
        isReadOnly: true,
      );

      await tester.pumpWidget(
        _wrap(
          NodeEditor(
            node: node,
            onChanged: () {},
          ),
          width: 600,
        ),
      );
      await tester.pumpAndSettle();

      // Title field is read-only with lock icon
      final titleField = tester.widget<TextField>(find.byType(TextField));
      expect(titleField.readOnly, isTrue);

      // Toolbar is omitted
      expect(find.byType(IconButton), findsNothing);
    });
  });

  group('NodePropertiesDialog', () {
    testWidgets('updates node properties and returns true on Save', (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final node = NoteNode(
        id: '1',
        parentId: null,
        title: 'Original Title',
        body: '',
        sortIndex: 0,
        isBold: false,
        tags: 'work',
      );

      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  result = await NodePropertiesDialog.show(ctx, node: node);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Node Properties'), findsOneWidget);

      // Enter new title
      final titleInput = find.byType(TextField).first;
      await tester.enterText(titleInput, 'Renamed Note');
      // Toggle bold
      await tester.tap(find.text('Bold node name in tree'));
      // Toggle read-only
      final roTile = find.text('Read Only (protect against editing)');
      await tester.ensureVisible(roTile);
      await tester.tap(roTile);
      await tester.pumpAndSettle();

      // Tap Save
      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(node.title, 'Renamed Note');
      expect(node.isBold, isTrue);
      expect(node.isReadOnly, isTrue);
    });
  });
}
