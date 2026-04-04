import 'dart:io';

import 'package:cherrytree_flutter/cherrytree/ctb_document_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CtbDocumentReader', () {
    test('reads sqlite tree', () async {
      final dir = await Directory.systemTemp.createTemp('ctb_ct_');
      final dbPath = '${dir.path}/t.ctb';
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, v) async {
          await db.execute('''
CREATE TABLE node (
  node_id INTEGER UNIQUE,
  name TEXT,
  txt TEXT,
  syntax TEXT,
  tags TEXT,
  is_ro INTEGER,
  is_richtxt INTEGER,
  has_codebox INTEGER,
  has_table INTEGER,
  has_image INTEGER,
  level INTEGER,
  ts_creation INTEGER,
  ts_lastsave INTEGER
)''');
          await db.execute('''
CREATE TABLE children (
  node_id INTEGER UNIQUE,
  father_id INTEGER,
  sequence INTEGER,
  master_id INTEGER
)''');
          await db.insert('node', {
            'node_id': 1,
            'name': 'SQL',
            'txt': 'line',
            'syntax': 'plain-text',
            'tags': '',
            'is_ro': 0,
            'is_richtxt': 0,
            'has_codebox': 0,
            'has_table': 0,
            'has_image': 0,
            'level': 0,
            'ts_creation': 0,
            'ts_lastsave': 0,
          });
          await db.insert('children', {
            'node_id': 1,
            'father_id': 0,
            'sequence': 1,
            'master_id': 0,
          });
        },
      );
      await db.close();

      final r = await CtbDocumentReader.readPath(dbPath);
      expect(r.document.nodes.length, 1);
      expect(r.document.find('ct-1')?.title, 'SQL');
      expect(r.document.find('ct-1')?.body, 'line');

      await dir.delete(recursive: true);
    });
  });
}
