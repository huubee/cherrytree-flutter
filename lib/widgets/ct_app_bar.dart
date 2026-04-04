import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum SaveState { idle, saving, saved, error }

class CTAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CTAppBar({
    super.key,
    this.titleText,
    required this.onAddRoot,
    required this.saveState,
    this.leading,
    this.onImportCherryTree,
  });

  final String? titleText;
  final VoidCallback onAddRoot;
  final SaveState saveState;
  final Widget? leading;
  final VoidCallback? onImportCherryTree;

  @override
  State<CTAppBar> createState() => _CTAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.titleText ?? l10n.appTitle),
          const SizedBox(width: 8),
          _buildSaveIndicator(),
        ],
      ),
      leading: widget.leading,
      actions: [
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
