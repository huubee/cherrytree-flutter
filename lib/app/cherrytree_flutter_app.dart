import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../l10n/app_localizations.dart';
import '../notes_home_page.dart';
import '../theme/app_theme.dart';
import 'app_settings.dart';

/// Root widget: theme, locale, and persisted split/layout prefs.
class CherrytreeFlutterApp extends StatefulWidget {
  const CherrytreeFlutterApp({super.key});

  @override
  State<CherrytreeFlutterApp> createState() => _CherrytreeFlutterAppState();
}

class _CherrytreeFlutterAppState extends State<CherrytreeFlutterApp> {
  /// `null` until [AppSettingsStore.load] completes.
  bool? _useDarkTheme;
  bool? _useSplitLayout;
  double? _splitLayoutRatioVertical;
  double? _splitLayoutRatioHorizontal;
  String? _appLocaleCode;

  @override
  void initState() {
    super.initState();
    // Defer prefs until after the first frame — on Android the Pigeon channel for
    // `shared_preferences` can fail if accessed before the engine/plugins are ready
    // ("Unable to establish connection on channel ... SharedPreferencesApi.getAll").
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrefs());
  }

  Future<void> _loadPrefs() async {
    final s = await AppSettingsStore.load();
    if (!mounted) return;
    setState(() {
      _useDarkTheme = s.useDarkTheme;
      _useSplitLayout = s.useSplitLayout;
      _splitLayoutRatioVertical = s.splitLayoutRatioVertical;
      _splitLayoutRatioHorizontal = s.splitLayoutRatioHorizontal;
      _appLocaleCode = s.appLocaleCode;
    });
  }

  // Preference setters call [setState] before awaiting persistence so toggles stay
  // responsive if the SharedPreferences channel hiccups; [AppSettingsStore] already
  // catches and logs save failures.

  Future<void> _setUseDarkTheme(bool value) async {
    if (!mounted) return;
    setState(() => _useDarkTheme = value);
    await AppSettingsStore.saveDarkTheme(value);
  }

  Future<void> _setUseSplitLayout(bool value) async {
    if (!mounted) return;
    setState(() => _useSplitLayout = value);
    await AppSettingsStore.saveSplitLayout(value);
  }

  Future<void> _setSplitLayoutRatioVertical(double value) async {
    if (!mounted) return;
    final v = value.clamp(0.1, 0.9);
    setState(() => _splitLayoutRatioVertical = v);
    await AppSettingsStore.saveSplitRatioVertical(v);
  }

  Future<void> _setSplitLayoutRatioHorizontal(double value) async {
    if (!mounted) return;
    final v = value.clamp(0.1, 0.9);
    setState(() => _splitLayoutRatioHorizontal = v);
    await AppSettingsStore.saveSplitRatioHorizontal(v);
  }

  Future<void> _setAppLocale(String? code) async {
    if (!mounted) return;
    setState(() => _appLocaleCode = code);
    await AppSettingsStore.saveAppLocale(code);
  }

  @override
  Widget build(BuildContext context) {
    final dark = _useDarkTheme ?? false;
    final useSplitLayout = _useSplitLayout ?? false;
    final splitRatioVertical = _splitLayoutRatioVertical ?? 0.33;
    final splitRatioHorizontal = _splitLayoutRatioHorizontal ?? 0.4;
    final localeCode = _appLocaleCode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: localeCode != null ? Locale(localeCode) : null,
      home: NotesHomePage(
        onSetUseDarkTheme: _setUseDarkTheme,
        useSplitLayout: useSplitLayout,
        splitLayoutRatioVertical: splitRatioVertical,
        splitLayoutRatioHorizontal: splitRatioHorizontal,
        onSetUseSplitLayout: _setUseSplitLayout,
        onSetSplitLayoutRatioVertical: _setSplitLayoutRatioVertical,
        onSetSplitLayoutRatioHorizontal: _setSplitLayoutRatioHorizontal,
        appLocaleCode: localeCode,
        onSetAppLocale: _setAppLocale,
      ),
    );
  }
}
