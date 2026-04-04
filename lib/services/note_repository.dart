import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../cherrytree/ctb_document_reader.dart';
import '../cherrytree/ctb_document_writer.dart';
import '../cherrytree/ctd_document_reader.dart';
import '../cherrytree/ctd_document_writer.dart';
import '../l10n/l10n_utils.dart';
import '../models/note_document.dart';
import 'document_storage_prefs.dart';

class NoteRepository {
  NoteRepository({Future<File> Function()? resolveFile})
      : _resolveFile = resolveFile;

  /// Override for tests; default uses app documents + [defaultFileName].
  final Future<File> Function()? _resolveFile;

  static const defaultFileName = 'spike_a_notes.json';

  Future<File> _file() async {
    if (_resolveFile != null) return _resolveFile();
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$defaultFileName');
  }

  Future<NoteDocument> load() async {
    final mode = await DocumentStoragePrefs.getCherrytreeMode();
    final ctPath = await DocumentStoragePrefs.getCherrytreePath();
    if (mode != null &&
        ctPath != null &&
        mode.isNotEmpty &&
        ctPath.isNotEmpty) {
      final ctFile = File(ctPath);
      if (await ctFile.exists()) {
        try {
          if (mode == 'ctd') {
            final bytes = await ctFile.readAsBytes();
            return CtdDocumentReader.readBytes(bytes).document;
          }
          if (mode == 'ctb') {
            return (await CtbDocumentReader.readPath(ctPath)).document;
          }
        } on Object catch (e, st) {
          developer.log(
            'CherryTree file load failed, falling back to JSON',
            error: e,
            stackTrace: st,
          );
        }
      }
    }

    final f = await _file();
    if (!await f.exists()) {
      return _seedDocument();
    }
    try {
      final text = await f.readAsString();
      if (text.trim().isEmpty) return _seedDocument();
      final map = jsonDecode(text) as Map<String, dynamic>;
      return NoteDocument.fromJson(map);
    } on Object {
      return _seedDocument();
    }
  }

  /// Persists [doc] to app documents (JSON backup) and, when configured, to the
  /// imported CherryTree [.ctd] / [.ctb] path. Returns `false` if the JSON backup failed.
  Future<bool> save(NoteDocument doc) async {
    try {
      final f = await _file();
      final encoder = JsonEncoder.withIndent('  ');
      await f.writeAsString(encoder.convert(doc.toJson()));
    } on Object catch (e, st) {
      developer.log('Failed to save notes JSON', error: e, stackTrace: st);
      return false;
    }

    final mode = await DocumentStoragePrefs.getCherrytreeMode();
    final ctPath = await DocumentStoragePrefs.getCherrytreePath();
    if (mode != null && ctPath != null && ctPath.isNotEmpty) {
      try {
        if (mode == 'ctd') {
          await CtdDocumentWriter.writeToFile(ctPath, doc);
        } else if (mode == 'ctb') {
          await CtbDocumentWriter.writeToPath(ctPath, doc);
        }
      } on Object catch (e, st) {
        developer.log(
          'Failed to save CherryTree document (JSON backup was written)',
          error: e,
          stackTrace: st,
        );
      }
    }
    return true;
  }

  NoteDocument _seedDocument() {
    final l10n = appLocalizationsForDeviceLocale();
    return NoteDocument(
      nodes: [
        NoteNode(
          id: 'seed-root',
          parentId: null,
          title: l10n.seedWelcomeTitle,
          body: l10n.seedWelcomeBody,
          sortIndex: 0,
        ),
      ],
    );
  }
}
