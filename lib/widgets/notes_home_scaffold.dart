import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
import '../theme/app_spacing.dart';
import 'ct_app_bar.dart';
import 'node_editor.dart';
import 'tree_panel.dart';

/// Wide vs narrow [Scaffold] for the notes home screen (tree + editor).
///
/// Uses [MediaQuery] for the breakpoint — not [LayoutBuilder] — to avoid
/// overlay/layout assertions with [TreePanel] popups (see changelog).
class NotesHomeScaffold extends StatelessWidget {
  const NotesHomeScaffold({
    super.key,
    required this.doc,
    required this.selectedId,
    required this.breadcrumbSegments,
    required this.onBreadcrumbTap,
    this.tabStrip,
    required this.saveState,
    required this.onOpenSettings,
    required this.onAddRoot,
    required this.onImportCherryTree,
    required this.onExportCherryTree,
    required this.onTreeSelectWide,
    required this.onTreeSelectDrawer,
    required this.onAddChild,
    required this.onDelete,
    required this.onEditorChanged,
    required this.l10n,
  });

  final NoteDocument doc;
  final String? selectedId;
  final List<BreadcrumbSegment>? breadcrumbSegments;
  final ValueChanged<String> onBreadcrumbTap;
  final Widget? tabStrip;
  final SaveState saveState;
  final VoidCallback? onOpenSettings;
  final void Function(AppLocalizations l10n) onAddRoot;
  final VoidCallback onImportCherryTree;
  final VoidCallback onExportCherryTree;
  final void Function(String id) onTreeSelectWide;
  final void Function(String id) onTreeSelectDrawer;
  final void Function(String parentId, AppLocalizations l10n) onAddChild;
  final void Function(String id) onDelete;
  final VoidCallback onEditorChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final selected = selectedId != null ? doc.find(selectedId!) : null;
    final wide =
        MediaQuery.sizeOf(context).width >= AppSpacing.wideLayoutBreakpoint;

    final appBar = CTAppBar(
      breadcrumbSegments: breadcrumbSegments,
      onBreadcrumbTap: onBreadcrumbTap,
      tabStrip: tabStrip,
      onOpenSettings: onOpenSettings,
      onAddRoot: () => onAddRoot(l10n),
      saveState: saveState,
      onImportCherryTree: onImportCherryTree,
      onExportCherryTree: onExportCherryTree,
      leading: wide
          ? null
          : Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
    );

    final editor = NodeEditor(
      key: ValueKey(selectedId),
      node: selected,
      onChanged: onEditorChanged,
    );

    if (wide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: AppSpacing.sidebarWidth,
              child: Material(
                elevation: 1,
                child: TreePanel(
                  doc: doc,
                  selectedId: selectedId,
                  onSelect: onTreeSelectWide,
                  onAddChild: (id) => onAddChild(id, l10n),
                  onDelete: onDelete,
                ),
              ),
            ),
            Expanded(child: editor),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(child: Text(l10n.drawerNotesTitle)),
              Expanded(
                child: TreePanel(
                  doc: doc,
                  selectedId: selectedId,
                  onSelect: onTreeSelectDrawer,
                  onAddChild: (id) => onAddChild(id, l10n),
                  onDelete: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
      body: editor,
    );
  }
}
