import 'dart:async';

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

/// App settings (theme today; room for CherryTree-style categories later).
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onSetUseDarkTheme,
  });

  /// Persists and applies light (`false`) vs dark (`true`) theme.
  final Future<void> Function(bool useDarkTheme)? onSetUseDarkTheme;

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
        ],
      ),
    );
  }
}
