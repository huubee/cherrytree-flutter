import 'package:cherrytree_flutter/l10n/app_localizations.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:cherrytree_flutter/widgets/draggable_split_view.dart';
import 'package:cherrytree_flutter/widgets/tree_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraggableSplitView and TreePanel mobile responsiveness', () {
    testWidgets('DraggableSplitView renders both children when height is ample', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var ratio = 0.33;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraggableSplitView(
              axis: Axis.vertical,
              ratio: ratio,
              onRatioChanged: (r) => ratio = r,
              firstChild: const Text('TopPane'),
              secondChild: const Text('BottomPane'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TopPane'), findsOneWidget);
      expect(find.text('BottomPane'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('DraggableSplitView hides firstChild when height is constrained (keyboard open)', (tester) async {
      // Simulating soft keyboard opening on mobile portrait (body height drops to 200px)
      await tester.binding.setSurfaceSize(const Size(400, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraggableSplitView(
              axis: Axis.vertical,
              ratio: 0.33,
              onRatioChanged: (_) {},
              firstChild: const Text('TopPane'),
              secondChild: const Text('BottomPane'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top pane is hidden so bottom pane (editor) can use the entire available space
      expect(find.text('TopPane'), findsNothing);
      expect(find.text('BottomPane'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TreePanel does not overflow when constrained to small height (< 56px)', (tester) async {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'Note 1', body: '', sortIndex: 0),
        ],
      );

      // Force TreePanel into a tight 35px height box (which originally caused the 13px overflow)
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 35,
              child: TreePanel(
                doc: doc,
                selectedId: doc.nodes.first.id,
                onSelect: (_) {},
                onAddChild: (_) {},
                onDelete: (_) {},
                onMoveUp: (_) {},
                onMoveDown: (_) {},
                onIndent: (_) {},
                onUnindent: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no RenderFlex overflow exception was thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('DraggableSplitView clamps drag within min/max extents', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var currentRatio = 0.5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraggableSplitView(
              axis: Axis.vertical,
              ratio: currentRatio,
              onRatioChanged: (r) => currentRatio = r,
              firstChild: const Text('TopPane'),
              secondChild: const Text('BottomPane'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag up significantly to attempt shrinking top pane below minimum
      await tester.drag(find.byType(GestureDetector).first, const Offset(0, -500), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(currentRatio, greaterThanOrEqualTo(0.05));
      expect(tester.takeException(), isNull);
    });
  });
}
