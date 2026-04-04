import 'dart:io';

import 'package:cherrytree_flutter/cherrytree/ctb_document_reader.dart';
import 'package:cherrytree_flutter/cherrytree/ctb_document_writer.dart';
import 'package:cherrytree_flutter/cherrytree/ctd_document_reader.dart';
import 'package:cherrytree_flutter/cherrytree/ctd_document_writer.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rich_test_utils.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CtdDocumentWriter', () {
    test('round-trips tree and text', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'ct-1',
            parentId: null,
            title: 'Root',
            body: 'Hello',
            sortIndex: 0,
          ),
          NoteNode(
            id: 'ct-2',
            parentId: 'ct-1',
            title: 'Child',
            body: 'Nested',
            sortIndex: 0,
          ),
        ],
      );
      final xml = CtdDocumentWriter.writeString(doc);
      final back = CtdDocumentReader.readString(xml).document;
      expect(back.find('ct-1')?.title, 'Root');
      expect(plainBody(back.find('ct-1')!.body), 'Hello');
      expect(back.find('ct-2')?.parentId, 'ct-1');
      expect(plainBody(back.find('ct-2')!.body), 'Nested');
    });
  });

  group('CtbDocumentWriter', () {
    test('round-trips tree and text', () async {
      final dir = await Directory.systemTemp.createTemp('ctb_wr_');
      final path = '${dir.path}/w.ctb';
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'ct-1',
            parentId: null,
            title: 'SQL',
            body: 'line',
            sortIndex: 0,
          ),
        ],
      );
      await CtbDocumentWriter.writeToPath(path, doc);
      final r = await CtbDocumentReader.readPath(path);
      expect(r.document.find('ct-1')?.title, 'SQL');
      expect(r.document.find('ct-1')?.body, 'line');
      await dir.delete(recursive: true);
    });
  });
}
