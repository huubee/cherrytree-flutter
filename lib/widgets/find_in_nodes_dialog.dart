import 'package:flutter/material.dart';

import '../cherrytree/cherrytree_stock_icons.dart';
import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
import '../search/cherrytree_search.dart';

/// Modal dialog for searching across nodes, tags, and content in a [NoteDocument].
class FindInNodesDialog extends StatefulWidget {
  const FindInNodesDialog({
    super.key,
    required this.doc,
    this.selectedNodeId,
    required this.onSelectNode,
  });

  final NoteDocument doc;
  final String? selectedNodeId;
  final ValueChanged<String> onSelectNode;

  static Future<void> show(
    BuildContext context, {
    required NoteDocument doc,
    String? selectedNodeId,
    required ValueChanged<String> onSelectNode,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => FindInNodesDialog(
        doc: doc,
        selectedNodeId: selectedNodeId,
        onSelectNode: onSelectNode,
      ),
    );
  }

  @override
  State<FindInNodesDialog> createState() => _FindInNodesDialogState();
}

class _FindInNodesDialogState extends State<FindInNodesDialog> {
  late final TextEditingController _queryController;
  late final FocusNode _queryFocus;

  bool _matchCase = false;
  bool _wholeWord = false;
  bool _useRegex = false;
  bool _searchInContent = true;
  bool _searchInNameAndTags = true;
  bool _overrideExclusions = false;
  bool _onlySelectedSubnodes = false;

  List<CherryTreeSearchResult> _results = [];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _queryFocus = FocusNode();
    _queryController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onSearchChanged);
    _queryController.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _queryController.text;
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    final opts = CherryTreeSearchOptions(
      query: query,
      matchCase: _matchCase,
      wholeWord: _wholeWord,
      useRegex: _useRegex,
      searchInContent: _searchInContent,
      searchInNameAndTags: _searchInNameAndTags,
      overrideExclusions: _overrideExclusions,
      onlySelectedSubnodes: _onlySelectedSubnodes,
      selectedNodeId: widget.selectedNodeId,
    );

    setState(() {
      _results = CherryTreeSearchEngine.search(doc: widget.doc, options: opts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isQueryEmpty = _queryController.text.trim().isEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog header
              Row(
                children: [
                  const Icon(Icons.search, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.searchTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search input box
              TextField(
                controller: _queryController,
                focusNode: _queryFocus,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _queryController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _queryController.clear();
                            _queryFocus.requestFocus();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),

              // Search option filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.searchMatchCase),
                      selected: _matchCase,
                      onSelected: (v) {
                        _matchCase = v;
                        _onSearchChanged();
                      },
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: Text(l10n.searchWholeWord),
                      selected: _wholeWord,
                      onSelected: (v) {
                        _wholeWord = v;
                        _onSearchChanged();
                      },
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: Text(l10n.searchRegex),
                      selected: _useRegex,
                      onSelected: (v) {
                        _useRegex = v;
                        _onSearchChanged();
                      },
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: Text(l10n.searchInContent),
                      selected: _searchInContent,
                      onSelected: (v) {
                        _searchInContent = v;
                        _onSearchChanged();
                      },
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: Text(l10n.searchInNameAndTags),
                      selected: _searchInNameAndTags,
                      onSelected: (v) {
                        _searchInNameAndTags = v;
                        _onSearchChanged();
                      },
                    ),
                    if (widget.selectedNodeId != null) ...[
                      const SizedBox(width: 6),
                      FilterChip(
                        label: Text(l10n.searchSubnodesOnly),
                        selected: _onlySelectedSubnodes,
                        onSelected: (v) {
                          _onlySelectedSubnodes = v;
                          _onSearchChanged();
                        },
                      ),
                    ],
                    const SizedBox(width: 6),
                    FilterChip(
                      label: Text(l10n.searchOverrideExclusions),
                      selected: _overrideExclusions,
                      onSelected: (v) {
                        _overrideExclusions = v;
                        _onSearchChanged();
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // Results summary bar
              if (!isQueryEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        _results.isEmpty
                            ? l10n.searchNoResults
                            : l10n.searchResultsCount(_results.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _results.isEmpty
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // Results List / Empty state
              Expanded(
                child: isQueryEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.manage_search,
                              size: 48,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.searchEmptyPrompt,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              l10n.searchNoResults,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, index) =>
                                const Divider(height: 1),
                            itemBuilder: (ctx, index) {
                              final res = _results[index];
                              final n = res.node;

                              Color? customTextColor;
                              final fg = n.foregroundColor;
                              if (fg != null && fg.isNotEmpty) {
                                try {
                                  final hex = fg.replaceAll('#', '');
                                  if (hex.length == 6) {
                                    customTextColor =
                                        Color(int.parse('FF$hex', radix: 16));
                                  }
                                } on Object {
                                  // ignore
                                }
                              }

                              return ListTile(
                                dense: true,
                                leading: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Center(
                                    child: CherrytreeStockIcons.treeIconForNode(
                                      customIconId: n.customIconId,
                                      treeDepth: res.path.length - 1,
                                      size: 20,
                                      fallback: const Icon(
                                        Icons.description_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title.trim().isEmpty
                                            ? l10n.untitledNote
                                            : n.title,
                                        style: TextStyle(
                                          fontWeight: n.isBold
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: customTextColor,
                                        ),
                                      ),
                                    ),
                                    // Match badges
                                    if (res.matchInTitle)
                                      _badge(l10n.searchBadgeTitle, theme),
                                    if (res.matchInTags)
                                      _badge(l10n.searchBadgeTag, theme),
                                    if (res.matchInContent)
                                      _badge(l10n.searchBadgeContent, theme),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (res.path.length > 1) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        res.path.join('  ›  '),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.outline,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (res.contentSnippet != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        res.contentSnippet!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () {
                                  widget.onSelectNode(n.id);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
