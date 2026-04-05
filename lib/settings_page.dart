import 'dart:async';

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

/// App settings (theme today; room for CherryTree-style categories later).
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onSetUseDarkTheme,
    this.useSplitLayout = false,
    this.onSetUseSplitLayout,
    this.appLocaleCode,
    this.onSetAppLocale,
  });

  /// Persists and applies light (`false`) vs dark (`true`) theme.
  final Future<void> Function(bool useDarkTheme)? onSetUseDarkTheme;

  /// Persists tree + editor split layout when it applies (narrow or wide).
  final bool useSplitLayout;
  final Future<void> Function(bool useSplitLayout)? onSetUseSplitLayout;

  final String? appLocaleCode;
  final Future<void> Function(String? code)? onSetAppLocale;

  String _getLanguageLabel(String? code, AppLocalizations l10n) {
    switch (code) {
      case 'en': return '🇬🇧 English';
      case 'nl': return '🇳🇱 Nederlands';
      case 'de': return '🇩🇪 Deutsch';
      default: return '🌐 ${l10n.settingsLanguageDefault}';
    }
  }

  Future<void> _showLanguagePicker(BuildContext context, String? currentCode, AppLocalizations l10n) async {
    final code = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(l10n.settingsLanguageSection),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ''),
              child: Row(
                children: [
                  Icon(currentCode == null ? Icons.check : null, size: 20),
                  const SizedBox(width: 12),
                  Text('🌐 ${l10n.settingsLanguageDefault}'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'en'),
              child: Row(
                children: [
                  Icon(currentCode == 'en' ? Icons.check : null, size: 20),
                  const SizedBox(width: 12),
                  const Text('🇬🇧 English'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'nl'),
              child: Row(
                children: [
                  Icon(currentCode == 'nl' ? Icons.check : null, size: 20),
                  const SizedBox(width: 12),
                  const Text('🇳🇱 Nederlands'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'de'),
              child: Row(
                children: [
                  Icon(currentCode == 'de' ? Icons.check : null, size: 20),
                  const SizedBox(width: 12),
                  const Text('🇩🇪 Deutsch'),
                ],
              ),
            ),
          ],
        );
      }
    );
    if (code != null && onSetAppLocale != null) {
      unawaited(onSetAppLocale!(code.isEmpty ? null : code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canTheme = onSetUseDarkTheme != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settingsAppearanceSection,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            title: Text(l10n.settingsUseDarkTheme),
            subtitle: Text(l10n.settingsUseDarkThemeSubtitle),
            value: isDark,
            onChanged: canTheme
                ? (v) {
                    unawaited(onSetUseDarkTheme!(v));
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settingsLayoutSection,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.splitscreen_outlined),
            title: Text(l10n.settingsUseSplitLayout),
            subtitle: Text(l10n.settingsUseSplitLayoutSubtitle),
            value: useSplitLayout,
            onChanged: onSetUseSplitLayout != null
                ? (v) {
                    unawaited(onSetUseSplitLayout!(v));
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settingsLanguageSection,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(_getLanguageLabel(appLocaleCode, l10n)),
            onTap: onSetAppLocale != null ? () => _showLanguagePicker(context, appLocaleCode, l10n) : null,
          ),
        ],
      ),
    );
  }
}
