import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteDocument', () {
    test('childrenOf sorts by sortIndex', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'b',
            parentId: null,
            title: 'B',
            body: '',
            sortIndex: 2,
          ),
          NoteNode(
            id: 'a',
            parentId: null,
            title: 'A',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final roots = doc.childrenOf(null);
      expect(roots.map((n) => n.id).toList(), ['a', 'b']);
    });

    test('nextSortIndex returns max sibling + 1', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'x',
            parentId: null,
            title: '',
            body: '',
            sortIndex: 3,
          ),
        ],
      );
      expect(doc.nextSortIndex(null), 4);
      expect(doc.nextSortIndex('missing'), 0);
    });

    test('removeSubtree removes node and descendants', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'root',
            parentId: null,
            title: 'R',
            body: '',
            sortIndex: 0,
          ),
          NoteNode(
            id: 'c1',
            parentId: 'root',
            title: 'C1',
            body: '',
            sortIndex: 0,
          ),
          NoteNode(
            id: 'c2',
            parentId: 'c1',
            title: 'C2',
            body: '',
            sortIndex: 0,
          ),
          NoteNode(
            id: 'other',
            parentId: null,
            title: 'O',
            body: '',
            sortIndex: 1,
          ),
        ],
      );
      doc.removeSubtree('root');
      expect(doc.nodes.map((n) => n.id).toList(), ['other']);
    });

    test('pathFromRoot returns root-to-node chain', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'root',
            parentId: null,
            title: 'R',
            body: '',
            sortIndex: 0,
          ),
          NoteNode(
            id: 'mid',
            parentId: 'root',
            title: 'M',
            body: '',
            sortIndex: 0,
          ),
          NoteNode(
            id: 'leaf',
            parentId: 'mid',
            title: 'L',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final p = doc.pathFromRoot('leaf');
      expect(p.map((n) => n.id).toList(), ['root', 'mid', 'leaf']);
      expect(doc.pathFromRoot('missing'), isEmpty);
    });

    test('JSON round-trip preserves nodes', () {
      final original = NoteDocument(
        nodes: [
          NoteNode(
            id: '1',
            parentId: null,
            title: 'T',
            body: 'B',
            sortIndex: 0,
          ),
          NoteNode(
            id: '2',
            parentId: '1',
            title: 'C',
            body: '',
            sortIndex: 0,
          ),
        ],
      );
      final json = original.toJson();
      final restored = NoteDocument.fromJson(json);
      expect(restored.nodes.length, 2);
      expect(restored.find('1')?.title, 'T');
      expect(restored.find('2')?.parentId, '1');
    });
  });
}
