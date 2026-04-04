import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../l10n/l10n_utils.dart';
import '../models/note_document.dart';

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

  /// Persists [doc] to app documents. Returns `false` if the write failed.
  Future<bool> save(NoteDocument doc) async {
    try {
      final f = await _file();
      final encoder = JsonEncoder.withIndent('  ');
      await f.writeAsString(encoder.convert(doc.toJson()));
      return true;
    } on Object catch (e, st) {
      developer.log('Failed to save notes', error: e, stackTrace: st);
      return false;
    }
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
