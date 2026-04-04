import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'l10n/app_localizations.dart';
import 'models/document_tab.dart';
import 'models/note_document.dart';
import 'notes/cherrytree_file_actions.dart';
import 'services/note_repository.dart';
import 'settings_page.dart';
import 'theme/app_timing.dart';
import 'widgets/ct_app_bar.dart';
import 'widgets/notes_home_scaffold.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key, this.repository, this.onSetUseDarkTheme});

  /// Injected in tests; production uses app documents directory.
  final NoteRepository? repository;

  /// Persists light/dark theme; used by [SettingsPage].
  final Future<void> Function(bool useDarkTheme)? onSetUseDarkTheme;

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final NoteRepository _repo = widget.repository ?? NoteRepository();
  final _uuid = const Uuid();
  List<DocumentTab> _tabs = [];
  int _activeTabIndex = 0;
  TabController? _tabController;
  bool _loading = true;
  Object? _loadError;
  Timer? _saveDebounce;
  SaveState _saveState = SaveState.idle;
  bool _isSaving = false;
  bool _saveRequested = false;

  DocumentTab get _activeTab => _tabs[_activeTabIndex];
  NoteDocument get _doc => _activeTab.document;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDocument();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
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

  void _recreateTabController({int? initialIndex}) {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    if (_tabs.isEmpty) {
      _tabController = null;
      return;
    }
    final idx = (initialIndex ?? _activeTabIndex).clamp(0, _tabs.length - 1);
    _tabController = TabController(
      length: _tabs.length,
      initialIndex: idx,
      vsync: this,
    );
    _activeTabIndex = _tabController!.index;
    _tabController!.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final c = _tabController;
    if (c == null || c.indexIsChanging) return;
    final i = c.index;
    if (i == _activeTabIndex) return;
    unawaited(_switchToTabIndex(i));
  }

  Future<void> _switchToTabIndex(int i) async {
    if (i < 0 || i >= _tabs.length || i == _activeTabIndex) return;
    await _repo.saveTab(_tabs[_activeTabIndex]);
    if (!mounted) return;
    setState(() => _activeTabIndex = i);
    await _repo.saveSession(_tabs, _tabs[i].id);
  }

  Future<void> _loadDocument() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final result = await _repo.loadTabs();
      if (!mounted) return;
      setState(() {
        _tabs = result.tabs;
        _activeTabIndex = result.tabs.indexWhere((t) => t.id == result.activeTabId);
        if (_activeTabIndex < 0) _activeTabIndex = 0;
        _recreateTabController();
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
    if (_tabs.isEmpty) return;

    if (_isSaving) {
      _saveRequested = true;
      return;
    }
    _isSaving = true;
    _saveRequested = false;

    if (mounted) {
      setState(() => _saveState = SaveState.saving);
    }

    final t = _activeTab;
    final ok = await _repo.saveTab(t);
    await _repo.saveSession(_tabs, t.id);

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

  Future<void> _addNewTab(AppLocalizations l10n) async {
    if (_tabs.isEmpty) return;
    await _repo.saveTab(_tabs[_activeTabIndex]);
    if (!mounted) return;
    final id = _uuid.v4();
    final doc = NoteDocument(
      nodes: [
        NoteNode(
          id: _uuid.v4(),
          parentId: null,
          title: l10n.newNoteTitle,
          body: '',
          sortIndex: 0,
        ),
      ],
    );
    final tab = DocumentTab(
      id: id,
      document: doc,
      selectedNodeId: doc.childrenOf(null).first.id,
    );
    setState(() {
      _tabs.add(tab);
      _activeTabIndex = _tabs.length - 1;
      _recreateTabController(initialIndex: _activeTabIndex);
    });
    await _repo.saveSession(_tabs, tab.id);
    await _repo.saveTab(tab);
  }

  Future<void> _closeTab(int index) async {
    if (_tabs.length <= 1) return;
    await _repo.saveTab(_tabs[index]);
    final oldActive = _activeTabIndex;
    final removed = _tabs.removeAt(index);
    await _repo.deleteTabFile(removed.id);
    final newActiveIndex = () {
      if (index < oldActive) {
        return oldActive - 1;
      }
      if (index == oldActive) {
        return index >= _tabs.length ? _tabs.length - 1 : index;
      }
      return oldActive;
    }();
    if (!mounted) return;
    setState(() {
      _activeTabIndex = newActiveIndex;
      _recreateTabController(initialIndex: newActiveIndex);
    });
    await _repo.saveSession(_tabs, _tabs[newActiveIndex].id);
  }

  void _addRoot(AppLocalizations l10n) {
    final d = _doc;
    final id = _uuid.v4();
    d.nodes.add(
      NoteNode(
        id: id,
        parentId: null,
        title: l10n.newNoteTitle,
        body: '',
        sortIndex: d.nextSortIndex(null),
      ),
    );
    setState(() => _activeTab.selectedNodeId = id);
    _persistImmediately();
  }

  void _addChild(String parentId, AppLocalizations l10n) {
    final d = _doc;
    final id = _uuid.v4();
    d.nodes.add(
      NoteNode(
        id: id,
        parentId: parentId,
        title: l10n.newNoteTitle,
        body: '',
        sortIndex: d.nextSortIndex(parentId),
      ),
    );
    setState(() => _activeTab.selectedNodeId = id);
    _persistImmediately();
  }

  void _delete(String id) {
    final d = _doc;
    d.removeSubtree(id);
    if (_activeTab.selectedNodeId == id ||
        (_activeTab.selectedNodeId != null &&
            d.find(_activeTab.selectedNodeId!) == null)) {
      final roots = d.childrenOf(null);
      _activeTab.selectedNodeId = roots.isNotEmpty ? roots.first.id : null;
    }
    setState(() {});
    _persistImmediately();
  }

  List<BreadcrumbSegment>? _breadcrumbSegments(
    AppLocalizations l10n,
    NoteDocument doc,
    String? selectedId,
  ) {
    if (selectedId == null) return null;
    final path = doc.pathFromRoot(selectedId);
    if (path.isEmpty) return null;
    return path
        .map(
          (n) => BreadcrumbSegment(
            id: n.id,
            label: n.title.trim().isEmpty ? l10n.untitledNote : n.title,
          ),
        )
        .toList();
  }

  void _openSettings() {
    final setter = widget.onSetUseDarkTheme;
    if (setter == null) return;
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (ctx) => SettingsPage(onSetUseDarkTheme: setter),
        ),
      ),
    );
  }

  Future<void> _importCherryTree() async {
    final outcome = await CherrytreeFileActions.pickAndReadCherryTreeImport(
      context,
    );
    if (outcome == null || !mounted) return;
    final target = await CherrytreeFileActions.showImportTabTargetDialog(
      context,
    );
    if (target == null || !mounted) return;

    if (target == CherrytreeImportTabTarget.replaceCurrent) {
      final newTab = CherrytreeFileActions.documentTabFromImport(
        _activeTab.id,
        outcome,
      );
      setState(() {
        _tabs[_activeTabIndex] = newTab;
      });
    } else {
      await _repo.saveTab(_activeTab);
      if (!mounted) return;
      final newTab = CherrytreeFileActions.documentTabFromImport(
        _uuid.v4(),
        outcome,
      );
      setState(() {
        _tabs.add(newTab);
        _activeTabIndex = _tabs.length - 1;
        _recreateTabController(initialIndex: _activeTabIndex);
      });
    }
    _saveDebounce?.cancel();
    await _persist();
    if (!mounted) return;
    if (outcome.result.hasWarnings) {
      await CherrytreeFileActions.showImportWarningsDialog(
        context,
        outcome.result.warnings,
      );
    }
  }

  Future<void> _exportCherryTree() async {
    await CherrytreeFileActions.exportDocument(context, _doc);
  }

  void _onEditorChanged() {
    setState(() {});
    _schedulePersistAfterEdit();
  }

  String _tabTitle(AppLocalizations l10n, DocumentTab t) {
    final label = t.tabLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    final roots = t.document.childrenOf(null);
    if (roots.isEmpty) return l10n.untitledNote;
    final n = roots.first;
    return n.title.trim().isEmpty ? l10n.untitledNote : n.title;
  }

  Future<void> _renameTab(int index) async {
    if (index < 0 || index >= _tabs.length) return;
    final l10n = AppLocalizations.of(context)!;
    final t = _tabs[index];
    final controller = TextEditingController(text: _tabTitle(l10n, t));
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameTabTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.renameTabDescription,
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.renameTabFieldLabel,
              ),
              autofocus: true,
              onSubmitted: (v) => Navigator.pop(ctx, v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.importCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.renameTabSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || result == null) return;
    final trimmed = result.trim();
    setState(() {
      _tabs[index].tabLabel = trimmed.isEmpty ? null : trimmed;
    });
    _persistImmediately();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(body: Center(child: Text(l10n.loading)));
    }
    if (_loadError != null) {
      return Scaffold(
        body: Center(child: Text(l10n.errorWithMessage('$_loadError'))),
      );
    }
    final tc = _tabController;
    if (_tabs.isEmpty || tc == null) {
      return Scaffold(body: Center(child: Text(l10n.noOpenDocuments)));
    }

    final doc = _doc;
    final selectedId = _activeTab.selectedNodeId;
    final breadcrumbSegments = _breadcrumbSegments(l10n, doc, selectedId);
    final theme = Theme.of(context);

    final tabStrip = Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TabBar(
              controller: tc,
              isScrollable: true,
              tabs: [
                for (var i = 0; i < _tabs.length; i++)
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Tooltip(
                            message: l10n.renameTabTooltip,
                            child: GestureDetector(
                              onLongPress: () => unawaited(_renameTab(i)),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  _tabTitle(l10n, _tabs[i]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_tabs.length > 1)
                          Tooltip(
                            message: l10n.closeTabTooltip,
                            child: InkWell(
                              onTap: () => unawaited(_closeTab(i)),
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 4,
                                ),
                                child: Icon(Icons.close, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.newTabTooltip,
            icon: const Icon(Icons.add),
            onPressed: () => unawaited(_addNewTab(l10n)),
          ),
        ],
      ),
    );

    return NotesHomeScaffold(
      doc: doc,
      selectedId: selectedId,
      breadcrumbSegments: breadcrumbSegments,
      onBreadcrumbTap: (id) => setState(() => _activeTab.selectedNodeId = id),
      tabStrip: tabStrip,
      saveState: _saveState,
      onOpenSettings: widget.onSetUseDarkTheme != null ? _openSettings : null,
      onAddRoot: _addRoot,
      onImportCherryTree: () {
        unawaited(_importCherryTree());
      },
      onExportCherryTree: () {
        unawaited(_exportCherryTree());
      },
      onTreeSelectWide: (id) => setState(() => _activeTab.selectedNodeId = id),
      onTreeSelectDrawer: (id) {
        setState(() => _activeTab.selectedNodeId = id);
        Navigator.of(context).pop();
      },
      onAddChild: _addChild,
      onDelete: _delete,
      onEditorChanged: _onEditorChanged,
      l10n: l10n,
    );
  }
}
