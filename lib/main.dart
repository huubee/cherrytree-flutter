import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'notes_home_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CherrytreeFlutterApp());
}

class CherrytreeFlutterApp extends StatefulWidget {
  const CherrytreeFlutterApp({super.key});

  @override
  State<CherrytreeFlutterApp> createState() => _CherrytreeFlutterAppState();
}

class _CherrytreeFlutterAppState extends State<CherrytreeFlutterApp> {
  static const _prefDarkTheme = 'use_dark_theme';

  /// `null` until [SharedPreferences] has been read.
  bool? _useDarkTheme;

  @override
  void initState() {
    super.initState();
    // Defer prefs until after the first frame — on Android the Pigeon channel for
    // `shared_preferences` can fail if accessed before the engine/plugins are ready
    // ("Unable to establish connection on channel ... SharedPreferencesApi.getAll").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTheme();
    });
  }

  Future<void> _loadTheme() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _useDarkTheme = p.getBool(_prefDarkTheme) ?? false;
      });
    } catch (e, st) {
      debugPrint('SharedPreferences load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _useDarkTheme = false);
    }
  }

  Future<void> _setUseDarkTheme(bool value) async {
    if (!mounted) return;
    // Apply theme immediately; persist in the background so a channel glitch
    // does not block the UI (same pattern as optimistic updates).
    setState(() => _useDarkTheme = value);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_prefDarkTheme, value);
    } catch (e, st) {
      debugPrint('SharedPreferences save failed: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = _useDarkTheme ?? false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: NotesHomePage(onSetUseDarkTheme: _setUseDarkTheme),
    );
  }
}
