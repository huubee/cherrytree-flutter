// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Cherrytree Flutter';

  @override
  String get loading => 'Laden…';

  @override
  String get noOpenDocuments => 'Geen open documenten.';

  @override
  String get saveFailed =>
      'Notities konden niet worden opgeslagen. Controleer opslag en vrije ruimte.';

  @override
  String errorWithMessage(String error) {
    return 'Fout: $error';
  }

  @override
  String get addRootNoteTooltip => 'Hoofdnotitie toevoegen';

  @override
  String get drawerNotesTitle => 'Notities';

  @override
  String get menuAddChild => 'Kind toevoegen';

  @override
  String get menuDeleteSubtree => 'Subboom verwijderen';

  @override
  String get untitledNote => 'Naamloos';

  @override
  String get emptyEditorHint => 'Selecteer een notitie of voeg er een toe.';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldBody => 'Tekst';

  @override
  String get newNoteTitle => 'Nieuwe notitie';

  @override
  String get seedWelcomeTitle => 'Welkom';

  @override
  String get seedWelcomeBody =>
      'Spike B: lokale notities met alleen-lezen import van onversleutelde CherryTree .ctd (XML) en .ctb (SQLite). Rijke tekst wordt als platte tekst getoond; afbeeldingen en tabellen worden weggelaten.';

  @override
  String get exportCherryTreeTooltip => 'Exporteren naar CherryTree-bestand';

  @override
  String get exportCherryTreeSheetTitle => 'Exportformaat';

  @override
  String get exportAsCtdTitle => 'XML (.ctd)';

  @override
  String get exportAsCtdSubtitle =>
      'Eén bestand; handig voor kleine bomen en diffen.';

  @override
  String get exportAsCtbTitle => 'SQLite (.ctb)';

  @override
  String get exportAsCtbSubtitle =>
      'Databasebestand; beter voor grote documenten.';

  @override
  String get exportCherryTreeDialogTitle => 'CherryTree-export opslaan';

  @override
  String get exportFileNameDialogTitle => 'Bestandsnaam';

  @override
  String get exportFileNameFieldLabel => 'Naam';

  @override
  String get exportFileNameContinue => 'Doorgaan';

  @override
  String get exportDestinationSheetTitle => 'Waar wilt u het bestand zetten?';

  @override
  String get exportSaveToDeviceTitle => 'Opslaan op dit apparaat';

  @override
  String get exportSaveToDeviceSubtitle => 'Kies een map (lokale opslag)';

  @override
  String get exportShareTitle => 'Delen via een andere app';

  @override
  String get exportShareSubtitle =>
      'Cloudopslag, e-mail of andere bestemmingen';

  @override
  String get exportCherryTreeSuccess => 'Export opgeslagen.';

  @override
  String get exportCherryTreeShareSuccess => 'Deelvenster geopend.';

  @override
  String exportCherryTreeFailed(String error) {
    return 'Exporteren mislukt: $error';
  }

  @override
  String get importCherryTreeTooltip => 'CherryTree-bestand importeren';

  @override
  String get importReplaceTitle => 'Lokale notities vervangen?';

  @override
  String get importReplaceMessage =>
      'Dit vervangt alle in deze app opgeslagen notities door het geïmporteerde CherryTree-document. Doorgaan?';

  @override
  String get importCancel => 'Annuleren';

  @override
  String get importReplaceConfirm => 'Vervangen';

  @override
  String get importTabTargetTitle => 'Importlocatie';

  @override
  String get importTabTargetMessage =>
      'Het huidige tabblad vervangen of de import in een nieuw tabblad openen?';

  @override
  String get importTabReplaceCurrent => 'Huidige tabblad vervangen';

  @override
  String get importTabOpenNew => 'Nieuw tabblad';

  @override
  String get newTabTooltip => 'Nieuw tabblad';

  @override
  String get closeTabTooltip => 'Tabblad sluiten';

  @override
  String get renameTabTooltip => 'Lang indrukken om te hernoemen';

  @override
  String get renameTabTitle => 'Tabblad hernoemen';

  @override
  String get renameTabFieldLabel => 'Tabnaam';

  @override
  String get renameTabDescription =>
      'Laat leeg om de titel van de eerste hoofdnotitie te gebruiken.';

  @override
  String get renameTabSave => 'Opslaan';

  @override
  String get importEncryptedError =>
      'Versleutelde CherryTree-documenten (.ctz / .ctx) worden nog niet ondersteund.';

  @override
  String get importUnsupportedFileType =>
      'Kies een CherryTree-.ctd- of .ctb-bestand.';

  @override
  String importFailedMessage(String error) {
    return 'Importeren mislukt: $error';
  }

  @override
  String get importWarningsTitle => 'Opmerkingen bij import';

  @override
  String get importWarningsOk => 'OK';

  @override
  String get themeUseLight => 'Licht thema';

  @override
  String get themeUseDark => 'Donker thema';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsTooltip => 'Instellingen';

  @override
  String get settingsAppearanceSection => 'Weergave';

  @override
  String get settingsUseDarkTheme => 'Donker thema';

  @override
  String get settingsUseDarkThemeSubtitle =>
      'Donkerblauw, vergelijkbaar met desktop CherryTree';

  @override
  String get settingsLayoutSection => 'Indeling';

  @override
  String get settingsUseSplitLayout => 'Gesplitste indeling';

  @override
  String get settingsUseSplitLayoutSubtitle =>
      'Toon de boom naast of boven de editor met een versleepbare scheiding in plaats van een vaste zijbalk of lade';

  @override
  String get splitLayoutToggleTooltip => 'Gesplitste indeling aan/uit';

  @override
  String get settingsLanguageSection => 'Taal';

  @override
  String get settingsLanguageDefault => 'Systeemstandaard';

  @override
  String get menuAddSibling => 'Nevenknoop toevoegen';

  @override
  String get menuMoveUp => 'Omhoog verplaatsen';

  @override
  String get menuMoveDown => 'Omlaag verplaatsen';

  @override
  String get menuIndent => 'Inspringen (naar rechts)';

  @override
  String get menuUnindent => 'Uitspringen (naar links)';

  @override
  String get menuSortAsc => 'Onderliggende sorteren (A-Z)';

  @override
  String get menuSortDesc => 'Onderliggende sorteren (Z-A)';

  @override
  String get menuToggleBookmark => 'Bladwijzer wisselen';

  @override
  String get menuDuplicate => 'Knoop dupliceren';

  @override
  String get menuNodeProperties => 'Knoopeigenschappen';

  @override
  String get treeExpandAll => 'Alles uitvouwen';

  @override
  String get treeCollapseAll => 'Alles samenvouwen';

  @override
  String get searchTitle => 'Zoeken in knopen';

  @override
  String get searchHint => 'Zoek titel, tags of inhoud...';

  @override
  String get searchMatchCase => 'Hoofdlettergevoelig';

  @override
  String get searchWholeWord => 'Heel woord';

  @override
  String get searchRegex => 'Reguliere expressie';

  @override
  String get searchInContent => 'Inhoud';

  @override
  String get searchInNameAndTags => 'Namen & tags';

  @override
  String get searchSubnodesOnly => 'Alleen subknopen';

  @override
  String get searchOverrideExclusions => 'Uitsluitingen negeren';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overeenkomende knopen',
      one: '1 overeenkomende knoop',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResults => 'Geen overeenkomende knopen gevonden';

  @override
  String get searchEmptyPrompt => 'Typ om in notities te zoeken';

  @override
  String get searchBadgeTitle => 'Titel';

  @override
  String get searchBadgeTag => 'Tag';

  @override
  String get searchBadgeContent => 'Inhoud';

  @override
  String get bookmarksTitle => 'Bladwijzers';

  @override
  String get bookmarksEmpty => 'Nog geen bladwijzers aanwezig.';

  @override
  String get bookmarksRemoveTooltip => 'Bladwijzer verwijderen';

  @override
  String get bookmarksTooltip => 'Bladwijzers';

  @override
  String get searchTooltip => 'Zoeken in knopen (Ctrl+F)';

  @override
  String get insertTimestampTooltip => 'Tijdstempel invoegen';

  @override
  String get insertHorizontalRuleTooltip => 'Horizontale lijn invoegen';

  @override
  String get insertSpecialCharTooltip => 'Speciaal teken invoegen';

  @override
  String get specialCharsTitle => 'Speciale tekens';

  @override
  String get specialCharsDone => 'Sluiten';

  @override
  String get insertCodeboxTooltip => 'Codebox invoegen';

  @override
  String get insertTableTooltip => 'Tabel invoegen';

  @override
  String get codeboxDialogTitle => 'Codebox invoegen';

  @override
  String get codeboxLanguageLabel => 'Taal';

  @override
  String get codeboxCodeLabel => 'Code';

  @override
  String get exportActionTitle => 'Notities exporteren';

  @override
  String get exportDialogTitle => 'Notities exporteren';

  @override
  String get exportScopeEntireTree => 'Volledige boom';

  @override
  String get exportScopeSelectedWithSubnodes => 'Huidige notitie & subnotities';

  @override
  String get exportScopeSelectedOnly => 'Alleen huidige notitie';

  @override
  String get exportFormatLabel => 'Formaat';

  @override
  String get exportCopyToClipboard => 'Kopiëren naar klembord';

  @override
  String get exportSaveToFile => 'Opslaan naar bestand';

  @override
  String get exportCopiedToClipboard => 'Export gekopieerd naar klembord';
}
