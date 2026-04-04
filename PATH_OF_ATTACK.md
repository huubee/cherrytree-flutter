# Path of attack — cherrytree_flutter

Ordered plan for building the unofficial mobile CherryTree-style notes app. Check items as they land on `main` (or your release branch). For versioning history, see [`CHANGELOG.md`](CHANGELOG.md).

**Legend:** `[x]` done · `[ ]` not started · `[-]` in progress (optional; use sparingly)

---

## Versioning & releases

- **App version** lives in [`pubspec.yaml`](pubspec.yaml) as `version: MAJOR.MINOR.PATCH+BUILD` (Flutter convention: `+BUILD` is the store build number).
- **Early stage:** use **0.x.y** until the app is **Play Store / App Store ready**; then move to **1.0.0+** and keep SemVer. Details: [`CHANGELOG.md`](CHANGELOG.md).
- **Changelog** entries should match tagged releases when you tag them in Git.
- Prefer small, reviewable PRs that map to one or two items below.

---

## Phase 0 — Repository & legal baseline

- [x] GPLv3 + `LICENSE` / attribution / README disclaimer (not the official CherryTree app)
- [x] Android + iOS only (no web/desktop Flutter targets in this repo)
- [x] Document bundle IDs and dev workflow (`README.md`, `DEVELOPMENT_GUIDELINES.md`)

---

## Spike A — Solid mobile foundation (local-only)

Goal: trustworthy tree + editor + persistence on device, without CherryTree file formats yet.

### Core product

- [x] Hierarchical notes (tree) + title/body editor
- [x] Local JSON persistence under app documents (`NoteRepository`, `spike_a_notes.json`)
- [x] First-run seed note (localized via device locale where applicable)
- [x] Debounced save for typing; immediate save for structural changes; flush on app pause / dispose
- [x] Drawer + wide layout; fix nested scroll / safe-area issues on phones

### Quality & maintainability

- [x] `flutter analyze` clean; unit tests for `NoteDocument` + `NoteRepository` (injected file path)
- [x] gen-l10n (EN / NL / DE), theme tokens (spacing, colors, timing)
- [x] `integration_test` on Android (and iOS when feasible): load → edit → background → relaunch
- [x] Save/error feedback UX (e.g. subtle status or retry) beyond snackbar on hard failures
- [x] Split oversized widgets if any file grows past ~300 lines (see `AGENTS.md`)

### Deferred (explicitly not Spike A)

- [ ] Export to CherryTree `.ctd` / `.ctb` (read-only import is Spike B)
- [ ] Round-trip parity with desktop CherryTree files

---

## Spike B — Read real CherryTree documents

- [x] Map upstream storage formats (reference: `lib/cherrytree/` readers; upstream `ct_storage_xml` / `ct_storage_sqlite` in [giuspen/cherrytree](https://github.com/giuspen/cherrytree))
- [x] Read-only import of a narrow subset: unencrypted `.ctd` (XML) and `.ctb` (SQLite); body text from `rich_text` / plain nodes (images, tables, code boxes omitted with messaging)
- [x] Clear UX when a feature is unsupported (replace-data confirmation, post-import warnings, encrypted `.ctz`/`.ctx` rejected)

### Follow-up (addressed on `main`)

- [x] **Import file picker:** AppBar folder action opens the OS file picker (`FilePicker` + replace/import flow). On Android 11+, `AndroidManifest.xml` must declare an `<queries>` intent for `OPEN_DOCUMENT` so `resolveActivity` can see the system document UI; `MainActivity` extends `FlutterFragmentActivity`. (Previously tracked as GitHub [#1](https://github.com/huubee/cherrytree-flutter/issues/1), now closed.) On **iOS**, use **`FileType.any`** and validate `.ctd`/`.ctb` in Dart — **`FileType.custom`** + those extensions maps to UTIs **`file_picker` discards**, which greys out files in **OneDrive** and similar providers.
- [x] **Tree expand/collapse** in the notes panel (chevrons) so large imports are easier to navigate.

### Later UX (not scheduled — desktop parity)

- [x] Path **breadcrumbs** (or subtitle) for the selected node — AppBar `bottom` strip, `NoteDocument.pathFromRoot`, ` / ` join (see `CTAppBar.breadcrumbPath`).
- [x] Optional **dark** theme — `AppTheme.dark()` (navy scaffold via `AppColors.darkScaffold`), **`SettingsPage`** switch, preference `use_dark_theme` in **`shared_preferences`** (`lib/main.dart`). Further CherryTree-like prefs can use the same screen (categories later).
- [x] **Richer body** (phase 1) — body `TextField` uses **monospace**, stable line height (`StrutStyle`), filled outline field; title stays proportional (see `NodeEditor`).
- [ ] **Richer body** (phase 2): checklist widgets, syntax / rich text — after Spike C or as a dedicated spike.

---

## Spike C — Safe round-trip with desktop

- [ ] Save back without corrupting documents that desktop CherryTree can still open
- [ ] Automated checks against reference exports / fixtures

---

## Later (after Spikes A–C)

- [ ] Encryption, multifile storage, attachments, rich text — only after narrow round-trip is proven
- [ ] Store listings, signing, CI release automation (as needed)

---

## How to update this file

When you complete a step, turn `[ ]` into `[x]` in the same PR as the code change, and add a short note under [`CHANGELOG.md`](CHANGELOG.md) **Unreleased** (or the release section you are cutting).
