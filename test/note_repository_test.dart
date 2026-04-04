import 'dart:io';

import 'package:cherrytree_flutter/models/document_tab.dart';
import 'package:cherrytree_flutter/models/note_document.dart';

import 'rich_test_utils.dart';
import 'package:cherrytree_flutter/services/document_storage_prefs.dart';
import 'package:cherrytree_flutter/services/note_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NoteRepository', () {
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('cherrytree_repo_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('save and load round-trip', () async {
      final file = File('${tempDir.path}/notes.json');
      final repo = NoteRepository(resolveFile: () async => file);
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'a',
            parentId: null,
            title: 'A',
            body: 'body',
            sortIndex: 0,
          ),
        ],
      );
      expect(await repo.save(doc), isTrue);
      final loaded = await repo.load();
      expect(loaded.nodes.length, 1);
      expect(loaded.find('a')?.title, 'A');
      expect(loaded.find('a')?.body, 'body');
    });

    test('save writes CherryTree .ctd when prefs point to a path', () async {
      final ctPath = '${tempDir.path}/doc.ctd';
      await DocumentStoragePrefs.setCherrytreeFile(mode: 'ctd', path: ctPath);
      final jsonFile = File('${tempDir.path}/notes.json');
      final repo = NoteRepository(resolveFile: () async => jsonFile);
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'ct-1',
            parentId: null,
            title: 'Root',
            body: 'hello',
            sortIndex: 0,
          ),
        ],
      );
      expect(await repo.save(doc), isTrue);
      expect(await File(ctPath).exists(), isTrue);
      final loaded = await repo.load();
      expect(loaded.find('ct-1')?.title, 'Root');
      expect(plainBody(loaded.find('ct-1')!.body), 'hello');
    });

    test('load reads existing JSON file', () async {
      final file = File('${tempDir.path}/notes.json');
      await file.writeAsString(
        '{"nodes":[{"id":"x","parentId":null,"title":"Hi","body":"","sortIndex":0}]}',
      );
      final repo = NoteRepository(resolveFile: () async => file);
      final loaded = await repo.load();
      expect(loaded.find('x')?.title, 'Hi');
    });

    test('loadTabs round-trips saveTab and saveSession including tabLabel', () async {
      final jsonFile = File('${tempDir.path}/notes.json');
      final repo = NoteRepository(resolveFile: () async => jsonFile);
      final doc1 = NoteDocument(
        nodes: [
          NoteNode(
            id: 'a',
            parentId: null,
            title: 'Alpha',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final doc2 = NoteDocument(
        nodes: [
          NoteNode(
            id: 'b',
            parentId: null,
            title: 'Beta',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final t1 = DocumentTab(
        id: 'id-1',
        document: doc1,
        selectedNodeId: 'a',
      );
      final t2 = DocumentTab(
        id: 'id-2',
        document: doc2,
        selectedNodeId: 'b',
        tabLabel: 'Project B',
      );
      expect(await repo.saveTab(t1), isTrue);
      expect(await repo.saveTab(t2), isTrue);
      await repo.saveSession([t1, t2], 'id-2');

      final repo2 = NoteRepository(resolveFile: () async => jsonFile);
      final r = await repo2.loadTabs();
      expect(r.tabs.length, 2);
      expect(r.activeTabId, 'id-2');
      expect(r.tabs[0].id, 'id-1');
      expect(r.tabs[0].selectedNodeId, 'a');
      expect(r.tabs[0].document.find('a')?.title, 'Alpha');
      expect(r.tabs[1].id, 'id-2');
      expect(r.tabs[1].document.find('b')?.title, 'Beta');
      expect(r.tabs[1].tabLabel, 'Project B');
    });

    test('loadTabs uses first tab when activeTabId is unknown', () async {
      final jsonFile = File('${tempDir.path}/notes.json');
      final repo = NoteRepository(resolveFile: () async => jsonFile);
      final doc1 = NoteDocument(
        nodes: [
          NoteNode(
            id: 'a',
            parentId: null,
            title: 'A',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final doc2 = NoteDocument(
        nodes: [
          NoteNode(
            id: 'b',
            parentId: null,
            title: 'B',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final t1 = DocumentTab(
        id: 'id-1',
        document: doc1,
        selectedNodeId: 'a',
      );
      final t2 = DocumentTab(
        id: 'id-2',
        document: doc2,
        selectedNodeId: 'b',
      );
      expect(await repo.saveTab(t1), isTrue);
      expect(await repo.saveTab(t2), isTrue);
      await repo.saveSession([t1, t2], 'no-such-tab');

      final repo2 = NoteRepository(resolveFile: () async => jsonFile);
      final r = await repo2.loadTabs();
      expect(r.activeTabId, 'id-1');
    });

    test('deleteTabFile removes tab JSON', () async {
      final jsonFile = File('${tempDir.path}/notes.json');
      final repo = NoteRepository(resolveFile: () async => jsonFile);
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'a',
            parentId: null,
            title: 'A',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final tab = DocumentTab(
        id: 'gone',
        document: doc,
        selectedNodeId: 'a',
      );
      expect(await repo.saveTab(tab), isTrue);
      final tabPath = File('${tempDir.path}/tab_gone.json');
      expect(await tabPath.exists(), isTrue);
      await repo.deleteTabFile('gone');
      expect(await tabPath.exists(), isFalse);
    });
  });
}
