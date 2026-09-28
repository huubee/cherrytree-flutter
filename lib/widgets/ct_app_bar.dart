import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum SaveState { idle, saving, saved, error }

/// One segment of the path under the app bar title (root → … → selected).
class BreadcrumbSegment {
  const BreadcrumbSegment({required this.id, required this.label});

  final String id;
  final String label;
}

class CTAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CTAppBar({
    super.key,
    this.titleText,
    this.breadcrumbSegments,
    this.onBreadcrumbTap,
    this.tabStrip,
    this.onOpenSettings,
    required this.onAddRoot,
    required this.saveState,
    this.leading,
    this.onImportCherryTree,
    this.onExportCherryTree,
    this.onSearch,
    this.onBookmarks,
    this.onToggleSplitLayout,
    this.splitLayoutEnabled = false,
    this.splitLayoutToggleTooltip,
  });

  final String? titleText;
  /// Path from root to selected note; each segment is tappable when [onBreadcrumbTap] is set.
  final List<BreadcrumbSegment>? breadcrumbSegments;
  final ValueChanged<String>? onBreadcrumbTap;
  /// Optional second row under the breadcrumb (e.g. [TabBar] with [TabController]).
  /// Height is fixed at [tabStripHeight]; do not wrap in [PreferredSize] (see layout note below).
  final Widget? tabStrip;

  /// Vertical space reserved for [tabStrip]. Must match the intrinsic height of that subtree.
  static const double tabStripHeight = 48;
  final VoidCallback? onOpenSettings;
  final VoidCallback onAddRoot;
  final SaveState saveState;
  final Widget? leading;
  final VoidCallback? onImportCherryTree;
  final VoidCallback? onExportCherryTree;
  final VoidCallback? onSearch;
  final VoidCallback? onBookmarks;

  /// When non-null, shows a split-layout toggle (same persistence as Settings).
  final VoidCallback? onToggleSplitLayout;
  final bool splitLayoutEnabled;
  final String? splitLayoutToggleTooltip;

  @override
  State<CTAppBar> createState() => _CTAppBarState();

  static const double _breadcrumbBarHeight = 26;

  @override
  Size get preferredSize {
    var bottom = 0.0;
    if (breadcrumbSegments != null && breadcrumbSegments!.isNotEmpty) {
      bottom += _breadcrumbBarHeight;
    }
    if (tabStrip != null) {
      bottom += tabStripHeight;
    }
    return Size.fromHeight(kToolbarHeight + bottom);
  }
}

class _CTAppBarState extends State<CTAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ScrollController _breadcrumbScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.saveState == SaveState.saving) {
      _pulseController.repeat(reverse: true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleScrollBreadcrumbToEnd();
    });
  }

  @override
  void didUpdateWidget(covariant CTAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_breadcrumbSegmentsEqual(
      oldWidget.breadcrumbSegments,
      widget.breadcrumbSegments,
    )) {
      _scheduleScrollBreadcrumbToEnd();
    }
    // Restart or halt the pulsing animation when the save state updates from the parent.
    // We halt by setting the value to 1.0 (fully opaque) to prevent the indicator from being stuck in a faded state.
    if (widget.saveState != oldWidget.saveState) {
      if (widget.saveState == SaveState.saving) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _breadcrumbScrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scheduleScrollBreadcrumbToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_breadcrumbScrollController.hasClients) return;
      final pos = _breadcrumbScrollController.position;
      _breadcrumbScrollController.animateTo(
        pos.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildSaveIndicator() {
    switch (widget.saveState) {
      case SaveState.idle:
        return const SizedBox.shrink();
      case SaveState.saving:
        return FadeTransition(
          opacity: _pulseAnimation,
          child: const Icon(Icons.cloud_upload_outlined, size: 20),
        );
      case SaveState.saved:
        return const Icon(Icons.cloud_done_outlined,
            size: 20, color: Colors.green);
      case SaveState.error:
        return const Icon(Icons.error_outline, size: 20, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final segments = widget.breadcrumbSegments;
    final hasBreadcrumb = segments != null && segments.isNotEmpty;
    final tabStrip = widget.tabStrip;
    final hasTabs = tabStrip != null;

    PreferredSizeWidget? bottomBar;
    if (hasBreadcrumb || hasTabs) {
      var h = 0.0;
      if (hasBreadcrumb) h += CTAppBar._breadcrumbBarHeight;
      if (hasTabs) h += CTAppBar.tabStripHeight;
      bottomBar = PreferredSize(
        preferredSize: Size.fromHeight(h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasBreadcrumb)
              SizedBox(
                height: CTAppBar._breadcrumbBarHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 16,
                      bottom: 6,
                    ),
                    child: Semantics(
                      label: segments
                          .map((s) => s.label)
                          .join(' / '),
                      child: SingleChildScrollView(
                        controller: _breadcrumbScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildBreadcrumbChildren(
                            context,
                            theme,
                            segments,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (hasTabs)
              SizedBox(
                height: CTAppBar.tabStripHeight,
                width: double.infinity,
                child: tabStrip,
              ),
          ],
        ),
      );
    }

    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.titleText ?? l10n.appTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          _buildSaveIndicator(),
        ],
      ),
      bottom: bottomBar,
      leading: widget.leading,
      actions: [
        if (widget.onToggleSplitLayout != null)
          IconButton(
            icon: Icon(
              widget.splitLayoutEnabled
                  ? Icons.view_sidebar
                  : Icons.view_sidebar_outlined,
            ),
            tooltip: widget.splitLayoutToggleTooltip,
            onPressed: widget.onToggleSplitLayout,
          ),
        if (widget.onOpenSettings != null)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
            onPressed: widget.onOpenSettings,
          ),
        if (widget.onImportCherryTree != null)
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: l10n.importCherryTreeTooltip,
            onPressed: widget.onImportCherryTree,
          ),
        if (widget.onExportCherryTree != null)
          IconButton(
            icon: const Icon(Icons.save_as_outlined),
            tooltip: l10n.exportCherryTreeTooltip,
            onPressed: widget.onExportCherryTree,
          ),
        if (widget.onSearch != null)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchTooltip,
            onPressed: widget.onSearch,
          ),
        if (widget.onBookmarks != null)
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: l10n.bookmarksTooltip,
            onPressed: widget.onBookmarks,
          ),
        IconButton(
          icon: const Icon(Icons.note_add_outlined),
          tooltip: l10n.addRootNoteTooltip,
          onPressed: widget.onAddRoot,
        ),
      ],
    );
  }

  List<Widget> _buildBreadcrumbChildren(
    BuildContext context,
    ThemeData theme,
    List<BreadcrumbSegment> segments,
  ) {
    final sepStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final tap = widget.onBreadcrumbTap;
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
    );
    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(' / ', style: sepStyle),
          ),
        );
      }
      children.add(
        TextButton(
          onPressed: tap != null ? () => tap(s.id) : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          child: Text(
            s.label,
            style: tap != null ? linkStyle : sepStyle,
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        ),
      );
    }
    return children;
  }
}

bool _breadcrumbSegmentsEqual(
  List<BreadcrumbSegment>? a,
  List<BreadcrumbSegment>? b,
) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].id != b[i].id) return false;
  }
  return true;
}
