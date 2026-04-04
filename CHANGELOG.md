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

### Added <!-- omit in toc -->

- **Contributor safeguards:** GitHub Actions CI on `main` (analyze + test), Dependabot for `pub` and Actions, [`CONTRIBUTING.md`](CONTRIBUTING.md), and [`CODEOWNERS`](.github/CODEOWNERS). Branch protection on `main` (PRs, approvals, Code Owners, **signed commits**) is documented in [`CONTRIBUTING.md`](CONTRIBUTING.md) and the README.
- **Spike B (read-only import):** import unencrypted CherryTree `.ctd` (XML) and `.ctb` (SQLite) via the app bar; tree and plain text come from `rich_text` slots and plain-syntax nodes; images/tables/code boxes are skipped with user-visible warnings; encrypted `.ctz`/`.ctx` are rejected. Dependencies: `xml`, `sqflite`, `file_picker`.
- Integration tests for Android/iOS simulating load, edit, background, and relaunch sequences.
- Added visual save status indicator (pulsing cloud) to the AppBar with resilient concurrent save handling.
- **Dependency policy:** [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md) § Dependencies and [`AGENTS.md`](AGENTS.md) now describe using **stable**, SDK-compatible SemVer constraints, committing `pubspec.lock`, and upgrades via Dependabot or reviewed PRs rather than ad-hoc “always latest” bumps.
- **Notes tree:** expand/collapse branches in the tree panel (chevron); imported documents still start fully expanded; adding a child from the ⋮ menu keeps that parent expanded.
- **Breadcrumbs:** AppBar shows the path from the root to the selected note (e.g. `Parent / Child`), horizontally scrollable on narrow screens; `NoteDocument.pathFromRoot` builds the chain.
- **Dark theme:** optional CherryTree-style navy dark scaffold (`AppTheme.dark`, `AppColors.darkScaffold`); choice persisted with **`shared_preferences`** (`use_dark_theme`). **Settings** screen (`lib/settings_page.dart`) holds the light/dark switch (room for more CherryTree-like categories later); AppBar uses a **settings** icon instead of a separate theme icon.
- **Note body editor:** monospace body field with consistent line height and subtle filled background for a “notes / commands” feel; line breaks preserved as before.

### Fixed

- **Android — import file picker:** `AndroidManifest.xml` declares a `<queries>` intent for `ACTION_OPEN_DOCUMENT` (plus `OPENABLE` / `*/*`) so `resolveActivity` can see the system document UI on **Android 11+**; `MainActivity` extends **`FlutterFragmentActivity`**. Together this fixes the picker not opening on device ([issue #1](https://github.com/huubee/cherrytree-flutter/issues/1) closed).
- **Notes home layout:** wide vs narrow breakpoint uses **`MediaQuery.sizeOf`** instead of a top-level **`LayoutBuilder`**, avoiding a **`RenderLayoutBuilder` / overlay** assertion when `PopupMenuButton`, `Tooltip`, or similar overlays attach during layout.
- **Tree panel:** expansion state is pruned in **`didUpdateWidget`** instead of mutating the expansion set during **`build`**.
- **AppBar title:** title + save indicator **`Row`** uses **`Expanded`** on the title text with **ellipsis** so narrow layouts no longer overflow when many action icons are present.
- **Android `shared_preferences`:** load theme **after the first frame**; theme toggle applies **optimistically** then persists with **`try/catch`** to avoid Pigeon channel errors (`SharedPreferencesApi.getAll`) during early startup or flaky channels.
- **iOS / cloud document providers — import picker:** CherryTree import uses **`FileType.any`** and then validates **`.ctd` / `.ctb`** in the app. **`FileType.custom`** with those extensions maps to **dynamic UTIs** on iOS that **`file_picker` drops**, which left files **greyed out and unselectable** in providers such as **OneDrive**. Wrong extensions show a localized snackbar (`importUnsupportedFileType`).

### Known issues

- **Import with no filesystem path:** Some providers return **bytes only** (no stable sandbox `path`). The import still works for the session, but **`DocumentStoragePrefs` is not set**, so the next launch uses **JSON only** until the user imports again from a source that exposes a path (or a future flow copies the file into app storage). Further UX is tracked in [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md).

## [0.1.0] — 2026-04-03

First changelog entry for the **Spike A foundation** line of work: local hierarchical notes, JSON persistence, localization, theming, debounced saves, and unit tests for core models/repository. Version **0.1.0** reflects **pre–store** development (see **0.x policy** above).

### Added

- Tree of notes + title/body editor (Android & iOS).
- JSON document storage via `NoteRepository` (`spike_a_notes.json` in app documents).
- Generated localization (English, Dutch, German) and shared theme/spacing/timing constants.
- Debounced persistence for edits; immediate save for structural changes; save flush on app pause.
- Injectable `NoteRepository` file path for tests; unit tests for `NoteDocument` and `NoteRepository`.
- Agent-oriented docs: `AGENTS.md`, this changelog, `PATH_OF_ATTACK.md`, `AI_DEVELOPMENT.md`.

### Fixed

- Drawer tree visibility (avoid nested `ListView` layout issues).
- Editor bottom inset so the body field is not covered by system navigation when the keyboard is hidden.

---

When you tag releases in Git (e.g. `v0.2.0`), you can add compare URLs at the bottom of this file using the [Keep a Changelog](https://keepachangelog.com) link style.
