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
  String get noOpenDocuments => 'Keine geöffneten Dokumente.';

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
  String get exportCherryTreeTooltip => 'Als CherryTree-Datei exportieren';

  @override
  String get exportCherryTreeSheetTitle => 'Exportformat';

  @override
  String get exportAsCtdTitle => 'XML (.ctd)';

  @override
  String get exportAsCtdSubtitle =>
      'Einzeldatei; gut für kleine Bäume und Diff.';

  @override
  String get exportAsCtbTitle => 'SQLite (.ctb)';

  @override
  String get exportAsCtbSubtitle =>
      'Datenbankdatei; besser für große Dokumente.';

  @override
  String get exportCherryTreeDialogTitle => 'CherryTree-Export speichern';

  @override
  String get exportFileNameDialogTitle => 'Dateiname';

  @override
  String get exportFileNameFieldLabel => 'Name';

  @override
  String get exportFileNameContinue => 'Weiter';

  @override
  String get exportDestinationSheetTitle => 'Wo soll die Datei hin?';

  @override
  String get exportSaveToDeviceTitle => 'Auf diesem Gerät speichern';

  @override
  String get exportSaveToDeviceSubtitle => 'Ordner wählen (lokaler Speicher)';

  @override
  String get exportShareTitle => 'Über eine andere App teilen';

  @override
  String get exportShareSubtitle => 'Cloud, E-Mail oder andere Ziele';

  @override
  String get exportCherryTreeSuccess => 'Export gespeichert.';

  @override
  String get exportCherryTreeShareSuccess => 'Teilen-Dialog geöffnet.';

  @override
  String exportCherryTreeFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

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
  String get importTabTargetTitle => 'Importziel';

  @override
  String get importTabTargetMessage =>
      'Aktuellen Tab ersetzen oder den Import in einem neuen Tab öffnen?';

  @override
  String get importTabReplaceCurrent => 'Aktuellen Tab ersetzen';

  @override
  String get importTabOpenNew => 'Neuer Tab';

  @override
  String get newTabTooltip => 'Neuer Tab';

  @override
  String get closeTabTooltip => 'Tab schließen';

  @override
  String get renameTabTooltip => 'Zum Umbenennen lange drücken';

  @override
  String get renameTabTitle => 'Tab umbenennen';

  @override
  String get renameTabFieldLabel => 'Tab-Name';

  @override
  String get renameTabDescription =>
      'Leer lassen, um den Titel der ersten Hauptnotiz zu verwenden.';

  @override
  String get renameTabSave => 'Speichern';

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

  @override
  String get settingsLayoutSection => 'Layout';

  @override
  String get settingsUseSplitLayout => 'Geteiltes Layout';

  @override
  String get settingsUseSplitLayoutSubtitle =>
      'Baum neben oder über dem Editor mit verschiebbarem Teiler statt fester Seitenleiste oder Schublade';

  @override
  String get splitLayoutToggleTooltip => 'Geteiltes Layout umschalten';

  @override
  String get settingsLanguageSection => 'Sprache';

  @override
  String get settingsLanguageDefault => 'Systemstandard';

  @override
  String get menuAddSibling => 'Geschwisterknoten hinzufügen';

  @override
  String get menuMoveUp => 'Nach oben';

  @override
  String get menuMoveDown => 'Nach unten';

  @override
  String get menuIndent => 'Einrücken (nach rechts)';

  @override
  String get menuUnindent => 'Ausrücken (nach links)';

  @override
  String get menuSortAsc => 'Unterknoten sortieren (A-Z)';

  @override
  String get menuSortDesc => 'Unterknoten sortieren (Z-A)';

  @override
  String get menuToggleBookmark => 'Lesezeichen umschalten';

  @override
  String get menuDuplicate => 'Knoten duplizieren';

  @override
  String get menuNodeProperties => 'Knoteneigenschaften';

  @override
  String get treeExpandAll => 'Alle aufklappen';

  @override
  String get treeCollapseAll => 'Alle zuklappen';

  @override
  String get searchTitle => 'In Knoten suchen';

  @override
  String get searchHint => 'Titel, Tags oder Inhalt suchen...';

  @override
  String get searchMatchCase => 'Groß-/Kleinschreibung';

  @override
  String get searchWholeWord => 'Ganzes Wort';

  @override
  String get searchRegex => 'Regulärer Ausdruck';

  @override
  String get searchInContent => 'Inhalt';

  @override
  String get searchInNameAndTags => 'Namen & Tags';

  @override
  String get searchSubnodesOnly => 'Nur Unterknoten';

  @override
  String get searchOverrideExclusions => 'Ausschlüsse ignorieren';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passende Knoten',
      one: '1 passender Knoten',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResults => 'Keine passenden Knoten gefunden';

  @override
  String get searchEmptyPrompt => 'Tippen Sie, um Notizen zu durchsuchen';

  @override
  String get searchBadgeTitle => 'Titel';

  @override
  String get searchBadgeTag => 'Tag';

  @override
  String get searchBadgeContent => 'Inhalt';

  @override
  String get bookmarksTitle => 'Lesezeichen';

  @override
  String get bookmarksEmpty => 'Noch keine Lesezeichen vorhanden.';

  @override
  String get bookmarksRemoveTooltip => 'Lesezeichen entfernen';

  @override
  String get bookmarksTooltip => 'Lesezeichen';

  @override
  String get searchTooltip => 'In Knoten suchen (Strg+F)';

  @override
  String get insertTimestampTooltip => 'Zeitstempel einfügen';

  @override
  String get insertHorizontalRuleTooltip => 'Horizontale Linie einfügen';

  @override
  String get insertSpecialCharTooltip => 'Sonderzeichen einfügen';

  @override
  String get specialCharsTitle => 'Sonderzeichen';

  @override
  String get specialCharsDone => 'Schließen';
}
