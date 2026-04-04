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

- **Spike B (read-only import):** import unencrypted CherryTree `.ctd` (XML) and `.ctb` (SQLite) via the app bar; tree and plain text come from `rich_text` slots and plain-syntax nodes; images/tables/code boxes are skipped with user-visible warnings; encrypted `.ctz`/`.ctx` are rejected. Dependencies: `xml`, `sqflite`, `file_picker`.
- Integration tests for Android/iOS simulating load, edit, background, and relaunch sequences.
- Added visual save status indicator (pulsing cloud) to the AppBar with resilient concurrent save handling.

### Known issues

- **CherryTree import (AppBar folder icon):** the file picker may not open on device in some cases; tracked for follow-up in [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) (Spike B → Follow-up).

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
