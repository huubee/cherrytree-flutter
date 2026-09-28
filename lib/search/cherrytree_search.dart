import '../models/note_document.dart';
import '../rich/note_body_codec.dart';

/// Configurable search options mirroring upstream CherryTree's `CtSearchOptions`.
class CherryTreeSearchOptions {
  const CherryTreeSearchOptions({
    this.query = '',
    this.matchCase = false,
    this.useRegex = false,
    this.wholeWord = false,
    this.searchInContent = true,
    this.searchInNameAndTags = true,
    this.overrideExclusions = false,
    this.onlySelectedSubnodes = false,
    this.selectedNodeId,
  });

  final String query;
  final bool matchCase;
  final bool useRegex;
  final bool wholeWord;
  final bool searchInContent;
  final bool searchInNameAndTags;
  final bool overrideExclusions;
  final bool onlySelectedSubnodes;
  final String? selectedNodeId;

  CherryTreeSearchOptions copyWith({
    String? query,
    bool? matchCase,
    bool? useRegex,
    bool? wholeWord,
    bool? searchInContent,
    bool? searchInNameAndTags,
    bool? overrideExclusions,
    bool? onlySelectedSubnodes,
    String? selectedNodeId,
  }) {
    return CherryTreeSearchOptions(
      query: query ?? this.query,
      matchCase: matchCase ?? this.matchCase,
      useRegex: useRegex ?? this.useRegex,
      wholeWord: wholeWord ?? this.wholeWord,
      searchInContent: searchInContent ?? this.searchInContent,
      searchInNameAndTags: searchInNameAndTags ?? this.searchInNameAndTags,
      overrideExclusions: overrideExclusions ?? this.overrideExclusions,
      onlySelectedSubnodes: onlySelectedSubnodes ?? this.onlySelectedSubnodes,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
    );
  }
}

/// Represents a match found within a specific node.
class CherryTreeSearchResult {
  const CherryTreeSearchResult({
    required this.node,
    required this.path,
    this.matchInTitle = false,
    this.matchInTags = false,
    this.contentSnippet,
    this.matchCount = 1,
  });

  final NoteNode node;
  final List<String> path;
  final bool matchInTitle;
  final bool matchInTags;
  final String? contentSnippet;
  final int matchCount;

  bool get matchInContent => contentSnippet != null;
}

/// Search engine for scanning a [NoteDocument] tree with upstream CherryTree filtering rules.
class CherryTreeSearchEngine {
  const CherryTreeSearchEngine._();

  static List<CherryTreeSearchResult> search({
    required NoteDocument doc,
    required CherryTreeSearchOptions options,
  }) {
    final query = options.query.trim();
    if (query.isEmpty) return const [];

    Pattern pattern;
    if (options.useRegex) {
      try {
        pattern = RegExp(query, caseSensitive: options.matchCase);
      } on FormatException {
        // Invalid regex; fall back to exact substring search
        pattern = options.matchCase ? query : query.toLowerCase();
      }
    } else if (options.wholeWord) {
      final escaped = RegExp.escape(query);
      pattern = RegExp(
        r'\b' + escaped + r'\b',
        caseSensitive: options.matchCase,
      );
    } else {
      pattern = query;
    }

    final results = <CherryTreeSearchResult>[];

    // Determine target root nodes
    List<NoteNode> targetNodes;
    if (options.onlySelectedSubnodes && options.selectedNodeId != null) {
      final sel = doc.find(options.selectedNodeId!);
      if (sel == null) return const [];
      final descendantIds = _collectSubtreeIds(doc, sel.id);
      targetNodes = descendantIds.map((id) => doc.find(id)!).toList();
    } else {
      targetNodes = doc.nodes;
    }

    // Identify nodes whose parent hierarchy has excludeChildrenFromSearch
    final excludedByParent = <String>{};
    if (!options.overrideExclusions) {
      for (final n in doc.nodes) {
        if (n.excludeChildrenFromSearch) {
          final desc = _collectSubtreeIds(doc, n.id)..remove(n.id);
          excludedByParent.addAll(desc);
        }
      }
    }

    for (final node in targetNodes) {
      if (!options.overrideExclusions) {
        if (node.excludeMeFromSearch || excludedByParent.contains(node.id)) {
          continue;
        }
      }

      var matchInTitle = false;
      var matchInTags = false;
      String? snippet;
      var matches = 0;

      if (options.searchInNameAndTags) {
        if (_matches(node.title, pattern, options.matchCase, options.useRegex)) {
          matchInTitle = true;
          matches++;
        }
        if (node.tags.isNotEmpty &&
            _matches(node.tags, pattern, options.matchCase, options.useRegex)) {
          matchInTags = true;
          matches++;
        }
      }

      if (options.searchInContent && node.body.isNotEmpty) {
        final plainText = NoteBodyCodec.plainTextFromStorage(node.body);
        final foundSnippet = _extractSnippet(
          plainText,
          pattern,
          options.matchCase,
          options.useRegex,
        );
        if (foundSnippet != null) {
          snippet = foundSnippet;
          matches++;
        }
      }

      if (matches > 0) {
        final pathNodes = doc.pathFromRoot(node.id);
        final pathTitles = pathNodes
            .map((p) => p.title.trim().isEmpty ? 'Untitled' : p.title.trim())
            .toList();

        results.add(
          CherryTreeSearchResult(
            node: node,
            path: pathTitles,
            matchInTitle: matchInTitle,
            matchInTags: matchInTags,
            contentSnippet: snippet,
            matchCount: matches,
          ),
        );
      }
    }

    return results;
  }

  static Set<String> _collectSubtreeIds(NoteDocument doc, String rootId) {
    final result = <String>{rootId};
    void addChildren(String pid) {
      for (final child in doc.childrenOf(pid)) {
        if (result.add(child.id)) {
          addChildren(child.id);
        }
      }
    }

    addChildren(rootId);
    return result;
  }

  static bool _matches(
    String text,
    Pattern pattern,
    bool matchCase,
    bool useRegex,
  ) {
    if (pattern is RegExp) {
      return pattern.hasMatch(text);
    }
    if (!matchCase) {
      return text.toLowerCase().contains((pattern as String).toLowerCase());
    }
    return text.contains(pattern as String);
  }

  static String? _extractSnippet(
    String text,
    Pattern pattern,
    bool matchCase,
    bool useRegex, {
    int contextChars = 40,
  }) {
    int matchStart = -1;
    int matchEnd = -1;

    if (pattern is RegExp) {
      final m = pattern.firstMatch(text);
      if (m != null) {
        matchStart = m.start;
        matchEnd = m.end;
      }
    } else {
      final str = pattern as String;
      final target = matchCase ? text : text.toLowerCase();
      final query = matchCase ? str : str.toLowerCase();
      final idx = target.indexOf(query);
      if (idx != -1) {
        matchStart = idx;
        matchEnd = idx + query.length;
      }
    }

    if (matchStart == -1) return null;

    final snippetStart = (matchStart - contextChars).clamp(0, text.length);
    final snippetEnd = (matchEnd + contextChars).clamp(0, text.length);

    var snippet = text.substring(snippetStart, snippetEnd).replaceAll('\n', ' ');
    if (snippetStart > 0) snippet = '...$snippet';
    if (snippetEnd < text.length) snippet = '$snippet...';

    return snippet;
  }
}
