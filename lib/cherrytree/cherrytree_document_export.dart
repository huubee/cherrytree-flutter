import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../models/note_document.dart';
import 'ctb_document_writer.dart';
import 'ctd_document_writer.dart';
import 'document_exporter.dart';

/// Builds file bytes for sharing or “save as” flows (see [CtdDocumentWriter], [CtbDocumentWriter]).
class CherrytreeDocumentExport {
  CherrytreeDocumentExport._();

  /// UTF-8 XML for a single-file `.ctd` document.
  static Uint8List ctdBytes(NoteDocument doc) {
    return Uint8List.fromList(utf8.encode(CtdDocumentWriter.writeString(doc)));
  }

  /// SQLite bytes for a `.ctb` document (written to a temp file then read back).
  static Future<Uint8List> ctbBytes(NoteDocument doc) async {
    final dir = await getTemporaryDirectory();
    final f = File(
      '${dir.path}/cherrytree_export_${DateTime.now().millisecondsSinceEpoch}.ctb',
    );
    try {
      await CtbDocumentWriter.writeToPath(f.path, doc);
      return await f.readAsBytes();
    } finally {
      if (await f.exists()) {
        await f.delete();
      }
    }
  }

  /// UTF-8 Markdown representation.
  static Uint8List markdownBytes(
    NoteDocument doc, {
    String? nodeId,
    bool recursive = true,
  }) {
    final md = DocumentExporter.exportToMarkdown(
      doc,
      nodeId: nodeId,
      recursive: recursive,
    );
    return Uint8List.fromList(utf8.encode(md));
  }

  /// UTF-8 HTML document.
  static Uint8List htmlBytes(
    NoteDocument doc, {
    String? nodeId,
    bool recursive = true,
    String title = 'CherryTree Notes',
  }) {
    final html = DocumentExporter.exportToHtml(
      doc,
      nodeId: nodeId,
      recursive: recursive,
      title: title,
    );
    return Uint8List.fromList(utf8.encode(html));
  }

  /// UTF-8 Plain text representation.
  static Uint8List plainTextBytes(
    NoteDocument doc, {
    String? nodeId,
    bool recursive = true,
  }) {
    final txt = DocumentExporter.exportToPlainText(
      doc,
      nodeId: nodeId,
      recursive: recursive,
    );
    return Uint8List.fromList(utf8.encode(txt));
  }
}
