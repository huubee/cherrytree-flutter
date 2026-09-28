import 'dart:io';

import 'package:xml/xml.dart';

import '../models/note_document.dart';
import '../rich/cherrytree_quill_bridge.dart';
import '../rich/note_body_codec.dart';
import 'cherrytree_id_map.dart';
import 'ct_constants.dart';

/// Writes a [NoteDocument] as CherryTree single-file XML ([.ctd]).
///
/// Bodies stored as Quill Delta JSON become `custom-colors` nodes with CherryTree
/// `<rich_text>` slots; legacy plain strings use `plain-text` and one slot.
class CtdDocumentWriter {
  CtdDocumentWriter._();

  static Future<void> writeToFile(String path, NoteDocument doc) async {
    await File(path).writeAsString(writeString(doc));
  }

  static String writeString(NoteDocument doc) {
    final idMap = CherrytreeIdMap.fromDocument(doc);
    final b = XmlBuilder();
    b.processing('xml', 'version="1.0" encoding="UTF-8"');
    b.element(
      kCherrytreeXmlRootElement,
      nest: () {
        if (doc.bookmarks.isNotEmpty) {
          final bmIds = <int>[];
          for (final bId in doc.bookmarks) {
            final mapped = idMap[bId];
            bmIds.add(mapped);
          }
          if (bmIds.isNotEmpty) {
            b.element('bookmarks', attributes: {'list': bmIds.join(',')});
          }
        }
        for (final root in doc.childrenOf(null)) {
          _writeNode(b, doc, idMap, root);
        }
      },
    );
    return b.buildDocument().toXmlString(pretty: true);
  }

  static void _writeNode(
    XmlBuilder b,
    NoteDocument doc,
    CherrytreeIdMap idMap,
    NoteNode n,
  ) {
    final uid = idMap[n.id];
    b.element(
      'node',
      attributes: _nodeAttributes(uid, n),
      nest: () {
        if (NoteBodyCodec.looksLikeQuillDeltaJson(n.body)) {
          final docBody = NoteBodyCodec.documentFromStorage(n.body);
          CherrytreeQuillBridge.writeRichTextChildren(b, docBody);
        } else {
          b.element(
            'rich_text',
            nest: () {
              b.text(n.body);
            },
          );
        }
        for (final ch in doc.childrenOf(n.id)) {
          _writeNode(b, doc, idMap, ch);
        }
      },
    );
  }

  /// Serializes node attributes aligning with upstream CherryTree XML format.
  static Map<String, String> _nodeAttributes(int uniqueId, NoteNode n) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final syntax = n.syntax.isNotEmpty
        ? n.syntax
        : (NoteBodyCodec.looksLikeQuillDeltaJson(n.body)
            ? kCherrytreeRichTextSyntaxId
            : 'plain-text');
    final tsCreation = n.tsCreation > 0 ? n.tsCreation : now;
    final tsLastSave = n.tsLastSave > 0 ? n.tsLastSave : now;

    return {
      'unique_id': '$uniqueId',
      'master_id': '${n.masterId}',
      'name': n.title,
      'prog_lang': syntax,
      'tags': n.tags,
      'readonly': n.isReadOnly ? '1' : '0',
      'nosearch_me': n.excludeMeFromSearch ? '1' : '0',
      'nosearch_ch': n.excludeChildrenFromSearch ? '1' : '0',
      'custom_icon_id': '${n.customIconId}',
      'is_bold': n.isBold ? '1' : '0',
      'foreground': n.foregroundColor ?? '',
      'ts_creation': '$tsCreation',
      'ts_lastsave': '$tsLastSave',
    };
  }
}
