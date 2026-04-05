import 'package:flutter/material.dart';

import '../cherrytree/cherrytree_stock_icons.dart';
import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
import '../theme/app_spacing.dart';

class TreePanel extends StatefulWidget {
  const TreePanel({
    super.key,
    required this.doc,
    required this.selectedId,
    required this.onSelect,
    required this.onAddChild,
    required this.onDelete,
  });

  final NoteDocument doc;
  final String? selectedId;
  final void Function(String id) onSelect;
  final void Function(String parentId) onAddChild;
  final void Function(String id) onDelete;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: EdgeInsets.zero,
      children: _buildLevel(context, l10n, null, 0),
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
              child: Text(
                n.title.trim().isEmpty ? l10n.untitledNote : n.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () => widget.onSelect(n.id),
            trailing: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 20,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              onSelected: (value) {
                if (value == 'add') {
                  widget.onAddChild(n.id);
                  setState(() => _expanded.add(n.id));
                }
                if (value == 'del') {
                  widget.onDelete(n.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add',
                  child: Text(l10n.menuAddChild),
                ),
                PopupMenuItem(
                  value: 'del',
                  child: Text(l10n.menuDeleteSubtree),
                ),
              ],
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
