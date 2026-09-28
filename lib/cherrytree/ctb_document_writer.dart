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
        final isQuill = NoteBodyCodec.looksLikeQuillDeltaJson(n.body);
        final String txt;
        final String syntax;
        final bool isRich;

        if (isQuill) {
          final qDoc = NoteBodyCodec.documentFromStorage(n.body);
          txt = CherrytreeQuillBridge.sqliteTxtFromDocument(qDoc);
          syntax = n.syntax.isNotEmpty && n.syntax != kCherrytreePlainTextSyntaxId
              ? n.syntax
              : kCherrytreeRichTextSyntaxId;
          isRich = true;
        } else {
          txt = n.body;
          syntax = n.syntax == kCherrytreeRichTextSyntaxId
              ? kCherrytreePlainTextSyntaxId
              : (n.syntax.isNotEmpty ? n.syntax : kCherrytreePlainTextSyntaxId);
          isRich = false;
        }

        final isRoValue = (n.customIconId << 1) | (n.isReadOnly ? 1 : 0);

        var isRichtxtValue = isRich ? 1 : 0;
        if (n.isBold) {
          isRichtxtValue |= (1 << 1);
        }
        final fgHex = n.foregroundColor?.trim();
        if (fgHex != null && fgHex.isNotEmpty) {
          final cleanHex = fgHex.startsWith('#') ? fgHex.substring(1) : fgHex;
          final rgb = int.tryParse(cleanHex, radix: 16);
          if (rgb != null) {
            isRichtxtValue |= (1 << 2);
            isRichtxtValue |= ((rgb & 0xffffff) << 3);
          }
        }

        var levelValue = 0;
        if (n.excludeMeFromSearch) levelValue |= 1;
        if (n.excludeChildrenFromSearch) levelValue |= 2;

        final tsCreation = n.tsCreation > 0 ? n.tsCreation : now;
        final tsLastSave = n.tsLastSave > 0 ? n.tsLastSave : now;

        batch.insert('node', {
          'node_id': nid,
          'name': n.title,
          'txt': txt,
          'syntax': syntax,
          'tags': n.tags,
          'is_ro': isRoValue,
          'is_richtxt': isRichtxtValue,
          'has_codebox': 0,
          'has_table': 0,
          'has_image': 0,
          'level': levelValue,
          'ts_creation': tsCreation,
          'ts_lastsave': tsLastSave,
        });
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
          'master_id': n.masterId,
        });
      }

      var bmSeq = 1;
      for (final bId in doc.bookmarks) {
        final nid = idMap[bId];
        batch.insert('bookmark', {
          'node_id': nid,
          'sequence': bmSeq++,
        });
      }

      await batch.commit(noResult: true);
    } finally {
      await db.close();
    }
  }
}
