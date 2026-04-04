import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../cherrytree/ctb_document_reader.dart';
import '../cherrytree/ctb_document_writer.dart';
import '../cherrytree/ctd_document_reader.dart';
import '../cherrytree/ctd_document_writer.dart';
import '../l10n/l10n_utils.dart';
import '../models/document_tab.dart';
import '../models/note_document.dart';
import 'document_storage_prefs.dart';
import 'tab_session_store.dart';

/// Result of [NoteRepository.loadTabs].
class TabLoadResult {
  const TabLoadResult({required this.tabs, required this.activeTabId});

  final List<DocumentTab> tabs;
  final String activeTabId;
}

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

  Future<Directory> _documentsDir() async {
    if (_resolveFile != null) {
      final f = await _resolveFile();
      return f.parent;
    }
    return getApplicationDocumentsDirectory();
  }

  Future<File> _sessionFile() async =>
      File('${(await _documentsDir()).path}/${TabSessionStore.sessionFileName}');

  Future<File> _tabFile(String tabId) async =>
      File('${(await _documentsDir()).path}/tab_$tabId.json');

  /// Loads all tabs + active id, or migrates legacy single-file storage to one tab.
  Future<TabLoadResult> loadTabs() async {
    final session = await _sessionFile();
    if (await session.exists()) {
      try {
        final text = await session.readAsString();
        final map = jsonDecode(text) as Map<String, dynamic>;
        final tabsJson = map['tabs'] as List<dynamic>? ?? [];
        final activeTabId = map['activeTabId'] as String?;
        final tabs = <DocumentTab>[];
        for (final e in tabsJson) {
          final m = Map<String, dynamic>.from(e as Map);
          final id = m['id'] as String;
          final tf = await _tabFile(id);
          NoteDocument doc;
          if (await tf.exists()) {
            final raw = await tf.readAsString();
            doc = NoteDocument.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            );
          } else {
            doc = _seedDocument();
          }
          tabs.add(
            DocumentTab(
              id: id,
              document: doc,
              selectedNodeId: m['selectedNodeId'] as String?,
              cherrytreeMode: m['cherrytreeMode'] as String?,
              cherrytreePath: m['cherrytreePath'] as String?,
              tabLabel: m['tabLabel'] as String?,
            ),
          );
        }
        if (tabs.isEmpty) {
          return _migrateLegacyToTabs();
        }
        final aid = activeTabId != null &&
                tabs.any((t) => t.id == activeTabId)
            ? activeTabId
            : tabs.first.id;
        return TabLoadResult(tabs: tabs, activeTabId: aid);
      } on Object catch (e, st) {
        developer.log('sessions_v1.json load failed, migrating', error: e, stackTrace: st);
        return _migrateLegacyToTabs();
      }
    }
    return _migrateLegacyToTabs();
  }

  Future<TabLoadResult> _migrateLegacyToTabs() async {
    final doc = await load();
    final id = const Uuid().v4();
    final roots = doc.childrenOf(null);
    final tab = DocumentTab(
      id: id,
      document: doc,
      selectedNodeId: roots.isNotEmpty ? roots.first.id : null,
      cherrytreeMode: await DocumentStoragePrefs.getCherrytreeMode(),
      cherrytreePath: await DocumentStoragePrefs.getCherrytreePath(),
    );
    final ok = await saveTab(tab);
    if (ok) {
      await saveSession([tab], tab.id);
    }
    return TabLoadResult(tabs: [tab], activeTabId: tab.id);
  }

  /// Writes [tab] JSON and best-effort CherryTree file when [DocumentTab.cherrytreePath] is set.
  Future<bool> saveTab(DocumentTab tab) async {
    try {
      final encoder = JsonEncoder.withIndent('  ');
      final f = await _tabFile(tab.id);
      await f.writeAsString(encoder.convert(tab.document.toJson()));
    } on Object catch (e, st) {
      developer.log('Failed to save tab JSON', error: e, stackTrace: st);
      return false;
    }
    final mode = tab.cherrytreeMode;
    final ctPath = tab.cherrytreePath;
    if (mode != null && ctPath != null && ctPath.isNotEmpty) {
      try {
        if (mode == 'ctd') {
          await CtdDocumentWriter.writeToFile(ctPath, tab.document);
        } else if (mode == 'ctb') {
          await CtbDocumentWriter.writeToPath(ctPath, tab.document);
        }
      } on Object catch (e, st) {
        developer.log(
          'Failed to save CherryTree document (tab JSON was written)',
          error: e,
          stackTrace: st,
        );
      }
    }
    return true;
  }

  Future<void> saveSession(List<DocumentTab> tabs, String activeTabId) async {
    final encoder = JsonEncoder.withIndent('  ');
    final map = <String, dynamic>{
      'version': 1,
      'activeTabId': activeTabId,
      'tabs': tabs
          .map(
            (t) => <String, dynamic>{
              'id': t.id,
              'selectedNodeId': t.selectedNodeId,
              'cherrytreeMode': t.cherrytreeMode,
              'cherrytreePath': t.cherrytreePath,
              'tabLabel': t.tabLabel,
            },
          )
          .toList(),
    };
    final f = await _sessionFile();
    await f.writeAsString(encoder.convert(map));
  }

  Future<void> deleteTabFile(String tabId) async {
    final f = await _tabFile(tabId);
    if (await f.exists()) {
      await f.delete();
    }
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
