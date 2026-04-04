// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Cherrytree Flutter';

  @override
  String get loading => 'Wird geladen…';

  @override
  String get saveFailed =>
      'Notizen konnten nicht gespeichert werden. Speicher prüfen.';

  @override
  String errorWithMessage(String error) {
    return 'Fehler: $error';
  }

  @override
  String get addRootNoteTooltip => 'Hauptnotiz hinzufügen';

  @override
  String get drawerNotesTitle => 'Notizen';

  @override
  String get menuAddChild => 'Unterpunkt hinzufügen';

  @override
  String get menuDeleteSubtree => 'Zweig löschen';

  @override
  String get untitledNote => 'Ohne Titel';

  @override
  String get emptyEditorHint => 'Notiz auswählen oder neue anlegen.';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldBody => 'Text';

  @override
  String get newNoteTitle => 'Neue Notiz';

  @override
  String get seedWelcomeTitle => 'Willkommen';

  @override
  String get seedWelcomeBody =>
      'Spike B: lokale Notizen mit schreibgeschütztem Import unverschlüsselter CherryTree-.ctd- (XML) und .ctb-Dateien (SQLite). Rich-Text wird als Klartext angezeigt; Bilder und Tabellen werden ausgelassen.';

  @override
  String get importCherryTreeTooltip => 'CherryTree-Datei importieren';

  @override
  String get importReplaceTitle => 'Lokale Notizen ersetzen?';

  @override
  String get importReplaceMessage =>
      'Damit werden alle in dieser App gespeicherten Notizen durch das importierte CherryTree-Dokument ersetzt. Fortfahren?';

  @override
  String get importCancel => 'Abbrechen';

  @override
  String get importReplaceConfirm => 'Ersetzen';

  @override
  String get importEncryptedError =>
      'Verschlüsselte CherryTree-Dokumente (.ctz / .ctx) werden noch nicht unterstützt.';

  @override
  String get importUnsupportedFileType =>
      'Bitte wählen Sie eine CherryTree-.ctd- oder .ctb-Datei.';

  @override
  String importFailedMessage(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get importWarningsTitle => 'Hinweise zum Import';

  @override
  String get importWarningsOk => 'OK';

  @override
  String get themeUseLight => 'Helles Design';

  @override
  String get themeUseDark => 'Dunkles Design';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get settingsAppearanceSection => 'Erscheinungsbild';

  @override
  String get settingsUseDarkTheme => 'Dunkles Design';

  @override
  String get settingsUseDarkThemeSubtitle =>
      'Dunkles Blau wie die Desktop-Version von CherryTree';
}
