import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'l10n/app_localizations.dart';
import 'models/note_document.dart';
import 'services/note_repository.dart';
import 'theme/app_spacing.dart';
import 'theme/app_timing.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key, this.repository});

  /// Injected in tests; production uses app documents directory.
  final NoteRepository? repository;

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage>
    with WidgetsBindingObserver {
  late final NoteRepository _repo =
      widget.repository ?? NoteRepository();
  final _uuid = const Uuid();
  NoteDocument? _doc;
  String? _selectedId;
  bool _loading = true;
  Object? _loadError;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDocument();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_persist());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveDebounce?.cancel();
      unawaited(_persist());
    }
  }

  Future<void> _loadDocument() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final d = await _repo.load();
      if (!mounted) return;
      final roots = d.childrenOf(null);
      setState(() {
        _doc = d;
        _selectedId ??= roots.isNotEmpty ? roots.first.id : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  Future<void> _persist() async {
    final d = _doc;
    if (d == null) return;
    final ok = await _repo.save(d);
    if (!ok && mounted) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final l10n = AppLocalizations.of(context)!;
      messenger?.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  void _schedulePersistAfterEdit() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(AppTiming.saveDebounce, () {
      if (!mounted) return;
      unawaited(_persist());
    });
  }

  void _persistImmediately() {
    _saveDebounce?.cancel();
    unawaited(_persist());
  }

  void _addRoot(AppLocalizations l10n) {
    final d = _doc!;
    final id = _uuid.v4();
    d.nodes.add(NoteNode(
      id: id,
      parentId: null,
      title: l10n.newNoteTitle,
      body: '',
      sortIndex: d.nextSortIndex(null),
    ));
    setState(() => _selectedId = id);
    _persistImmediately();
  }

  void _addChild(String parentId, AppLocalizations l10n) {
    final d = _doc!;
    final id = _uuid.v4();
    d.nodes.add(NoteNode(
      id: id,
      parentId: parentId,
      title: l10n.newNoteTitle,
      body: '',
      sortIndex: d.nextSortIndex(parentId),
    ));
    setState(() => _selectedId = id);
    _persistImmediately();
  }

  void _delete(String id) {
    final d = _doc!;
    d.removeSubtree(id);
    if (_selectedId == id ||
        (_selectedId != null && d.find(_selectedId!) == null)) {
      final roots = d.childrenOf(null);
      _selectedId = roots.isNotEmpty ? roots.first.id : null;
    }
    setState(() {});
    _persistImmediately();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        body: Center(child: Text(l10n.loading)),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Text(l10n.errorWithMessage('$_loadError')),
        ),
      );
    }
    final doc = _doc!;
    final selected = _selectedId != null ? doc.find(_selectedId!) : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= AppSpacing.wideLayoutBreakpoint;
        if (wide) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.appTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.note_add_outlined),
                  tooltip: l10n.addRootNoteTooltip,
                  onPressed: () => _addRoot(l10n),
                ),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: AppSpacing.sidebarWidth,
                  child: Material(
                    elevation: 1,
                    child: _TreePanel(
                      doc: doc,
                      selectedId: _selectedId,
                      onSelect: (id) => setState(() => _selectedId = id),
                      onAddChild: (id) => _addChild(id, l10n),
                      onDelete: _delete,
                    ),
                  ),
                ),
                Expanded(
                  child: NodeEditor(
                    key: ValueKey(_selectedId),
                    node: selected,
                    onChanged: () {
                      setState(() {});
                      _schedulePersistAfterEdit();
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.note_add_outlined),
                tooltip: l10n.addRootNoteTooltip,
                onPressed: () => _addRoot(l10n),
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DrawerHeader(
                    child: Text(l10n.drawerNotesTitle),
                  ),
                  Expanded(
                    child: _TreePanel(
                      doc: doc,
                      selectedId: _selectedId,
                      onSelect: (id) {
                        setState(() => _selectedId = id);
                        Navigator.of(context).pop();
                      },
                      onAddChild: (id) => _addChild(id, l10n),
                      onDelete: _delete,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: NodeEditor(
            key: ValueKey(_selectedId),
            node: selected,
            onChanged: () {
              setState(() {});
              _schedulePersistAfterEdit();
            },
          ),
        );
      },
    );
  }
}

class _TreePanel extends StatelessWidget {
  const _TreePanel({
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

class NodeEditor extends StatefulWidget {
  const NodeEditor({
    super.key,
    required this.node,
    required this.onChanged,
  });

  final NoteNode? node;
  final VoidCallback onChanged;

  @override
  State<NodeEditor> createState() => _NodeEditorState();
}

class _NodeEditorState extends State<NodeEditor> {
  late TextEditingController _title;
  late TextEditingController _body;

  @override
  void initState() {
    super.initState();
    final n = widget.node;
    _title = TextEditingController(text: n?.title ?? '');
    _body = TextEditingController(text: n?.body ?? '');
  }

  @override
  void didUpdateWidget(covariant NodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node?.id != widget.node?.id) {
      _title.text = widget.node?.title ?? '';
      _body.text = widget.node?.body ?? '';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final n = widget.node;
    if (n == null) {
      return Center(child: Text(l10n.emptyEditorHint));
    }
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.editorPadding,
        AppSpacing.editorPadding,
        AppSpacing.editorPadding,
        AppSpacing.editorPadding + bottomSafe,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(
              labelText: l10n.fieldTitle,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              n.title = v;
              widget.onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.editorFieldGap),
          Expanded(
            child: TextField(
              controller: _body,
              decoration: InputDecoration(
                labelText: l10n.fieldBody,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (v) {
                n.body = v;
                widget.onChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}
