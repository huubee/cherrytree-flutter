// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cherrytree Flutter';

  @override
  String get loading => 'Loading…';

  @override
  String get noOpenDocuments => 'No open documents.';

  @override
  String get saveFailed =>
      'Could not save notes. Check storage permissions and free space.';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get addRootNoteTooltip => 'Add root note';

  @override
  String get drawerNotesTitle => 'Notes';

  @override
  String get menuAddChild => 'Add child';

  @override
  String get menuDeleteSubtree => 'Delete subtree';

  @override
  String get untitledNote => 'Untitled';

  @override
  String get emptyEditorHint => 'Select a note or add one.';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldBody => 'Body';

  @override
  String get newNoteTitle => 'New note';

  @override
  String get seedWelcomeTitle => 'Welcome';

  @override
  String get seedWelcomeBody =>
      'Spike B: local tree of notes with read-only import of unencrypted CherryTree .ctd (XML) and .ctb (SQLite) files. Rich text is shown as plain text; images and tables are omitted.';

  @override
  String get exportCherryTreeTooltip => 'Export to CherryTree file';

  @override
  String get exportCherryTreeSheetTitle => 'Export format';

  @override
  String get exportAsCtdTitle => 'XML (.ctd)';

  @override
  String get exportAsCtdSubtitle =>
      'Single-file document; good for small trees and diff-friendly text.';

  @override
  String get exportAsCtbTitle => 'SQLite (.ctb)';

  @override
  String get exportAsCtbSubtitle =>
      'Database file; better for large documents on mobile and desktop.';

  @override
  String get exportCherryTreeDialogTitle => 'Save CherryTree export';

  @override
  String get exportFileNameDialogTitle => 'File name';

  @override
  String get exportFileNameFieldLabel => 'Name';

  @override
  String get exportFileNameContinue => 'Continue';

  @override
  String get exportDestinationSheetTitle => 'Where to put the file?';

  @override
  String get exportSaveToDeviceTitle => 'Save to this device';

  @override
  String get exportSaveToDeviceSubtitle => 'Choose a folder (local storage)';

  @override
  String get exportShareTitle => 'Share via another app';

  @override
  String get exportShareSubtitle =>
      'Cloud storage, email, or other destinations';

  @override
  String get exportCherryTreeSuccess => 'Export saved.';

  @override
  String get exportCherryTreeShareSuccess => 'Share sheet opened.';

  @override
  String exportCherryTreeFailed(String error) {
    return 'Could not export: $error';
  }

  @override
  String get importCherryTreeTooltip => 'Import CherryTree file';

  @override
  String get importReplaceTitle => 'Replace local notes?';

  @override
  String get importReplaceMessage =>
      'This replaces all notes stored in this app with the imported CherryTree document. Continue?';

  @override
  String get importCancel => 'Cancel';

  @override
  String get importReplaceConfirm => 'Replace';

  @override
  String get importTabTargetTitle => 'Import location';

  @override
  String get importTabTargetMessage =>
      'Replace the current tab’s notes or open the import in a new tab?';

  @override
  String get importTabReplaceCurrent => 'Replace current tab';

  @override
  String get importTabOpenNew => 'New tab';

  @override
  String get newTabTooltip => 'New tab';

  @override
  String get closeTabTooltip => 'Close tab';

  @override
  String get renameTabTooltip => 'Long-press to rename';

  @override
  String get renameTabTitle => 'Rename tab';

  @override
  String get renameTabFieldLabel => 'Tab name';

  @override
  String get renameTabDescription =>
      'Leave empty to use the first root note’s title.';

  @override
  String get renameTabSave => 'Save';

  @override
  String get importEncryptedError =>
      'Encrypted CherryTree documents (.ctz / .ctx) are not supported yet.';

  @override
  String get importUnsupportedFileType =>
      'Please choose a CherryTree .ctd or .ctb file.';

  @override
  String importFailedMessage(String error) {
    return 'Could not import: $error';
  }

  @override
  String get importWarningsTitle => 'Import notes';

  @override
  String get importWarningsOk => 'OK';

  @override
  String get themeUseLight => 'Use light theme';

  @override
  String get themeUseDark => 'Use dark theme';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsUseDarkTheme => 'Dark theme';

  @override
  String get settingsUseDarkThemeSubtitle =>
      'Navy tones similar to desktop CherryTree';

  @override
  String get settingsLayoutSection => 'Layout';

  @override
  String get settingsUseSplitLayout => 'Split layout';

  @override
  String get settingsUseSplitLayoutSubtitle =>
      'Show the tree beside or above the editor with a draggable divider instead of a fixed sidebar or drawer';

  @override
  String get splitLayoutToggleTooltip => 'Toggle split layout';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageDefault => 'System Default';

  @override
  String get menuAddSibling => 'Add sibling';

  @override
  String get menuMoveUp => 'Move up';

  @override
  String get menuMoveDown => 'Move down';

  @override
  String get menuIndent => 'Indent (move right)';

  @override
  String get menuUnindent => 'Unindent (move left)';

  @override
  String get menuSortAsc => 'Sort subnodes (A-Z)';

  @override
  String get menuSortDesc => 'Sort subnodes (Z-A)';

  @override
  String get menuToggleBookmark => 'Toggle bookmark';

  @override
  String get menuDuplicate => 'Duplicate node';

  @override
  String get menuNodeProperties => 'Node properties';

  @override
  String get treeExpandAll => 'Expand all';

  @override
  String get treeCollapseAll => 'Collapse all';

  @override
  String get searchTitle => 'Find in Nodes';

  @override
  String get searchHint => 'Search title, tags, or content...';

  @override
  String get searchMatchCase => 'Match case';

  @override
  String get searchWholeWord => 'Whole word';

  @override
  String get searchRegex => 'Regular expression';

  @override
  String get searchInContent => 'Content';

  @override
  String get searchInNameAndTags => 'Names & tags';

  @override
  String get searchSubnodesOnly => 'Only selected subnodes';

  @override
  String get searchOverrideExclusions => 'Override exclusions';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matching nodes',
      one: '1 matching node',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResults => 'No matching nodes found';

  @override
  String get searchEmptyPrompt => 'Type to search notes in this document';

  @override
  String get searchBadgeTitle => 'Title';

  @override
  String get searchBadgeTag => 'Tag';

  @override
  String get searchBadgeContent => 'Content';

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get bookmarksEmpty =>
      'No bookmarks yet. Right-click or use the node menu to bookmark notes for quick access.';

  @override
  String get bookmarksRemoveTooltip => 'Remove bookmark';

  @override
  String get bookmarksTooltip => 'Bookmarks';

  @override
  String get searchTooltip => 'Find in nodes (Ctrl+F)';
}
