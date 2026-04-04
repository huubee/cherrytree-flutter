import 'package:flutter/material.dart';

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
            selected: isSel,
            leading: SizedBox(
              width: 32,
              height: 32,
              child: hasChildren
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
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
                  : null,
            ),
            title: Text(
              n.title.trim().isEmpty ? l10n.untitledNote : n.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => widget.onSelect(n.id),
            trailing: PopupMenuButton<String>(
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
