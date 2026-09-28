import 'package:xml/xml.dart';

import '../models/note_document.dart';
import '../rich/cherrytree_quill_bridge.dart';
import '../rich/note_body_codec.dart';
import 'cherrytree_read_result.dart';
import 'ct_body_plain.dart';
import 'ct_constants.dart';

/// Read-only import of an unencrypted CherryTree XML document ([.ctd]).
class CtdDocumentReader {
  CtdDocumentReader._();

  /// Decodes [bytes] as UTF-8 and parses the document.
  static CherrytreeReadResult readBytes(List<int> bytes, {List<String>? warnings}) {
    final w = warnings ?? <String>[];
    final text = String.fromCharCodes(bytes);
    return readString(text, warnings: w);
  }

  static CherrytreeReadResult readString(String xmlText, {List<String>? warnings}) {
    final w = warnings ?? <String>[];
    late XmlDocument doc;
    try {
      doc = XmlDocument.parse(xmlText);
    } on Object catch (e) {
      throw FormatException('Invalid XML: $e');
    }

    final root = doc.rootElement;
    if (root.name.local != kCherrytreeXmlRootElement) {
      w.add(
        'Expected root element "$kCherrytreeXmlRootElement", found "${root.name.local}".',
      );
    }

    final primary = <int, _PrimaryContent>{};
    final nodes = <NoteNode>[];
    var anyUnsupportedSlots = false;

    void visit(XmlElement el, String? parentId, int sortIndex) {
      final uidStr = el.getAttribute('unique_id');
      if (uidStr == null) {
        w.add('Skipped a node with no unique_id.');
        return;
      }
      final uid = int.tryParse(uidStr);
      if (uid == null) {
        w.add('Skipped node with invalid unique_id: $uidStr');
        return;
      }

      final masterStr = el.getAttribute('master_id') ?? '0';
      final masterId = int.tryParse(masterStr) ?? 0;
      final id = 'ct-$uid';

      late String title;
      late String body;
      var customIconId = 0;
      var tags = '';
      var syntax = kCherrytreeRichTextSyntaxId;
      var isBold = false;
      String? foregroundColor;
      var isReadOnly = false;
      var excludeMeFromSearch = false;
      var excludeChildrenFromSearch = false;
      var tsCreation = 0;
      var tsLastSave = 0;

      if (masterId <= 0) {
        title = el.getAttribute('name') ?? '';
        final iconStr = el.getAttribute('custom_icon_id');
        customIconId = int.tryParse(iconStr ?? '') ?? 0;
        tags = el.getAttribute('tags') ?? '';
        syntax = el.getAttribute('prog_lang') ?? kCherrytreeRichTextSyntaxId;
        isBold = el.getAttribute('is_bold') == '1';
        final fg = el.getAttribute('foreground')?.trim();
        foregroundColor = (fg != null && fg.isNotEmpty) ? fg : null;
        isReadOnly = el.getAttribute('readonly') == '1';
        excludeMeFromSearch = el.getAttribute('nosearch_me') == '1';
        excludeChildrenFromSearch = el.getAttribute('nosearch_ch') == '1';
        tsCreation = int.tryParse(el.getAttribute('ts_creation') ?? '0') ?? 0;
        tsLastSave = int.tryParse(el.getAttribute('ts_lastsave') ?? '0') ?? 0;

        final parsed = CtBodyPlain.fromCtdNode(el, w);
        body = NoteBodyCodec.documentToStorage(
          CherrytreeQuillBridge.documentFromCtdNode(el),
        );
        if (parsed.$2) anyUnsupportedSlots = true;
        primary[uid] = _PrimaryContent(title: title, body: body);
      } else {
        final p = primary[masterId];
        if (p == null) {
          w.add('Shared node $uid references missing master $masterId.');
          title = '';
          body = '';
        } else {
          title = p.title;
          body = p.body;
        }
      }

      nodes.add(
        NoteNode(
          id: id,
          parentId: parentId,
          title: title,
          body: body,
          sortIndex: sortIndex,
          customIconId: customIconId,
          tags: tags,
          syntax: syntax,
          isBold: isBold,
          foregroundColor: foregroundColor,
          isReadOnly: isReadOnly,
          excludeMeFromSearch: excludeMeFromSearch,
          excludeChildrenFromSearch: excludeChildrenFromSearch,
          tsCreation: tsCreation,
          tsLastSave: tsLastSave,
          masterId: masterId,
        ),
      );

      var childSeq = 0;
      for (final child in el.childElements) {
        if (child.name.local == 'node') {
          visit(child, id, childSeq++);
        }
      }
    }

    final bookmarks = <String>[];
    var rootSeq = 0;
    for (final child in root.childElements) {
      if (child.name.local == 'bookmarks') {
        final listAttr = child.getAttribute('list');
        if (listAttr != null && listAttr.isNotEmpty) {
          for (final part in listAttr.split(',')) {
            final numId = int.tryParse(part.trim());
            if (numId != null) {
              bookmarks.add('ct-$numId');
            }
          }
        }
      } else if (child.name.local == 'node') {
        visit(child, null, rootSeq++);
      }
    }

    if (anyUnsupportedSlots) {
      w.add(
        'Some content (images, tables, or code boxes) was omitted; only plain text is imported.',
      );
    }

    return CherrytreeReadResult(
      document: NoteDocument(nodes: nodes, bookmarks: bookmarks),
      warnings: List<String>.from(w),
    );
  }
}

class _PrimaryContent {
  _PrimaryContent({required this.title, required this.body});

  final String title;
  final String body;
}
