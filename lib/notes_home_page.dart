import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'l10n/app_localizations.dart';
import 'models/note_document.dart';
import 'services/note_repository.dart';
import 'theme/app_spacing.dart';
import 'theme/app_timing.dart';
import 'widgets/ct_app_bar.dart';
import 'widgets/node_editor.dart';
import 'widgets/tree_panel.dart';

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
  SaveState _saveState = SaveState.idle;
  bool _isSaving = false;
  bool _saveRequested = false;

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

    if (_isSaving) {
      _saveRequested = true;
      return;
    }
    _isSaving = true;
    _saveRequested = false;

    if (mounted) {
      setState(() => _saveState = SaveState.saving);
    }

    final ok = await _repo.save(d);

    if (mounted) {
      setState(() => _saveState = ok ? SaveState.saved : SaveState.error);
      
      if (ok) {
        Timer(const Duration(seconds: 2), () {
          if (mounted && _saveState == SaveState.saved) {
             setState(() => _saveState = SaveState.idle);
          }
        });
      } else {
        final messenger = ScaffoldMessenger.maybeOf(context);
        final l10n = AppLocalizations.of(context)!;
        messenger?.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    }
    _isSaving = false;
    
    // If another save was requested while we were saving, trigger it now.
    if (_saveRequested) {
      unawaited(_persist());
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
            appBar: CTAppBar(
              onAddRoot: () => _addRoot(l10n),
              saveState: _saveState,
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: AppSpacing.sidebarWidth,
                  child: Material(
                    elevation: 1,
                    child: TreePanel(
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
          appBar: CTAppBar(
            onAddRoot: () => _addRoot(l10n),
            saveState: _saveState,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
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
                    child: TreePanel(
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
