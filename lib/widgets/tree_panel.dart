import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
import '../theme/app_spacing.dart';

class TreePanel extends StatelessWidget {
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
    // DFS traversal of the document graph to render the tree sequentially in a single ListView.
    // This avoids nested ListViews or complex slivers, keeping the layout simple and performant.
    final out = <Widget>[];
    for (final n in doc.childrenOf(parentId)) {
      final isSel = n.id == selectedId;
      out.add(
        Padding(
          padding: EdgeInsets.only(
            left: depth * AppSpacing.treeIndentStep,
          ),
          child: ListTile(
            dense: true,
            selected: isSel,
            title: Text(
              n.title.trim().isEmpty ? l10n.untitledNote : n.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onSelect(n.id),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add') onAddChild(n.id);
                if (value == 'del') onDelete(n.id);
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
      out.addAll(_buildLevel(context, l10n, n.id, depth + 1));
    }
    return out;
  }
}
