# Changelog

All notable changes to **cherrytree_flutter** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to **Semantic Versioning** for the `MAJOR.MINOR.PATCH` part of
[`pubspec.yaml`](pubspec.yaml) `version` (the `+BUILD` suffix is the Android/iOS build number).

**0.x policy:** While the app is **early-stage and not store-ready**, `MAJOR` stays **0** (e.g. `0.1.0`, `0.2.0`).
Breaking changes are still allowed during 0.x; bump **MINOR** for notable milestones and **PATCH** for fixes.
When you prepare a public store release, move to **1.0.0** and continue SemVer from there.

---

## [Unreleased]

### Changed

- **App entrypoint:** [`lib/main.dart`](lib/main.dart) is limited to `main()` + `runApp` (and re-exports [`CherrytreeFlutterApp`](lib/app/cherrytree_flutter_app.dart) for tests). Root widget and `MaterialApp` live in [`lib/app/cherrytree_flutter_app.dart`](lib/app/cherrytree_flutter_app.dart); SharedPreferences keys and load/save for theme, split layout, ratios, and locale are in [`lib/app/app_settings.dart`](lib/app/app_settings.dart) (`AppSettings`, `AppSettingsStore`).
- **Split layout** (formerly “portrait split”): the same setting now enables a **horizontal** draggable tree | editor split on **wide** layouts (e.g. phone landscape), with its own persisted ratio; narrow layouts keep the **vertical** split. Wide + split off still uses the fixed sidebar. SharedPreferences keys: `use_split_layout`, `split_layout_ratio_vertical`, `split_layout_ratio_horizontal` (legacy `use_split_layout_portrait` / `split_layout_ratio` are still read for migration).
- **Tree panel:** denser list rows (narrower leading strip, compact padding) so more title text fits in split sidebars.
- Refactored [`lib/notes_home_page.dart`](lib/notes_home_page.dart): CherryTree import/export moved to [`lib/notes/cherrytree_file_actions.dart`](lib/notes/cherrytree_file_actions.dart); wide/narrow layout to [`lib/widgets/notes_home_scaffold.dart`](lib/widgets/notes_home_scaffold.dart). [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md) § Maintainability documents the pattern.

### Added <!-- omit in toc -->

- **Contributor safeguards:** GitHub Actions CI on `main` (analyze + test), Dependabot for `pub` and Actions, [`CONTRIBUTING.md`](CONTRIBUTING.md), and [`CODEOWNERS`](.github/CODEOWNERS). Branch protection on `main` (PRs, approvals, Code Owners, **signed commits**) is documented in [`CONTRIBUTING.md`](CONTRIBUTING.md) and the README.
- **Spike B (read-only import):** import unencrypted CherryTree `.ctd` (XML) and `.ctb` (SQLite) via the app bar; tree and plain text come from `rich_text` slots and plain-syntax nodes; images/tables/code boxes are skipped with user-visible warnings; encrypted `.ctz`/`.ctx` are rejected. Dependencies: `xml`, `sqflite`, `file_picker`.
- Integration tests for Android/iOS simulating load, edit, background, and relaunch sequences.
- Added visual save status indicator (pulsing cloud) to the AppBar with resilient concurrent save handling.
- **Dependency policy:** [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md) § Dependencies and [`AGENTS.md`](AGENTS.md) now describe using **stable**, SDK-compatible SemVer constraints, committing `pubspec.lock`, and upgrades via Dependabot or reviewed PRs rather than ad-hoc “always latest” bumps.
- **Notes tree:** expand/collapse branches in the tree panel (chevron); imported documents still start fully expanded; adding a child from the ⋮ menu keeps that parent expanded.
- **Breadcrumbs:** AppBar shows the path from the root to the selected note (e.g. `Parent / Child`), horizontally scrollable on narrow screens; `NoteDocument.pathFromRoot` builds the chain.
- **Dark theme:** optional CherryTree-style navy dark scaffold (`AppTheme.dark`, `AppColors.darkScaffold`); choice persisted with **`shared_preferences`** (`use_dark_theme`). **Settings** screen (`lib/settings_page.dart`) holds the light/dark switch (room for more CherryTree-like categories later); AppBar uses a **settings** icon instead of a separate theme icon.
- **Split layout:** Optional tree + editor split via adjustable `DraggableSplitView` (vertical on narrow, horizontal on wide when enabled), managed from **Settings** and an **app bar** toggle.
- **Language Selector:** Safely override the system native translation language string mappings manually via `Settings` and `SharedPreferences`.
- **Note body editor:** monospace body field with consistent line height and subtle filled background for a “notes / commands” feel; line breaks preserved as before.

