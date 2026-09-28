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

    test('moveNodeUp and moveNodeDown reorders siblings', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'First', body: '', sortIndex: 0),
          NoteNode(id: '2', parentId: null, title: 'Second', body: '', sortIndex: 1),
          NoteNode(id: '3', parentId: null, title: 'Third', body: '', sortIndex: 2),
        ],
      );

      // Move top node up should fail
      expect(doc.moveNodeUp('1'), isFalse);

      // Move second node up
      expect(doc.moveNodeUp('2'), isTrue);
      expect(doc.childrenOf(null).map((n) => n.id).toList(), ['2', '1', '3']);

      // Move bottom node down should fail
      expect(doc.moveNodeDown('3'), isFalse);

      // Move first node down
      expect(doc.moveNodeDown('2'), isTrue);
      expect(doc.childrenOf(null).map((n) => n.id).toList(), ['1', '2', '3']);
    });

    test('indentNode and unindentNode adjust parentage and hierarchy', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'A', body: '', sortIndex: 0),
          NoteNode(id: '2', parentId: null, title: 'B', body: '', sortIndex: 1),
          NoteNode(id: '3', parentId: null, title: 'C', body: '', sortIndex: 2),
        ],
      );

      // Cannot indent first child
      expect(doc.indentNode('1'), isFalse);

      // Indent '2' under '1'
      expect(doc.indentNode('2'), isTrue);
      expect(doc.find('2')?.parentId, '1');
      expect(doc.childrenOf(null).map((n) => n.id).toList(), ['1', '3']);
      expect(doc.childrenOf('1').map((n) => n.id).toList(), ['2']);

      // Unindent '2' back to root
      expect(doc.unindentNode('2'), isTrue);
      expect(doc.find('2')?.parentId, isNull);
      expect(doc.childrenOf(null).map((n) => n.id).toList(), ['1', '2', '3']);

      // Cannot unindent a root node
      expect(doc.unindentNode('1'), isFalse);
    });

    test('sortSiblings sorts by title ascending and descending', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'Zebra', body: '', sortIndex: 0),
          NoteNode(id: '2', parentId: null, title: 'Apple', body: '', sortIndex: 1),
          NoteNode(id: '3', parentId: null, title: 'Mango', body: '', sortIndex: 2),
        ],
      );

      doc.sortSiblings(null, ascending: true);
      expect(doc.childrenOf(null).map((n) => n.title).toList(), ['Apple', 'Mango', 'Zebra']);

      doc.sortSiblings(null, ascending: false);
      expect(doc.childrenOf(null).map((n) => n.title).toList(), ['Zebra', 'Mango', 'Apple']);
    });

    test('insertSiblingAfter inserts directly after target node', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'A', body: '', sortIndex: 0),
          NoteNode(id: '2', parentId: null, title: 'C', body: '', sortIndex: 1),
        ],
      );

      final newNode = NoteNode(id: 'new', parentId: null, title: 'B', body: '', sortIndex: 0);
      doc.insertSiblingAfter('1', newNode);

      expect(doc.childrenOf(null).map((n) => n.id).toList(), ['1', 'new', '2']);
    });

    test('duplicateNode clones tree with descendants and updates IDs', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: 'root', parentId: null, title: 'My Root', body: 'Root body', sortIndex: 0),
          NoteNode(id: 'sub', parentId: 'root', title: 'Subnode', body: 'Sub body', sortIndex: 0),
        ],
      );

      var counter = 0;
      final newRootId = doc.duplicateNode('root', newIdGenerator: () => 'dup_${++counter}');

      expect(newRootId, 'dup_1');
      expect(doc.nodes.length, 4);

      final clonedRoot = doc.find('dup_1');
      expect(clonedRoot, isNotNull);
      expect(clonedRoot?.title, 'My Root (Copy)');
      expect(clonedRoot?.body, 'Root body');
      expect(clonedRoot?.parentId, isNull);

      final clonedSub = doc.find('dup_2');
      expect(clonedSub, isNotNull);
      expect(clonedSub?.title, 'Subnode');
      expect(clonedSub?.body, 'Sub body');
      expect(clonedSub?.parentId, 'dup_1');
    });

    test('toggleBookmark adds and removes bookmarks', () {
      final doc = NoteDocument(
        nodes: [
          NoteNode(id: '1', parentId: null, title: 'A', body: '', sortIndex: 0),
        ],
      );

      expect(doc.isBookmarked('1'), isFalse);
      doc.toggleBookmark('1');
      expect(doc.isBookmarked('1'), isTrue);
      expect(doc.bookmarks, ['1']);

      doc.toggleBookmark('1');
      expect(doc.isBookmarked('1'), isFalse);
      expect(doc.bookmarks, isEmpty);
    });
  });
}
