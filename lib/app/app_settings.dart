import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide UI settings loaded from [SharedPreferences].
final class AppSettings {
  const AppSettings({
    required this.useDarkTheme,
    required this.useSplitLayout,
    required this.splitLayoutRatioVertical,
    required this.splitLayoutRatioHorizontal,
    this.appLocaleCode,
  });

  final bool useDarkTheme;
  final bool useSplitLayout;
  final double splitLayoutRatioVertical;
  final double splitLayoutRatioHorizontal;
  final String? appLocaleCode;

  static const defaults = AppSettings(
    useDarkTheme: false,
    useSplitLayout: false,
    splitLayoutRatioVertical: 0.33,
    splitLayoutRatioHorizontal: 0.4,
    appLocaleCode: null,
  );
}

/// Read and write [AppSettings] keys in [SharedPreferences].
abstract final class AppSettingsStore {
  static const _prefDarkTheme = 'use_dark_theme';
  static const _prefSplitLayout = 'use_split_layout';
  /// Older installs used these keys before split layout applied to wide + narrow.
  static const _prefSplitLayoutLegacy = 'use_split_layout_portrait';
  static const _prefSplitRatioVertical = 'split_layout_ratio_vertical';
  static const _prefSplitRatioHorizontal = 'split_layout_ratio_horizontal';
  static const _prefSplitRatioLegacy = 'split_layout_ratio';
  static const _prefLocale = 'app_locale_code';

  /// Loads prefs or returns [AppSettings.defaults] after logging — never throws, so
  /// startup is not blocked by a bad channel or corrupt store.
  static Future<AppSettings> load() async {
    try {
      final p = await SharedPreferences.getInstance();

      final split =
          p.getBool(_prefSplitLayout) ?? p.getBool(_prefSplitLayoutLegacy) ?? false;

      double vertical = p.getDouble(_prefSplitRatioVertical) ?? 0;
      if (vertical <= 0 || vertical >= 1) {
        vertical = p.getDouble(_prefSplitRatioLegacy) ?? 0.33;
      }
      vertical = vertical.clamp(0.1, 0.9);

      var horizontal = p.getDouble(_prefSplitRatioHorizontal) ?? 0.4;
      horizontal = horizontal.clamp(0.1, 0.9);

      return AppSettings(
        useDarkTheme: p.getBool(_prefDarkTheme) ?? false,
        useSplitLayout: split,
        splitLayoutRatioVertical: vertical,
        splitLayoutRatioHorizontal: horizontal,
        appLocaleCode: p.getString(_prefLocale),
      );
    } catch (e, st) {
      debugPrint('SharedPreferences load failed: $e\n$st');
      return AppSettings.defaults;
    }
  }

  static Future<void> saveDarkTheme(bool value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_prefDarkTheme, value);
    } catch (e, st) {
      debugPrint('SharedPreferences save failed: $e\n$st');
    }
  }

  static Future<void> saveSplitLayout(bool value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_prefSplitLayout, value);
    } catch (e, st) {
      debugPrint('SharedPreferences save failed: $e\n$st');
    }
  }

  static Future<void> saveSplitRatioVertical(double value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_prefSplitRatioVertical, value);
    } catch (e, st) {
      debugPrint('SharedPreferences save failed: $e\n$st');
    }
  }

  static Future<void> saveSplitRatioHorizontal(double value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_prefSplitRatioHorizontal, value);
    } catch (e, st) {
      debugPrint('SharedPreferences save failed: $e\n$st');
    }
  }

  static Future<void> saveAppLocale(String? code) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (code == null) {
        await p.remove(_prefLocale);
      } else {
        await p.setString(_prefLocale, code);
      }
    } catch (e, st) {
      debugPrint('SharedPreferences save failed: $e\n$st');
    }
  }
}
