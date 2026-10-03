import 'dart:convert';
import 'package:cherrytree_flutter/cherrytree/cherrytree_document_export.dart';
import 'package:cherrytree_flutter/cherrytree/ct_body_plain.dart';
import 'package:cherrytree_flutter/cherrytree/document_exporter.dart';
import 'package:cherrytree_flutter/l10n/app_localizations.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:cherrytree_flutter/rich/cherrytree_quill_bridge.dart';
import 'package:cherrytree_flutter/rich/note_body_codec.dart';
import 'package:cherrytree_flutter/widgets/export_dialog.dart';
import 'package:cherrytree_flutter/widgets/insert_codebox_dialog.dart';
import 'package:cherrytree_flutter/widgets/insert_table_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

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
  group('Phase 5 - Advanced Content in CherrytreeQuillBridge & CtBodyPlain', () {
    test('parses <codebox> from XML node into Quill code block', () {
      const xml = '''
<node unique_id="1" name="Code Note">
  <rich_text>Intro text\n</rich_text>
  <codebox syntax_highlighting="python">def add(a, b):
    return a + b</codebox>
  <rich_text>\nOutro text</rich_text>
</node>
''';
      final root = XmlDocument.parse(xml).rootElement;
      final doc = CherrytreeQuillBridge.documentFromCtdNode(root);
      final plain = doc.toPlainText();

      expect(plain, contains('def add(a, b):'));
      expect(plain, contains('return a + b'));

      // Check code-block attribute in delta
      final ops = doc.toDelta().toList();
      final hasCodeBlock = ops.any((op) =>
          op.attributes != null && op.attributes!['code-block'] != null);
      expect(hasCodeBlock, isTrue);
    });

    test('parses <table> from XML node into grid table format', () {
      const xml = '''
<node unique_id="2" name="Table Note">
  <table col_widths="100,100">
    <row>
      <cell>Col A</cell>
      <cell>Col B</cell>
    </row>
    <row>
      <cell>Val 1</cell>
      <cell>Val 2</cell>
    </row>
  </table>
</node>
''';
      final root = XmlDocument.parse(xml).rootElement;
      final doc = CherrytreeQuillBridge.documentFromCtdNode(root);
      final plain = doc.toPlainText();

      expect(plain, contains('| Col A | Col B |'));
      expect(plain, contains('| --- | --- |'));
      expect(plain, contains('| Val 1 | Val 2 |'));
    });

    test('parses <encoded_png> into Quill image embed and serializes back', () {
      const sampleBase64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      const xml = '''
<node unique_id="3" name="Image Note">
  <encoded_png>$sampleBase64</encoded_png>
</node>
''';
      final root = XmlDocument.parse(xml).rootElement;
      final doc = CherrytreeQuillBridge.documentFromCtdNode(root);

      final ops = doc.toDelta().toList();
      final imageOp = ops.firstWhere(
        (op) => op.data is Map && (op.data as Map).containsKey('image'),
      );
      expect((imageOp.data as Map)['image'], contains(sampleBase64));

      // Serialize back to XML
      final xmlBack = CherrytreeQuillBridge.sqliteTxtFromDocument(doc);
      expect(xmlBack, contains('<encoded_png'));
      expect(xmlBack, contains(sampleBase64));
    });

    test('CtBodyPlain extracts text from codebox and table for search indexing', () {
      const xml = '''
<node unique_id="4" name="Searchable">
  <rich_text>Hello </rich_text>
  <codebox syntax_highlighting="sh">echo "findme_in_code"</codebox>
  <table>
    <row>
      <cell>findme_in_cell</cell>
    </row>
  </table>
</node>
''';
      final root = XmlDocument.parse(xml).rootElement;
      final (body, _) = CtBodyPlain.fromCtdNode(root, []);
      expect(body, contains('findme_in_code'));
      expect(body, contains('findme_in_cell'));
    });
  });

  group('Phase 5 - DocumentExporter Engine', () {
    late NoteDocument doc;

    setUp(() {
      doc = NoteDocument(
        nodes: [
          NoteNode(
            id: '1',
            parentId: null,
            title: 'Parent Node',
            tags: 'project, urgent',
            body: NoteBodyCodec.documentToStorage(
              Document.fromJson([
                {'insert': 'This is bold text', 'attributes': {'bold': true}},
                {'insert': ' and '},
                {'insert': 'inline code', 'attributes': {'code': true}},
                {'insert': '\n'},
              ]),
            ),
            sortIndex: 0,
          ),
          NoteNode(
            id: '2',
            parentId: '1',
            title: 'Child Node',
            tags: '',
            body: NoteBodyCodec.documentToStorage(
              Document.fromJson([
                {'insert': 'def calculate():\n    return 42\n'},
                {'insert': '\n', 'attributes': {'code-block': 'python'}},
              ]),
            ),
            sortIndex: 0,
          ),
        ],
      );
    });

    test('exportToMarkdown creates hierarchical markdown with tags and formatting', () {
      final md = DocumentExporter.exportToMarkdown(doc);

      // Parent heading level 1
      expect(md, contains('# Parent Node'));
      expect(md, contains('> **Tags**: project, urgent'));
      expect(md, contains('**This is bold text**'));
      expect(md, contains('`inline code`'));

      // Child heading level 2
      expect(md, contains('## Child Node'));
      expect(md, contains('def calculate():'));
    });

    test('exportToMarkdown scoped to single node produces single level heading', () {
      final md = DocumentExporter.exportToMarkdown(doc, nodeId: '2', recursive: false);

      expect(md, contains('# Child Node'));
      expect(md, isNot(contains('# Parent Node')));
    });

    test('exportToHtml generates standalone HTML5 with styling and TOC', () {
      final html = DocumentExporter.exportToHtml(doc, title: 'Test Export');

      expect(html, contains('<!DOCTYPE html>'));
      expect(html, contains('<title>Test Export</title>'));
      expect(html, contains('<nav class="toc">'));
      expect(html, contains('href="#node-1"'));
      expect(html, contains('href="#node-2"'));
      expect(html, contains('<strong>This is bold text</strong>'));
      expect(html, contains('<code>inline code</code>'));
      expect(html, contains('<pre><code>'));
      expect(html, contains('calculate():'));
    });

    test('exportToPlainText generates clean structured plain text', () {
      final txt = DocumentExporter.exportToPlainText(doc);

      expect(txt, contains('Parent Node'));
      expect(txt, contains('[Tags: project, urgent]'));
      expect(txt, contains('This is bold text and inline code'));
      expect(txt, contains('Child Node'));
    });

    test('CherrytreeDocumentExport generates valid non-empty byte streams', () {
      final mdBytes = CherrytreeDocumentExport.markdownBytes(doc);
      final htmlBytes = CherrytreeDocumentExport.htmlBytes(doc);
      final txtBytes = CherrytreeDocumentExport.plainTextBytes(doc);

      expect(mdBytes.isNotEmpty, isTrue);
      expect(htmlBytes.isNotEmpty, isTrue);
      expect(txtBytes.isNotEmpty, isTrue);

      expect(utf8.decode(mdBytes), contains('# Parent Node'));
      expect(utf8.decode(htmlBytes), contains('<!DOCTYPE html>'));
      expect(utf8.decode(txtBytes), contains('Parent Node'));
    });
  });

  group('Phase 5 - Advanced Content Dialogs', () {
    testWidgets('InsertCodeboxDialog configures language and returns code',
        (tester) async {
      CodeboxInsertResult? result;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await InsertCodeboxDialog.show(ctx);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(InsertCodeboxDialog), findsOneWidget);
      expect(find.text('Insert Code Box'), findsOneWidget);

      // Enter code into the text field
      await tester.enterText(find.byType(TextField), 'print("Hello from test")');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Insert'));
      await tester.pumpAndSettle();

      expect(find.byType(InsertCodeboxDialog), findsNothing);
      expect(result, isNotNull);
      expect(result!.language, 'python');
      expect(result!.code, 'print("Hello from test")');
      expect(result!.showLineNumbers, isTrue);
    });

    testWidgets('InsertTableDialog generates formatted markdown table',
        (tester) async {
      String? generatedTable;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                generatedTable = await InsertTableDialog.show(ctx);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(InsertTableDialog), findsOneWidget);

      // Click Insert with default 3x3 table
      await tester.tap(find.text('Insert'));
      await tester.pumpAndSettle();

      expect(find.byType(InsertTableDialog), findsNothing);
      expect(generatedTable, isNotNull);
      expect(generatedTable, contains('| Col 1 | Col 2 | Col 3 |'));
      expect(generatedTable, contains('| --- | --- | --- |'));
    });

    testWidgets('ExportDialog displays scope and format options',
        (tester) async {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'My Note', body: 'Content', sortIndex: 0),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => ExportDialog.show(ctx, doc: doc, selectedNodeId: '1'),
              child: const Text('Export'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();

      expect(find.byType(ExportDialog), findsOneWidget);
      expect(find.text('Export Notes'), findsOneWidget);

      // Check format options exist
      expect(find.text('Markdown (.md)'), findsOneWidget);
      expect(find.text('HTML (.html)'), findsOneWidget);
      expect(find.text('Plain Text (.txt)'), findsOneWidget);
      expect(find.text('CherryTree XML (.ctd)'), findsOneWidget);
      expect(find.text('CherryTree SQLite (.ctb)'), findsOneWidget);

      // Action buttons
      expect(find.text('Copy to Clipboard'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Save to File'), findsOneWidget);

      // Close dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(ExportDialog), findsNothing);
    });
  });
}
