import 'dart:io';

import 'package:cherrytree_flutter/cherrytree/ctb_document_reader.dart';
import 'package:cherrytree_flutter/cherrytree/ctb_document_writer.dart';
import 'package:cherrytree_flutter/cherrytree/ctd_document_reader.dart';
import 'package:cherrytree_flutter/cherrytree/ctd_document_writer.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('NoteNode and NoteDocument metadata', () {
    test('JSON serialization round-trips all metadata and bookmarks', () {
      final node = NoteNode(
        id: 'node-1',
        parentId: null,
        title: 'Project Roadmap',
        body: 'Plain text roadmap',
        sortIndex: 0,
        customIconId: 4,
        tags: 'work, planning',
        syntax: 'plain-text',
        isBold: true,
        foregroundColor: '#ff5500',
        isReadOnly: true,
        excludeMeFromSearch: true,
        excludeChildrenFromSearch: false,
        tsCreation: 1600000000,
        tsLastSave: 1600001000,
        masterId: 10,
      );

      final doc = NoteDocument(
        nodes: [node],
        bookmarks: ['node-1'],
      );

      expect(doc.isBookmarked('node-1'), isTrue);
      expect(doc.isBookmarked('other'), isFalse);

      final json = doc.toJson();
      final roundTripped = NoteDocument.fromJson(json);

      expect(roundTripped.bookmarks, ['node-1']);
      expect(roundTripped.nodes.length, 1);

      final n = roundTripped.nodes.first;
      expect(n.id, 'node-1');
      expect(n.title, 'Project Roadmap');
      expect(n.body, 'Plain text roadmap');
      expect(n.customIconId, 4);
      expect(n.tags, 'work, planning');
      expect(n.syntax, 'plain-text');
      expect(n.isBold, isTrue);
      expect(n.foregroundColor, '#ff5500');
      expect(n.isReadOnly, isTrue);
      expect(n.excludeMeFromSearch, isTrue);
      expect(n.excludeChildrenFromSearch, isFalse);
      expect(n.tsCreation, 1600000000);
      expect(n.tsLastSave, 1600001000);
      expect(n.masterId, 10);
    });

    test('bookmarks can be added, toggled, and removed', () {
      final doc = NoteDocument();
      expect(doc.isBookmarked('a'), isFalse);

      doc.addBookmark('a');
      expect(doc.isBookmarked('a'), isTrue);

      doc.toggleBookmark('a');
      expect(doc.isBookmarked('a'), isFalse);

      doc.toggleBookmark('b');
      expect(doc.isBookmarked('b'), isTrue);

      doc.removeBookmark('b');
      expect(doc.isBookmarked('b'), isFalse);
    });
  });

  group('XML CTD full metadata and bookmarks round-trip', () {
    test('preserves tags, syntax, bold, color, readonly, search flags, timestamps, and bookmarks', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'ct-1',
            parentId: null,
            title: 'Node A',
            body: 'Body A',
            sortIndex: 0,
            customIconId: 7,
            tags: 'tag1, tag2',
            syntax: 'python',
            isBold: true,
            foregroundColor: '#123456',
            isReadOnly: true,
            excludeMeFromSearch: true,
            excludeChildrenFromSearch: true,
            tsCreation: 1600000000,
            tsLastSave: 1600002000,
          ),
          NoteNode(
            id: 'ct-2',
            parentId: 'ct-1',
            title: 'Node B',
            body: 'Body B',
            sortIndex: 0,
            customIconId: 0,
          ),
        ],
        bookmarks: ['ct-1'],
      );

      final xmlString = CtdDocumentWriter.writeString(doc);
      expect(xmlString, contains('tags="tag1, tag2"'));
      expect(xmlString, contains('prog_lang="python"'));
      expect(xmlString, contains('is_bold="1"'));
      expect(xmlString, contains('foreground="#123456"'));
      expect(xmlString, contains('readonly="1"'));
      expect(xmlString, contains('nosearch_me="1"'));
      expect(xmlString, contains('nosearch_ch="1"'));
      expect(xmlString, contains('bookmarks list="1"'));

      final readResult = CtdDocumentReader.readString(xmlString);
      final rDoc = readResult.document;

      expect(rDoc.bookmarks, ['ct-1']);
      expect(rDoc.nodes.length, 2);

      final nodeA = rDoc.find('ct-1')!;
      expect(nodeA.title, 'Node A');
      expect(nodeA.tags, 'tag1, tag2');
      expect(nodeA.syntax, 'python');
      expect(nodeA.isBold, isTrue);
      expect(nodeA.foregroundColor, '#123456');
      expect(nodeA.isReadOnly, isTrue);
      expect(nodeA.excludeMeFromSearch, isTrue);
      expect(nodeA.excludeChildrenFromSearch, isTrue);
      expect(nodeA.customIconId, 7);
      expect(nodeA.tsCreation, 1600000000);
      expect(nodeA.tsLastSave, 1600002000);

      final nodeB = rDoc.find('ct-2')!;
      expect(nodeB.parentId, 'ct-1');
      expect(nodeB.isBold, isFalse);
      expect(nodeB.isReadOnly, isFalse);
    });
  });

  group('SQLite CTB full metadata and bookmarks round-trip', () {
    test('preserves bitfields, colors, readonly, timestamps, and bookmark table', () async {
      final dir = await Directory.systemTemp.createTemp('ctb_meta_');
      final path = '${dir.path}/meta.ctb';

      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'ct-10',
            parentId: null,
            title: 'SQLite Meta Node',
            body: 'Content for sqlite',
            sortIndex: 0,
            customIconId: 5,
            tags: 'sqlite, db',
            syntax: 'sql',
            isBold: true,
            foregroundColor: '#336699',
            isReadOnly: true,
            excludeMeFromSearch: true,
            excludeChildrenFromSearch: false,
            tsCreation: 1700000000,
            tsLastSave: 1700005000,
          ),
        ],
        bookmarks: ['ct-10'],
      );

      await CtbDocumentWriter.writeToPath(path, doc);
      final readResult = await CtbDocumentReader.readPath(path);
      final rDoc = readResult.document;

      expect(rDoc.bookmarks, ['ct-10']);
      expect(rDoc.nodes.length, 1);

      final n = rDoc.find('ct-10')!;
      expect(n.title, 'SQLite Meta Node');
      expect(n.body, 'Content for sqlite');
      expect(n.customIconId, 5);
      expect(n.tags, 'sqlite, db');
      expect(n.syntax, 'sql');
      expect(n.isBold, isTrue);
      expect(n.foregroundColor, '#336699');
      expect(n.isReadOnly, isTrue);
      expect(n.excludeMeFromSearch, isTrue);
      expect(n.excludeChildrenFromSearch, isFalse);
      expect(n.tsCreation, 1700000000);
      expect(n.tsLastSave, 1700005000);

      await dir.delete(recursive: true);
    });
  });
}
