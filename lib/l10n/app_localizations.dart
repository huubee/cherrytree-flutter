import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cherrytree Flutter'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @noOpenDocuments.
  ///
  /// In en, this message translates to:
  /// **'No open documents.'**
  String get noOpenDocuments;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save notes. Check storage permissions and free space.'**
  String get saveFailed;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @addRootNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add root note'**
  String get addRootNoteTooltip;

  /// No description provided for @drawerNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get drawerNotesTitle;

  /// No description provided for @menuAddChild.
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get menuAddChild;

  /// No description provided for @menuDeleteSubtree.
  ///
  /// In en, this message translates to:
  /// **'Delete subtree'**
  String get menuDeleteSubtree;

  /// No description provided for @untitledNote.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledNote;

  /// No description provided for @emptyEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Select a note or add one.'**
  String get emptyEditorHint;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get fieldBody;

  /// No description provided for @newNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNoteTitle;

  /// No description provided for @seedWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get seedWelcomeTitle;

  /// No description provided for @seedWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Spike B: local tree of notes with read-only import of unencrypted CherryTree .ctd (XML) and .ctb (SQLite) files. Rich text is shown as plain text; images and tables are omitted.'**
  String get seedWelcomeBody;

  /// No description provided for @exportCherryTreeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export to CherryTree file'**
  String get exportCherryTreeTooltip;

  /// No description provided for @exportCherryTreeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Export format'**
  String get exportCherryTreeSheetTitle;

  /// No description provided for @exportAsCtdTitle.
  ///
  /// In en, this message translates to:
  /// **'XML (.ctd)'**
  String get exportAsCtdTitle;

  /// No description provided for @exportAsCtdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Single-file document; good for small trees and diff-friendly text.'**
  String get exportAsCtdSubtitle;

  /// No description provided for @exportAsCtbTitle.
  ///
  /// In en, this message translates to:
  /// **'SQLite (.ctb)'**
  String get exportAsCtbTitle;

  /// No description provided for @exportAsCtbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Database file; better for large documents on mobile and desktop.'**
  String get exportAsCtbSubtitle;

  /// No description provided for @exportCherryTreeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save CherryTree export'**
  String get exportCherryTreeDialogTitle;

  /// No description provided for @exportFileNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get exportFileNameDialogTitle;

  /// No description provided for @exportFileNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get exportFileNameFieldLabel;

  /// No description provided for @exportFileNameContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get exportFileNameContinue;

  /// No description provided for @exportDestinationSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to put the file?'**
  String get exportDestinationSheetTitle;

  /// No description provided for @exportSaveToDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Save to this device'**
  String get exportSaveToDeviceTitle;

  /// No description provided for @exportSaveToDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder (local storage)'**
  String get exportSaveToDeviceSubtitle;

  /// No description provided for @exportShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share via another app'**
  String get exportShareTitle;

  /// No description provided for @exportShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud storage, email, or other destinations'**
  String get exportShareSubtitle;

  /// No description provided for @exportCherryTreeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export saved.'**
  String get exportCherryTreeSuccess;

  /// No description provided for @exportCherryTreeShareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Share sheet opened.'**
  String get exportCherryTreeShareSuccess;

  /// No description provided for @exportCherryTreeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export: {error}'**
  String exportCherryTreeFailed(String error);

  /// No description provided for @importCherryTreeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import CherryTree file'**
  String get importCherryTreeTooltip;

  /// No description provided for @importReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace local notes?'**
  String get importReplaceTitle;

  /// No description provided for @importReplaceMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces all notes stored in this app with the imported CherryTree document. Continue?'**
  String get importReplaceMessage;

  /// No description provided for @importCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get importCancel;

  /// No description provided for @importReplaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importReplaceConfirm;

  /// No description provided for @importTabTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Import location'**
  String get importTabTargetTitle;

  /// No description provided for @importTabTargetMessage.
  ///
  /// In en, this message translates to:
  /// **'Replace the current tab’s notes or open the import in a new tab?'**
  String get importTabTargetMessage;

  /// No description provided for @importTabReplaceCurrent.
  ///
  /// In en, this message translates to:
  /// **'Replace current tab'**
  String get importTabReplaceCurrent;

  /// No description provided for @importTabOpenNew.
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get importTabOpenNew;

  /// No description provided for @newTabTooltip.
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get newTabTooltip;

  /// No description provided for @closeTabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close tab'**
  String get closeTabTooltip;

  /// No description provided for @renameTabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Long-press to rename'**
  String get renameTabTooltip;

  /// No description provided for @renameTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename tab'**
  String get renameTabTitle;

  /// No description provided for @renameTabFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Tab name'**
  String get renameTabFieldLabel;

  /// No description provided for @renameTabDescription.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the first root note’s title.'**
  String get renameTabDescription;

  /// No description provided for @renameTabSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get renameTabSave;

  /// No description provided for @importEncryptedError.
  ///
  /// In en, this message translates to:
  /// **'Encrypted CherryTree documents (.ctz / .ctx) are not supported yet.'**
  String get importEncryptedError;

  /// No description provided for @importUnsupportedFileType.
  ///
  /// In en, this message translates to:
  /// **'Please choose a CherryTree .ctd or .ctb file.'**
  String get importUnsupportedFileType;

  /// No description provided for @importFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not import: {error}'**
  String importFailedMessage(String error);

  /// No description provided for @importWarningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import notes'**
  String get importWarningsTitle;

  /// No description provided for @importWarningsOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get importWarningsOk;

  /// No description provided for @themeUseLight.
  ///
  /// In en, this message translates to:
  /// **'Use light theme'**
  String get themeUseLight;

  /// No description provided for @themeUseDark.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get themeUseDark;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsUseDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settingsUseDarkTheme;

  /// No description provided for @settingsUseDarkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navy tones similar to desktop CherryTree'**
  String get settingsUseDarkThemeSubtitle;

  /// No description provided for @settingsLayoutSection.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get settingsLayoutSection;

  /// No description provided for @settingsUseSplitLayout.
  ///
  /// In en, this message translates to:
  /// **'Split layout'**
  String get settingsUseSplitLayout;

  /// No description provided for @settingsUseSplitLayoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the tree beside or above the editor with a draggable divider instead of a fixed sidebar or drawer'**
  String get settingsUseSplitLayoutSubtitle;

  /// No description provided for @splitLayoutToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle split layout'**
  String get splitLayoutToggleTooltip;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsLanguageDefault;

  /// No description provided for @menuAddSibling.
  ///
  /// In en, this message translates to:
  /// **'Add sibling'**
  String get menuAddSibling;

  /// No description provided for @menuMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get menuMoveUp;

  /// No description provided for @menuMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get menuMoveDown;

  /// No description provided for @menuIndent.
  ///
  /// In en, this message translates to:
  /// **'Indent (move right)'**
  String get menuIndent;

  /// No description provided for @menuUnindent.
  ///
  /// In en, this message translates to:
  /// **'Unindent (move left)'**
  String get menuUnindent;

  /// No description provided for @menuSortAsc.
  ///
  /// In en, this message translates to:
  /// **'Sort subnodes (A-Z)'**
  String get menuSortAsc;

  /// No description provided for @menuSortDesc.
  ///
  /// In en, this message translates to:
  /// **'Sort subnodes (Z-A)'**
  String get menuSortDesc;

  /// No description provided for @menuToggleBookmark.
  ///
  /// In en, this message translates to:
  /// **'Toggle bookmark'**
  String get menuToggleBookmark;

  /// No description provided for @menuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate node'**
  String get menuDuplicate;

  /// No description provided for @menuNodeProperties.
  ///
  /// In en, this message translates to:
  /// **'Node properties'**
  String get menuNodeProperties;

  /// No description provided for @treeExpandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get treeExpandAll;

  /// No description provided for @treeCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get treeCollapseAll;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Find in Nodes'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, tags, or content...'**
  String get searchHint;

  /// No description provided for @searchMatchCase.
  ///
  /// In en, this message translates to:
  /// **'Match case'**
  String get searchMatchCase;

  /// No description provided for @searchWholeWord.
  ///
  /// In en, this message translates to:
  /// **'Whole word'**
  String get searchWholeWord;

  /// No description provided for @searchRegex.
  ///
  /// In en, this message translates to:
  /// **'Regular expression'**
  String get searchRegex;

  /// No description provided for @searchInContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get searchInContent;

  /// No description provided for @searchInNameAndTags.
  ///
  /// In en, this message translates to:
  /// **'Names & tags'**
  String get searchInNameAndTags;

  /// No description provided for @searchSubnodesOnly.
  ///
  /// In en, this message translates to:
  /// **'Only selected subnodes'**
  String get searchSubnodesOnly;

  /// No description provided for @searchOverrideExclusions.
  ///
  /// In en, this message translates to:
  /// **'Override exclusions'**
  String get searchOverrideExclusions;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 matching node} other{{count} matching nodes}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching nodes found'**
  String get searchNoResults;

  /// No description provided for @searchEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type to search notes in this document'**
  String get searchEmptyPrompt;

  /// No description provided for @searchBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get searchBadgeTitle;

  /// No description provided for @searchBadgeTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get searchBadgeTag;

  /// No description provided for @searchBadgeContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get searchBadgeContent;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Right-click or use the node menu to bookmark notes for quick access.'**
  String get bookmarksEmpty;

  /// No description provided for @bookmarksRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get bookmarksRemoveTooltip;

  /// No description provided for @bookmarksTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTooltip;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Find in nodes (Ctrl+F)'**
  String get searchTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
