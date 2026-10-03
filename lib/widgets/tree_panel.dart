import 'dart:async';

import 'package:flutter/material.dart';

import '../cherrytree/cherrytree_stock_icons.dart';
import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
import '../theme/app_spacing.dart';
import 'export_dialog.dart';

class TreePanel extends StatefulWidget {
  const TreePanel({
    super.key,
    required this.doc,
    required this.selectedId,
    required this.onSelect,
    required this.onAddChild,
    this.onAddSibling,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
    this.onIndent,
    this.onUnindent,
    this.onSort,
    this.onToggleBookmark,
    this.onDuplicate,
    this.onNodeProperties,
  });

  final NoteDocument doc;
  final String? selectedId;
  final void Function(String id) onSelect;
  final void Function(String parentId) onAddChild;
  final void Function(String targetId)? onAddSibling;
  final void Function(String id) onDelete;
  final void Function(String id)? onMoveUp;
  final void Function(String id)? onMoveDown;
  final void Function(String id)? onIndent;
  final void Function(String id)? onUnindent;
  final void Function(String? parentId, bool ascending)? onSort;
  final void Function(String id)? onToggleBookmark;
  final void Function(String id)? onDuplicate;
  final void Function(String id)? onNodeProperties;

  @override
  State<TreePanel> createState() => _TreePanelState();
}

