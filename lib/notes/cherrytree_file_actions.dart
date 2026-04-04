import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../cherrytree/cherrytree_document_export.dart';
import '../cherrytree/cherrytree_document_reader.dart';
import '../l10n/app_localizations.dart';
import '../models/document_tab.dart';
import '../models/note_document.dart';
import '../services/document_storage_prefs.dart';
import 'cherrytree_import_outcome.dart';

/// Where to place a CherryTree import when multiple tabs are open.
enum CherrytreeImportTabTarget {
  replaceCurrent,
  newTab,
}

/// Import / export flows for CherryTree `.ctd` / `.ctb` (picker, dialogs, snackbars).
class CherrytreeFileActions {
  CherrytreeFileActions._();

  /// Picks a file, validates extension, reads document (no confirmation dialog).
  /// Returns `null` if the user cancels or validation/read fails.
  static Future<CherrytreeImportOutcome?> pickAndReadCherryTreeImport(
    BuildContext context,
  ) async {
    final platformFile = await _pickCherryTreeValidatedFile(context);
    if (platformFile == null) return null;
    if (!context.mounted) return null;
    return _readCherryTreeOutcome(context, platformFile);
  }

  /// Picks a file, validates extension, confirm-replace dialog, reads document.
  /// Returns `null` if the user cancels or validation fails before read.
  static Future<CherrytreeImportOutcome?> importReplaceDocument(
    BuildContext context,
  ) async {
    final platformFile = await _pickCherryTreeValidatedFile(context);
    if (platformFile == null) return null;
    if (!context.mounted) return null;
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importReplaceTitle),
        content: Text(l10n.importReplaceMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.importCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.importReplaceConfirm),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return null;

