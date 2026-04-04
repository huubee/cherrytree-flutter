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
      attributes: _nodeAttributes(uid, n.title, n.body),
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

  /// Defaults mirror typical CherryTree exports (see [CtdDocumentReader] tests).
  static Map<String, String> _nodeAttributes(int uniqueId, String title, String body) => {
        'unique_id': '$uniqueId',
        'master_id': '0',
        'name': title,
        'prog_lang': _progLangForBody(body),
        'tags': '',
        'readonly': '0',
        'nosearch_me': '0',
        'nosearch_ch': '0',
        'custom_icon_id': '0',
        'is_bold': '0',
        'foreground': '',
        'ts_creation': '0',
        'ts_lastsave': '0',
      };

  static String _progLangForBody(String body) {
    return NoteBodyCodec.looksLikeQuillDeltaJson(body)
        ? kCherrytreeRichTextSyntaxId
        : 'plain-text';
  }
}
