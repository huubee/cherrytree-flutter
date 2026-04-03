import 'dart:io';

import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:cherrytree_flutter/services/note_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteRepository', () {
    late Directory tempDir;

    setUp(() async {
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

    test('load reads existing JSON file', () async {
      final file = File('${tempDir.path}/notes.json');
      await file.writeAsString(
        '{"nodes":[{"id":"x","parentId":null,"title":"Hi","body":"","sortIndex":0}]}',
      );
      final repo = NoteRepository(resolveFile: () async => file);
      final loaded = await repo.load();
      expect(loaded.find('x')?.title, 'Hi');
    });
  });
}