    return _readCherryTreeOutcome(context, platformFile);
  }

  static Future<PlatformFile?> _pickCherryTreeValidatedFile(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;
    if (!context.mounted) return null;

    final platformFile = picked.files.single;
    final name = platformFile.name.toLowerCase();
    if (name.endsWith('.ctz') || name.endsWith('.ctx')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importEncryptedError)));
      return null;
    }
    if (!name.endsWith('.ctd') && !name.endsWith('.ctb')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importUnsupportedFileType)));
      return null;
    }
    return platformFile;
  }

  static Future<CherrytreeImportOutcome?> _readCherryTreeOutcome(
    BuildContext context,
    PlatformFile platformFile,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final name = platformFile.name.toLowerCase();
    try {
      final r = await CherrytreeDocumentReader.readFromPickedFile(platformFile);
      return CherrytreeImportOutcome(
        result: r,
        sourcePath: platformFile.path,
        fileNameLower: name,
      );
    } on CherrytreeEncryptedImportException {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importEncryptedError)));
      return null;
    } catch (e) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importFailedMessage('$e'))));
      return null;
    }
  }

  /// Asks whether to replace the active tab or open a new tab.
  static Future<CherrytreeImportTabTarget?> showImportTabTargetDialog(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<CherrytreeImportTabTarget>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importTabTargetTitle),
        content: Text(l10n.importTabTargetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.importCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              ctx,
              CherrytreeImportTabTarget.replaceCurrent,
            ),
            child: Text(l10n.importTabReplaceCurrent),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, CherrytreeImportTabTarget.newTab),
            child: Text(l10n.importTabOpenNew),
          ),
        ],
      ),
    );
  }

  /// Builds a [DocumentTab] from a successful import (new id or existing tab id).
  static DocumentTab documentTabFromImport(
    String tabId,
    CherrytreeImportOutcome outcome,
  ) {
    final roots = outcome.result.document.childrenOf(null);
    String? mode;
    String? path;
    final sp = outcome.sourcePath;
    if (sp != null) {
      if (outcome.fileNameLower.endsWith('.ctd')) {
        mode = 'ctd';
        path = sp;
      } else if (outcome.fileNameLower.endsWith('.ctb')) {
        mode = 'ctb';
        path = sp;
      }
    }
    return DocumentTab(
      id: tabId,
      document: outcome.result.document,
      selectedNodeId: roots.isNotEmpty ? roots.first.id : null,
      cherrytreeMode: mode,
      cherrytreePath: path,
    );
  }

  static Future<void> applyImportPrefsFromOutcome(
    CherrytreeImportOutcome outcome,
  ) async {
    final path = outcome.sourcePath;
    if (path == null) return;
    final lower = outcome.fileNameLower;
    if (lower.endsWith('.ctd')) {
      await DocumentStoragePrefs.setCherrytreeFile(mode: 'ctd', path: path);
    } else if (lower.endsWith('.ctb')) {
      await DocumentStoragePrefs.setCherrytreeFile(mode: 'ctb', path: path);
    }
  }

  /// Shows import warnings dialog after a successful read (caller handles `mounted`).
  static Future<void> showImportWarningsDialog(
    BuildContext context,
    List<String> warnings,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importWarningsTitle),
        content: SingleChildScrollView(
          child: SelectableText(warnings.join('\n\n')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.importWarningsOk),
          ),
        ],
      ),
    );
  }

  /// Format sheet + system save dialog. Shows snackbars on success or error.
  static Future<void> exportDocument(
    BuildContext context,
    NoteDocument doc,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final useCtb = await showModalBottomSheet<bool?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                l10n.exportCherryTreeSheetTitle,
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.exportAsCtdTitle),
              subtitle: Text(l10n.exportAsCtdSubtitle),
              onTap: () => Navigator.pop(ctx, false),
            ),
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: Text(l10n.exportAsCtbTitle),
              subtitle: Text(l10n.exportAsCtbSubtitle),
              onTap: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (useCtb == null || !context.mounted) return;

    final shareInsteadOfSave = await showModalBottomSheet<bool?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                l10n.exportDestinationSheetTitle,
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n.exportSaveToDeviceTitle),
              subtitle: Text(l10n.exportSaveToDeviceSubtitle),
              onTap: () => Navigator.pop(ctx, false),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.exportShareTitle),
              subtitle: Text(l10n.exportShareSubtitle),
              onTap: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (shareInsteadOfSave == null || !context.mounted) return;

    final ext = useCtb ? 'ctb' : 'ctd';
    final suggestedName = 'cherrytree-export.$ext';
    final pickedName = await _promptExportFileName(context, l10n, suggestedName);
    if (pickedName == null || !context.mounted) return;
    final fileName = _ensureExportFileName(pickedName, ext);

    try {
      final Uint8List bytes;
      if (useCtb) {
        bytes = await CherrytreeDocumentExport.ctbBytes(doc);
      } else {
        bytes = CherrytreeDocumentExport.ctdBytes(doc);
      }
      if (shareInsteadOfSave) {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                bytes,
                name: fileName,
                mimeType: useCtb ? 'application/vnd.sqlite3' : 'application/xml',
              ),
            ],
            subject: l10n.exportCherryTreeDialogTitle,
            fileNameOverrides: [fileName],
          ),
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportCherryTreeShareSuccess)));
        return;
      }
      final path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportCherryTreeDialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [ext],
        bytes: bytes,
      );
      if (!context.mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportCherryTreeSuccess)));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportCherryTreeFailed('$e'))),
      );
    }
  }

  /// Normalizes the name the user typed so it ends with [`.$ext`].
  static String _ensureExportFileName(String input, String ext) {
    var t = input.trim();
    if (t.isEmpty) return 'cherrytree-export.$ext';
    final lower = t.toLowerCase();
    if (lower.endsWith('.$ext')) return t;
    final dot = t.lastIndexOf('.');
    if (dot > 0) {
      t = t.substring(0, dot).trim();
    }
    if (t.isEmpty) return 'cherrytree-export.$ext';
    return '$t.$ext';
  }

  static Future<String?> _promptExportFileName(
    BuildContext context,
    AppLocalizations l10n,
    String defaultName,
  ) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _ExportFileNameDialog(
        defaultName: defaultName,
        l10n: l10n,
      ),
    );
  }
}

class _ExportFileNameDialog extends StatefulWidget {
  const _ExportFileNameDialog({
    required this.defaultName,
    required this.l10n,
  });

  final String defaultName;
  final AppLocalizations l10n;

  @override
  State<_ExportFileNameDialog> createState() => _ExportFileNameDialogState();
}

class _ExportFileNameDialogState extends State<_ExportFileNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.exportFileNameDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: l10n.exportFileNameFieldLabel,
        ),
        onSubmitted: (_) {
          Navigator.pop(context, _controller.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.importCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.exportFileNameContinue),
        ),
      ],
    );
  }
}