class _TreePanelState extends State<TreePanel> {
  /// Parent node ids whose children are visible. Defaults to all parents expanded.
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _expanded.addAll(_parentIdsWithChildren(widget.doc));
  }

  @override
  void didUpdateWidget(TreePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doc != widget.doc) {
      _expanded
        ..clear()
        ..addAll(_parentIdsWithChildren(widget.doc));
    } else {
      _expanded.removeWhere((id) => widget.doc.find(id) == null);
    }
  }

  static Set<String> _parentIdsWithChildren(NoteDocument doc) {
    final ids = <String>{};
    for (final n in doc.nodes) {
      if (doc.childrenOf(n.id).isNotEmpty) {
        ids.add(n.id);
      }
    }
    return ids;
  }

  void expandAll() {
    setState(() {
      _expanded.addAll(_parentIdsWithChildren(widget.doc));
    });
  }

  void collapseAll() {
    setState(() {
      _expanded.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final toolbar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.drawerNotesTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.unfold_more, size: 18),
            tooltip: l10n.treeExpandAll,
            visualDensity: VisualDensity.compact,
            onPressed: expandAll,
          ),
          IconButton(
            icon: const Icon(Icons.unfold_less, size: 18),
            tooltip: l10n.treeCollapseAll,
            visualDensity: VisualDensity.compact,
            onPressed: collapseAll,
          ),
          if (widget.onSort != null)
            IconButton(
              icon: const Icon(Icons.sort_by_alpha, size: 18),
              tooltip: l10n.menuSortAsc,
              visualDensity: VisualDensity.compact,
              onPressed: () => widget.onSort!(null, true),
            ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight && constraints.maxHeight < 56) {
          return ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minHeight: 0,
              maxHeight: 56,
              child: toolbar,
            ),
          );
        }
        return Column(
          children: [
            toolbar,
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _buildLevel(context, l10n, null, 0),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildLevel(
    BuildContext context,
    AppLocalizations l10n,
    String? parentId,
    int depth,
  ) {
    final out = <Widget>[];
    for (final n in widget.doc.childrenOf(parentId)) {
      final isSel = n.id == widget.selectedId;
      final children = widget.doc.childrenOf(n.id);
      final hasChildren = children.isNotEmpty;
      final isExpanded = hasChildren && _expanded.contains(n.id);

      final isBookmarked = widget.doc.isBookmarked(n.id);
      Color? customTextColor;
      if (n.foregroundColor != null && n.foregroundColor!.isNotEmpty) {
        var c = n.foregroundColor!.trim();
        if (c.startsWith('#')) c = c.substring(1);
        final rgb = int.tryParse(c, radix: 16);
        if (rgb != null) {
          customTextColor = Color(0xff000000 | rgb);
        }
      }

      out.add(
        Padding(
          padding: EdgeInsets.only(
            left: depth * AppSpacing.treeIndentStep,
          ),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            horizontalTitleGap: 6,
            minLeadingWidth: 48,
            selected: isSel,
            leading: SizedBox(
              width: 50,
              height: 32,
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 28,
                    child: Center(
                      child: CherrytreeStockIcons.treeIconForNode(
                        customIconId: n.customIconId,
                        treeDepth: depth,
                        size: 22,
                        fallback: Icon(
                          Icons.description_outlined,
                          size: 22,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (hasChildren)
                    IconButton(
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(28, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 22,
                      ),
                      tooltip: isExpanded
                          ? MaterialLocalizations.of(context)
                              .expandedIconTapHint
                          : MaterialLocalizations.of(context)
                              .collapsedIconTapHint,
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expanded.remove(n.id);
                          } else {
                            _expanded.add(n.id);
                          }
                        });
                      },
                    )
                  else
                    const SizedBox(width: 28, height: 32),
                ],
              ),
            ),
            title: Tooltip(
              message:
                  n.title.trim().isEmpty ? l10n.untitledNote : n.title.trim(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      n.title.trim().isEmpty ? l10n.untitledNote : n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            n.isBold ? FontWeight.bold : FontWeight.normal,
                        color: customTextColor,
                      ),
                    ),
                  ),
                  if (n.isReadOnly) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                  if (isBookmarked) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.bookmark,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ],
                ],
              ),
            ),
            onTap: () => widget.onSelect(n.id),
            trailing: SizedBox(
              width: 28,
              height: 28,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 20,
                onSelected: (value) {
                switch (value) {
                  case 'add':
                    widget.onAddChild(n.id);
                    setState(() => _expanded.add(n.id));
                    break;
                  case 'add_sibling':
                    widget.onAddSibling?.call(n.id);
                    break;
                  case 'move_up':
                    widget.onMoveUp?.call(n.id);
                    break;
                  case 'move_down':
                    widget.onMoveDown?.call(n.id);
                    break;
                  case 'indent':
                    widget.onIndent?.call(n.id);
                    break;
                  case 'unindent':
                    widget.onUnindent?.call(n.id);
                    break;
                  case 'sort_asc':
                    widget.onSort?.call(n.id, true);
                    break;
                  case 'sort_desc':
                    widget.onSort?.call(n.id, false);
                    break;
                  case 'bookmark':
                    widget.onToggleBookmark?.call(n.id);
                    break;
                  case 'duplicate':
                    widget.onDuplicate?.call(n.id);
                    break;
                  case 'properties':
                    widget.onNodeProperties?.call(n.id);
                    break;
                  case 'export':
                    unawaited(ExportDialog.show(
                      context,
                      doc: widget.doc,
                      selectedNodeId: n.id,
                    ));
                    break;
                  case 'del':
                    widget.onDelete(n.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.menuAddChild),
                    ],
                  ),
                ),
                if (widget.onAddSibling != null)
                  PopupMenuItem(
                    value: 'add_sibling',
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuAddSibling),
                      ],
                    ),
                  ),
                const PopupMenuDivider(),
                if (widget.onMoveUp != null)
                  PopupMenuItem(
                    value: 'move_up',
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuMoveUp),
                      ],
                    ),
                  ),
                if (widget.onMoveDown != null)
                  PopupMenuItem(
                    value: 'move_down',
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_downward, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuMoveDown),
                      ],
                    ),
                  ),
                if (widget.onIndent != null)
                  PopupMenuItem(
                    value: 'indent',
                    child: Row(
                      children: [
                        const Icon(Icons.format_indent_increase, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuIndent),
                      ],
                    ),
                  ),
                if (widget.onUnindent != null)
                  PopupMenuItem(
                    value: 'unindent',
                    child: Row(
                      children: [
                        const Icon(Icons.format_indent_decrease, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuUnindent),
                      ],
                    ),
                  ),
                if (widget.onSort != null && hasChildren) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'sort_asc',
                    child: Row(
                      children: [
                        const Icon(Icons.sort_by_alpha, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuSortAsc),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'sort_desc',
                    child: Row(
                      children: [
                        const Icon(Icons.sort_by_alpha, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuSortDesc),
                      ],
                    ),
                  ),
                ],
                const PopupMenuDivider(),
                if (widget.onToggleBookmark != null)
                  PopupMenuItem(
                    value: 'bookmark',
                    child: Row(
                      children: [
                        Icon(
                          isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.menuToggleBookmark),
                      ],
                    ),
                  ),
                if (widget.onDuplicate != null)
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        const Icon(Icons.copy, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuDuplicate),
                      ],
                    ),
                  ),
                if (widget.onNodeProperties != null)
                  PopupMenuItem(
                    value: 'properties',
                    child: Row(
                      children: [
                        const Icon(Icons.tune, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.menuNodeProperties),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(Icons.ios_share_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.exportActionTitle),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'del',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.menuDeleteSubtree),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      if (hasChildren && isExpanded) {
        out.addAll(_buildLevel(context, l10n, n.id, depth + 1));
      }
    }
    return out;
  }
}
