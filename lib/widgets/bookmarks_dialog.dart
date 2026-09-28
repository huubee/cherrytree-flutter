import 'package:flutter/material.dart';

import '../cherrytree/cherrytree_stock_icons.dart';
import '../l10n/app_localizations.dart';
import '../models/note_document.dart';

/// Modal dialog or sheet listing all bookmarked nodes with direct navigation.
class BookmarksDialog extends StatefulWidget {
  const BookmarksDialog({
    super.key,
    required this.doc,
    required this.onSelectNode,
    required this.onRemoveBookmark,
  });

  final NoteDocument doc;
  final ValueChanged<String> onSelectNode;
  final ValueChanged<String> onRemoveBookmark;

  static Future<void> show(
    BuildContext context, {
    required NoteDocument doc,
    required ValueChanged<String> onSelectNode,
    required ValueChanged<String> onRemoveBookmark,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => BookmarksDialog(
        doc: doc,
        onSelectNode: onSelectNode,
        onRemoveBookmark: onRemoveBookmark,
      ),
    );
  }

  @override
  State<BookmarksDialog> createState() => _BookmarksDialogState();
}

class _BookmarksDialogState extends State<BookmarksDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final doc = widget.doc;
    final bookmarks = doc.bookmarks;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 580),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.bookmarks, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.bookmarksTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (bookmarks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${bookmarks.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Content
              Expanded(
                child: bookmarks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 54,
                                color: theme.colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.bookmarksEmpty,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: bookmarks.length,
                        separatorBuilder: (_, index) => const Divider(height: 1),
                        itemBuilder: (ctx, index) {
                          final id = bookmarks[index];
                          final node = doc.find(id);
                          if (node == null) {
                            return const SizedBox.shrink();
                          }

                          final pathNodes = doc.pathFromRoot(node.id);
                          final pathString = pathNodes
                              .map((p) => p.title.trim().isEmpty
                                  ? l10n.untitledNote
                                  : p.title.trim())
                              .join('  ›  ');

                          Color? customTextColor;
                          final fg = node.foregroundColor;
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
                                  customIconId: node.customIconId,
                                  treeDepth: pathNodes.length - 1,
                                  size: 20,
                                  fallback: const Icon(
                                    Icons.description_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              node.title.trim().isEmpty
                                  ? l10n.untitledNote
                                  : node.title,
                              style: TextStyle(
                                fontWeight: node.isBold
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: customTextColor,
                              ),
                            ),
                            subtitle: pathNodes.length > 1
                                ? Text(
                                    pathString,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              tooltip: l10n.bookmarksRemoveTooltip,
                              iconSize: 20,
                              onPressed: () {
                                widget.onRemoveBookmark(node.id);
                                setState(() {});
                              },
                            ),
                            onTap: () {
                              widget.onSelectNode(node.id);
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
}