### Fixed

- **Android — system bars (landscape / edge-to-edge):** On **Android 15+** (including **Android 16** and OEM skins such as **One UI**), mandatory edge-to-edge can leave **zero** navigation-bar insets in Flutter’s `MediaQuery`, so the UI drew under the **three-button** strip (often on the **right** in landscape). [`MainActivity`](android/app/src/main/kotlin/nl/bytesnbits/cherrytree_flutter/MainActivity.kt) applies **`WindowInsetsCompat`** for **system bars** and **display cutout** as **`View` padding** on `android.R.id.content`, then clears those inset types for descendants so Flutter does not double-apply them.
- **Android — import file picker:** `AndroidManifest.xml` declares a `<queries>` intent for `ACTION_OPEN_DOCUMENT` (plus `OPENABLE` / `*/*`) so `resolveActivity` can see the system document UI on **Android 11+**; `MainActivity` extends **`FlutterFragmentActivity`**. Together this fixes the picker not opening on device ([issue #1](https://github.com/huubee/cherrytree-flutter/issues/1) closed).
- **Notes home layout:** wide vs narrow breakpoint uses **`MediaQuery.sizeOf`** instead of a top-level **`LayoutBuilder`**, avoiding a **`RenderLayoutBuilder` / overlay** assertion when `PopupMenuButton`, `Tooltip`, or similar overlays attach during layout.
- **Tree panel:** expansion state is pruned in **`didUpdateWidget`** instead of mutating the expansion set during **`build`**.
- **AppBar title:** title + save indicator **`Row`** uses **`Expanded`** on the title text with **ellipsis** so narrow layouts no longer overflow when many action icons are present.
- **Android `shared_preferences`:** load theme **after the first frame**; theme toggle applies **optimistically** then persists with **`try/catch`** to avoid Pigeon channel errors (`SharedPreferencesApi.getAll`) during early startup or flaky channels.
- **iOS / cloud document providers — import picker:** CherryTree import uses **`FileType.any`** and then validates **`.ctd` / `.ctb`** in the app. **`FileType.custom`** with those extensions maps to **dynamic UTIs** on iOS that **`file_picker` drops**, which left files **greyed out and unselectable** in providers such as **OneDrive**. Wrong extensions show a localized snackbar (`importUnsupportedFileType`).

### Known issues

- **Import with no filesystem path:** Some providers return **bytes only** (no stable sandbox `path`). The import still works for the session, but **`DocumentStoragePrefs` is not set**, so the next launch uses **JSON only** until the user imports again from a source that exposes a path (or a future flow copies the file into app storage). Further UX is tracked in [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md).

## [0.3.0] — 2026-04-04

### Added

- **Export:** Save current notes as CherryTree **`.ctd`** (XML) or **`.ctb`** (SQLite) via the app bar (save-as icon) → format sheet → OS save dialog. Uses [`CtdDocumentWriter`](lib/cherrytree/ctd_document_writer.dart) / [`CtbDocumentWriter`](lib/cherrytree/ctb_document_writer.dart); [`CherrytreeDocumentExport`](lib/cherrytree/cherrytree_document_export.dart) builds bytes (SQLite via a temp file on mobile). Localized EN / NL / DE.

## [0.1.0] — 2026-04-03

First changelog entry for the **Spike A foundation** line of work: local hierarchical notes, JSON persistence, localization, theming, debounced saves, and unit tests for core models/repository. Version **0.1.0** reflects **pre–store** development (see **0.x policy** above).

### Added-02

- Tree of notes + title/body editor (Android & iOS).
- JSON document storage via `NoteRepository` (`spike_a_notes.json` in app documents).
- Generated localization (English, Dutch, German) and shared theme/spacing/timing constants.
- Debounced persistence for edits; immediate save for structural changes; save flush on app pause.
- Injectable `NoteRepository` file path for tests; unit tests for `NoteDocument` and `NoteRepository`.
- Agent-oriented docs: `AGENTS.md`, this changelog, `PATH_OF_ATTACK.md`, `AI_DEVELOPMENT.md`.

### Fixed-02

- Drawer tree visibility (avoid nested `ListView` layout issues).
- Editor bottom inset so the body field is not covered by system navigation when the keyboard is hidden.

---

When you tag releases in Git (e.g. `v0.2.0`), you can add compare URLs at the bottom of this file using the [Keep a Changelog](https://keepachangelog.com) link style.
