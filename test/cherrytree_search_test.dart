import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:cherrytree_flutter/search/cherrytree_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CherryTreeSearchEngine', () {
    late NoteDocument doc;

    setUp(() {
      doc = NoteDocument(
        nodes: [
          NoteNode(
            id: 'root',
            parentId: null,
            title: 'Programming Notes',
            body: 'Dart and Flutter development environment notes.',
            sortIndex: 0,
            tags: 'code dev mobile',
          ),
          NoteNode(
            id: 'child1',
            parentId: 'root',
            title: 'Dart Language Basics',
            body: 'Variables, functions, classes and patterns in Dart.',
            sortIndex: 0,
            tags: 'dart oop',
          ),
          NoteNode(
            id: 'child2',
            parentId: 'root',
            title: 'Secrets & Passwords',
            body: 'Sensitive API keys and deployment credentials.',
            sortIndex: 1,
            excludeMeFromSearch: true,
          ),
          NoteNode(
            id: 'parent_excl',
            parentId: null,
            title: 'Archived Projects',
            body: 'Old notes',
            sortIndex: 1,
            excludeChildrenFromSearch: true,
          ),
          NoteNode(
            id: 'archived_sub',
            parentId: 'parent_excl',
            title: 'Legacy Python Script',
            body: 'Ancient scripts from 2015.',
            sortIndex: 0,
          ),
        ],
      );
    });

    test('finds matches in title, tags, and content', () {
      final results = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'Dart'),
      );

      expect(results.length, 2);
      expect(results[0].node.id, 'root');
      expect(results[0].matchInContent, isTrue);
      expect(results[0].contentSnippet, contains('Dart and Flutter'));

      expect(results[1].node.id, 'child1');
      expect(results[1].matchInTitle, isTrue);
      expect(results[1].matchInTags, isTrue);
      expect(results[1].matchInContent, isTrue);
    });

    test('respects matchCase option', () {
      final caseInsensitive = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'dart', matchCase: false),
      );
      expect(caseInsensitive.length, 2);

      final caseSensitive = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'dart', matchCase: true),
      );
      // In child1, tags has lowercase 'dart'
      expect(caseSensitive.length, 1);
      expect(caseSensitive.first.node.id, 'child1');
      expect(caseSensitive.first.matchInTags, isTrue);
      expect(caseSensitive.first.matchInTitle, isFalse);
    });

    test('respects wholeWord option', () {
      final partial = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'dev', wholeWord: false),
      );
      // 'development' in root content and 'dev' in root tags
      expect(partial.length, 1);

      final whole = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'dev', wholeWord: true),
      );
      expect(whole.length, 1);
      expect(whole.first.matchInTags, isTrue);
    });

    test('respects regular expression queries', () {
      final regexResults = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(
          query: r'P\w+ Notes',
          useRegex: true,
        ),
      );
      expect(regexResults.length, 1);
      expect(regexResults.first.node.id, 'root');
    });

    test('respects search exclusions and overrideExclusions flag', () {
      // Searching for 'keys' in child2 (excludeMeFromSearch = true)
      final withoutOverride = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'keys', overrideExclusions: false),
      );
      expect(withoutOverride, isEmpty);

      final withOverride = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'keys', overrideExclusions: true),
      );
      expect(withOverride.length, 1);
      expect(withOverride.first.node.id, 'child2');

      // Searching for 'Ancient' in archived_sub (parent has excludeChildrenFromSearch = true)
      final childExcluded = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'Ancient', overrideExclusions: false),
      );
      expect(childExcluded, isEmpty);

      final childOverridden = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'Ancient', overrideExclusions: true),
      );
      expect(childOverridden.length, 1);
      expect(childOverridden.first.node.id, 'archived_sub');
    });

    test('scopes search to selected subnodes when requested', () {
      final all = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'Dart'),
      );
      expect(all.length, 2);

      final scoped = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(
          query: 'Dart',
          onlySelectedSubnodes: true,
          selectedNodeId: 'child1',
        ),
      );
      expect(scoped.length, 1);
      expect(scoped.first.node.id, 'child1');
    });

    test('formats path breadcrumb for results', () {
      final results = CherryTreeSearchEngine.search(
        doc: doc,
        options: const CherryTreeSearchOptions(query: 'Basics'),
      );
      expect(results.length, 1);
      expect(results.first.path, ['Programming Notes', 'Dart Language Basics']);
    });
  });
}
