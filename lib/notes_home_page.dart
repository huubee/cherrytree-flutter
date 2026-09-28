import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'l10n/app_localizations.dart';
import 'models/document_tab.dart';
import 'models/note_document.dart';
import 'notes/cherrytree_file_actions.dart';
import 'services/note_repository.dart';
import 'settings_page.dart';
import 'theme/app_timing.dart';
import 'widgets/bookmarks_dialog.dart';
import 'widgets/ct_app_bar.dart';
import 'widgets/find_in_nodes_dialog.dart';
import 'widgets/node_properties_dialog.dart';
import 'widgets/notes_home_scaffold.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({
    super.key,
    this.repository,
    this.onSetUseDarkTheme,
    this.useSplitLayout = false,
    this.splitLayoutRatioVertical = 0.33,
    this.splitLayoutRatioHorizontal = 0.4,
    this.onSetUseSplitLayout,
    this.onSetSplitLayoutRatioVertical,
    this.onSetSplitLayoutRatioHorizontal,
    this.appLocaleCode,
    this.onSetAppLocale,
  });

  /// Injected in tests; production uses app documents directory.
  final NoteRepository? repository;

  /// Persists light/dark theme; used by [SettingsPage].
  final Future<void> Function(bool useDarkTheme)? onSetUseDarkTheme;

  final bool useSplitLayout;
  final double splitLayoutRatioVertical;
  final double splitLayoutRatioHorizontal;
  final Future<void> Function(bool useSplitLayout)? onSetUseSplitLayout;
  final Future<void> Function(double ratio)? onSetSplitLayoutRatioVertical;
  final Future<void> Function(double ratio)? onSetSplitLayoutRatioHorizontal;
  final String? appLocaleCode;
  final Future<void> Function(String? code)? onSetAppLocale;

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
    // Do not call [_persist] here: it uses [setState], which is invalid while the
    // element is unmounting (assertion: ElementLifecycle.defunct).
    unawaited(_flushSaveToDisk());
    super.dispose();
  }

  /// Best-effort save without UI updates. Used from [dispose] only.
  Future<void> _flushSaveToDisk() async {
    if (_tabs.isEmpty) return;
    try {
      final t = _activeTab;
      await _repo.saveTab(t);
      await _repo.saveSession(_tabs, t.id);
    } on Object {
      // ignore
    }
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
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final doc = NoteDocument(
      nodes: [
        NoteNode(
          id: _uuid.v4(),
          parentId: null,
          title: l10n.newNoteTitle,
          body: '',
          sortIndex: 0,
          tsCreation: now,
          tsLastSave: now,
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
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    d.nodes.add(
      NoteNode(
        id: id,
        parentId: null,
        title: l10n.newNoteTitle,
        body: '',
        sortIndex: d.nextSortIndex(null),
        tsCreation: now,
        tsLastSave: now,
      ),
    );
    setState(() => _activeTab.selectedNodeId = id);
    _persistImmediately();
  }

  void _addChild(String parentId, AppLocalizations l10n) {
    final d = _doc;
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    d.nodes.add(
      NoteNode(
        id: id,
        parentId: parentId,
        title: l10n.newNoteTitle,
        body: '',
        sortIndex: d.nextSortIndex(parentId),
        tsCreation: now,
        tsLastSave: now,
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

  void _addSibling(String targetId, AppLocalizations l10n) {
    final d = _doc;
    final target = d.find(targetId);
    if (target == null) return;
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final newNode = NoteNode(
      id: id,
      parentId: target.parentId,
      title: l10n.newNoteTitle,
      body: '',
      sortIndex: target.sortIndex + 1,
      tsCreation: now,
      tsLastSave: now,
    );
    d.insertSiblingAfter(targetId, newNode);
    setState(() => _activeTab.selectedNodeId = id);
    _persistImmediately();
  }

  void _moveUp(String id) {
    if (_doc.moveNodeUp(id)) {
      setState(() {});
      _persistImmediately();
    }
  }

  void _moveDown(String id) {
    if (_doc.moveNodeDown(id)) {
      setState(() {});
      _persistImmediately();
    }
  }

  void _indent(String id) {
    if (_doc.indentNode(id)) {
      setState(() {});
      _persistImmediately();
    }
  }

  void _unindent(String id) {
    if (_doc.unindentNode(id)) {
      setState(() {});
      _persistImmediately();
    }
  }

  void _sort(String? parentId, bool ascending) {
    _doc.sortSiblings(parentId, ascending: ascending);
    setState(() {});
    _persistImmediately();
  }

  void _toggleBookmark(String id) {
    setState(() {
      _doc.toggleBookmark(id);
    });
    _persistImmediately();
  }

  void _duplicate(String id) {
    final newId = _doc.duplicateNode(id, newIdGenerator: () => _uuid.v4());
    if (newId != null) {
      setState(() => _activeTab.selectedNodeId = newId);
      _persistImmediately();
    }
  }

  Future<void> _nodeProperties(String id) async {
    final n = _doc.find(id);
    if (n == null) return;
    final saved = await NodePropertiesDialog.show(context, node: n);
    if (saved == true && mounted) {
      setState(() {});
      _persistImmediately();
    }
  }

  void _openSearch() {
    unawaited(
      FindInNodesDialog.show(
        context,
        doc: _doc,
        selectedNodeId: _activeTab.selectedNodeId,
        onSelectNode: (id) => setState(() => _activeTab.selectedNodeId = id),
      ),
    );
  }

  void _openBookmarks() {
    unawaited(
      BookmarksDialog.show(
        context,
        doc: _doc,
        onSelectNode: (id) => setState(() => _activeTab.selectedNodeId = id),
        onRemoveBookmark: (id) {
          setState(() => _doc.removeBookmark(id));
          _persistImmediately();
        },
      ),
    );
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
          builder: (ctx) => SettingsPage(
            onSetUseDarkTheme: setter,
            useSplitLayout: widget.useSplitLayout,
            onSetUseSplitLayout: widget.onSetUseSplitLayout,
            appLocaleCode: widget.appLocaleCode,
            onSetAppLocale: widget.onSetAppLocale,
          ),
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
    final selId = _activeTab.selectedNodeId;
    if (selId != null) {
      _doc.find(selId)?.tsLastSave =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
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
                        // Scrollable [TabBar] has no built-in tab separators; thin rules
                        // between tabs improve scanability. Skip before the first tab so the
                        // strip does not start with a stray line at the scroll edge.
                        if (i > 0)
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(end: 8),
                            child: SizedBox(
                              height: 22,
                              child: VerticalDivider(
                                width: 1,
                                thickness: 1,
                                indent: 2,
                                endIndent: 2,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                          ),
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

    final scaffold = NotesHomeScaffold(
      doc: doc,
      selectedId: selectedId,
      breadcrumbSegments: breadcrumbSegments,
      onBreadcrumbTap: (id) => setState(() => _activeTab.selectedNodeId = id),
      tabStrip: tabStrip,
      saveState: _saveState,
      onOpenSettings: widget.onSetUseDarkTheme != null ? _openSettings : null,
      useSplitLayout: widget.useSplitLayout,
      splitLayoutRatioVertical: widget.splitLayoutRatioVertical,
      splitLayoutRatioHorizontal: widget.splitLayoutRatioHorizontal,
      onSetSplitLayoutRatioVertical: widget.onSetSplitLayoutRatioVertical,
      onSetSplitLayoutRatioHorizontal: widget.onSetSplitLayoutRatioHorizontal,
      onToggleSplitLayout: widget.onSetUseSplitLayout != null
          ? () => unawaited(
                widget.onSetUseSplitLayout!(!widget.useSplitLayout),
              )
          : null,
      onAddRoot: _addRoot,
      onImportCherryTree: () {
        unawaited(_importCherryTree());
      },
      onExportCherryTree: () {
        unawaited(_exportCherryTree());
      },
      onSearch: _openSearch,
      onBookmarks: _openBookmarks,
      onTreeSelectWide: (id) => setState(() => _activeTab.selectedNodeId = id),
      onTreeSelectDrawer: (id) {
        setState(() => _activeTab.selectedNodeId = id);
        Navigator.of(context).pop();
      },
      onAddChild: _addChild,
      onAddSibling: _addSibling,
      onDelete: _delete,
      onMoveUp: _moveUp,
      onMoveDown: _moveDown,
      onIndent: _indent,
      onUnindent: _unindent,
      onSort: _sort,
      onToggleBookmark: _toggleBookmark,
      onDuplicate: _duplicate,
      onNodeProperties: (id) => unawaited(_nodeProperties(id)),
      onEditorChanged: _onEditorChanged,
      l10n: l10n,
    );

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _openSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): _openSearch,
      },
      child: Focus(
        autofocus: true,
        child: scaffold,
      ),
    );
  }
}
