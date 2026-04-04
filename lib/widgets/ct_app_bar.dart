import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum SaveState { idle, saving, saved, error }

class CTAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CTAppBar({
    super.key,
    this.titleText,
    this.breadcrumbPath,
    this.onOpenSettings,
    required this.onAddRoot,
    required this.saveState,
    this.leading,
    this.onImportCherryTree,
  });

  final String? titleText;
  /// Path from root to selected note, e.g. `A / B / C` (shown under the title).
  final String? breadcrumbPath;
  final VoidCallback? onOpenSettings;
  final VoidCallback onAddRoot;
  final SaveState saveState;
  final Widget? leading;
  final VoidCallback? onImportCherryTree;

  @override
  State<CTAppBar> createState() => _CTAppBarState();

  static const double _breadcrumbBarHeight = 26;

  @override
  Size get preferredSize {
    final hasBreadcrumb =
        breadcrumbPath != null && breadcrumbPath!.trim().isNotEmpty;
    return Size.fromHeight(
      kToolbarHeight + (hasBreadcrumb ? _breadcrumbBarHeight : 0),
    );
  }
}

class _CTAppBarState extends State<CTAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
  }

  @override
  void didUpdateWidget(covariant CTAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _pulseController.dispose();
    super.dispose();
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
    final breadcrumb = widget.breadcrumbPath?.trim();
    final hasBreadcrumb = breadcrumb != null && breadcrumb.isNotEmpty;

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
      bottom: hasBreadcrumb
          ? PreferredSize(
              preferredSize: const Size.fromHeight(CTAppBar._breadcrumbBarHeight),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 16,
                    end: 16,
                    bottom: 6,
                  ),
                  child: Semantics(
                    label: breadcrumb,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        breadcrumb,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      leading: widget.leading,
      actions: [
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
        IconButton(
          icon: const Icon(Icons.note_add_outlined),
          tooltip: l10n.addRootNoteTooltip,
          onPressed: widget.onAddRoot,
        ),
      ],
    );
  }
}
