import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../models/note_document.dart';
import '../rich/cherrytree_quill_bridge.dart';
import '../rich/note_body_codec.dart';
import 'cherrytree_id_map.dart';
import 'ct_constants.dart';
import 'ctb_schema.dart';

/// Writes a [NoteDocument] as CherryTree SQLite ([.ctb]).
///
/// Quill bodies use `custom-colors` and XML [txt]; legacy plain strings stay `plain-text`.
class CtbDocumentWriter {
  CtbDocumentWriter._();

  static Future<void> writeToPath(String path, NoteDocument doc) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        for (final sql in CtbSchema.createAll) {
          await db.execute(sql);
        }
      },
    );
    try {
      final idMap = CherrytreeIdMap.fromDocument(doc);
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final batch = db.batch();
      for (final n in doc.nodes) {
        final nid = idMap[n.id];
        if (NoteBodyCodec.looksLikeQuillDeltaJson(n.body)) {
          final qDoc = NoteBodyCodec.documentFromStorage(n.body);
          batch.insert('node', {
            'node_id': nid,
            'name': n.title,
            'txt': CherrytreeQuillBridge.sqliteTxtFromDocument(qDoc),
            'syntax': kCherrytreeRichTextSyntaxId,
            'tags': '',
            'is_ro': n.customIconId << 1,
            'is_richtxt': 1,
            'has_codebox': 0,
            'has_table': 0,
            'has_image': 0,
            'level': 0,
            'ts_creation': now,
            'ts_lastsave': now,
          });
        } else {
          batch.insert('node', {
            'node_id': nid,
            'name': n.title,
            'txt': n.body,
            'syntax': 'plain-text',
            'tags': '',
            'is_ro': n.customIconId << 1,
            'is_richtxt': 0,
            'has_codebox': 0,
            'has_table': 0,
            'has_image': 0,
            'level': 0,
            'ts_creation': now,
            'ts_lastsave': now,
          });
        }
      }
      for (final n in doc.nodes) {
        final nid = idMap[n.id];
        final parentId = n.parentId;
        final pid = parentId == null ? 0 : idMap[parentId];
        final siblings = doc.childrenOf(n.parentId);
        final seq = siblings.indexWhere((x) => x.id == n.id) + 1;
        batch.insert('children', {
          'node_id': nid,
          'father_id': pid,
          'sequence': seq,
          'master_id': 0,
        });
      }
      await batch.commit(noResult: true);
    } finally {
      await db.close();
    }
  }
}
