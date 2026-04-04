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

- [ ] Import/export CherryTree `.ctd` / `.ctb`
- [ ] Round-trip parity with desktop CherryTree files

---

## Spike B — Read real CherryTree documents

- [ ] Map upstream storage formats (`ct_storage_*`, tests in [giuspen/cherrytree](https://github.com/giuspen/cherrytree))
- [ ] Read-only open of a narrow subset (e.g. unencrypted XML / SQLite paths as agreed)
- [ ] Clear UX when a feature is unsupported (import partial view, messaging)

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
