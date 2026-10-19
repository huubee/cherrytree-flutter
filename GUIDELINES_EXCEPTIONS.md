# Guideline exceptions

This file adds to [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md). Where these exceptions conflict with that document, they win for this repository only.

## Product scope

- **Platforms:** Android and iOS only. Do not re-add desktop or web targets (`web/`, `windows/`, `linux/`, `macos/`) unless the project direction changes.
- **Upstream:** The [official CherryTree](https://github.com/giuspen/cherrytree) desktop app remains the reference for behavior and, later, file formats. This repo does not ship or fork that C++ codebase.
- **License:** GPLv3 — see [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). Be careful when copying or adapting upstream concepts; compatibility work may have licensing implications.
- Do not expand scope into full desktop parity in one PR; use spikes and issues to slice work.

## Architecture

This repo does not use the feature-first `lib/features/<feature>/data|domain|presentation` tree in section 2.

| Layer | Responsibility |
| ----- | ---------------- |
| **UI** (`lib/…`, widgets, screens) | Layout, navigation, user input. Keep widgets as dumb as practical. |
| **App shell** (`lib/main.dart`, `lib/app/`) | Process entry (`main`, `runApp`), root `MaterialApp` ([`cherrytree_flutter_app.dart`](lib/app/cherrytree_flutter_app.dart)), and device-persisted **app-wide** UI prefs ([`app_settings.dart`](lib/app/app_settings.dart)) — not document data. |
| **Domain / models** (`lib/models/`) | Data structures (nodes, document graph). No Flutter imports if avoidable. |
| **Persistence** (`lib/services/` or `lib/data/`) | Load/save; file paths; JSON or future formats. No UI. |

Local notes are a **single JSON file** per device. That will evolve when CherryTree-compatible import/export appears.

### Refactoring hotspots

- **`lib/main.dart`** — keep as a **thin** entry: `WidgetsFlutterBinding`, `runApp`, and optionally `export` for tests. Put **`MaterialApp`** and startup state in [`lib/app/cherrytree_flutter_app.dart`](lib/app/cherrytree_flutter_app.dart); put **SharedPreferences** keys and read/write for theme / layout / locale in [`lib/app/app_settings.dart`](lib/app/app_settings.dart).
- **`lib/notes_home_page.dart`** — owns document load, debounced save, and tree/edit actions. Keep it **under ~300 lines**; move new **import/export** or **dialogs** into `lib/notes/` (see [`cherrytree_file_actions.dart`](lib/notes/cherrytree_file_actions.dart)) and **layout shells** into `lib/widgets/` (see [`notes_home_scaffold.dart`](lib/widgets/notes_home_scaffold.dart)).
- **Feature-adjacent helpers** can live under **`lib/notes/`** without pulling in Flutter where avoidable; keep **models** in `lib/models/` and **persistence** in `lib/services/`.

## State management

Section 5’s Riverpod / Bloc / BlocSignals choice is not in force here yet.

- **Today:** `StatefulWidget` + a small amount of mutable document state + async `NoteRepository`. That is enough for early spikes.
- **When to introduce a global solution** (Riverpod, Bloc, Provider, etc.): when multiple screens must share the same document, complex undo/redo appears, or deeply nested `setState` hurts testability.
- **Rule of thumb:** Prefer one clear owner of the document (for example a notifier or repository facade) before adding more feature screens.
- Do not pull in a large framework for a single call site unless the team agrees.

## Persistence and testing

- Documents live under the app’s **application documents** directory (see `path_provider`). Paths differ per OS and emulator.
- **Widget tests** do not get real plugin paths unless channels are mocked or a fake repository is injected. Smoke tests that only mount `MaterialApp` are fine; deeper tests should use fakes or `path_provider` test setup.
- After load, **never** reassign the in-memory document from an immutable `FutureBuilder` snapshot on every rebuild — that resets user edits. Use `??=` or a dedicated “loaded once” flag.

## Dependencies

Section 15’s baseline pins are not this app’s lockfile.

- Add packages with a **one-line rationale** in the PR or commit (for example “path_provider: OS document directory”).
- Prefer **small, maintained** packages.
- **Versions:** add dependencies at **stable** releases that satisfy [`pubspec.yaml`](pubspec.yaml) **`environment.sdk`** and Flutter’s constraints. Use normal **SemVer** ranges from pub.dev (typically **`^x.y.z`**); commit **`pubspec.lock`** with the change.
- Do **not** treat “always the newest version on pub.dev” as a standing rule. **Dependabot** (see [`.github/dependabot.yml`](.github/dependabot.yml)) and intentional PRs handle upgrades. Skim changelogs for **major** bumps and mention breaking changes in the PR when relevant.

## File size

The section 1 / section 12 limit of 200–250 lines is a **soft limit of about 300 lines** in this repo. If a file keeps growing, split out widgets, models, or helpers.

- **One primary public type per file** when practical (one screen widget, one repository class). Small `part` files or private classes in the same file are fine if they stay easy to navigate.
- **Generated or data-heavy files** (for example long static lists) may exceed the limit. Add a short header comment pointing to the generator or upstream source so they are not edited by hand.
- Do not copy-paste identical UI or logic. Extract a widget (`lib/widgets/` or a feature folder), function, or extension when the same pattern appears three times or is clearly reusable. Prefer composition over giant widgets.

### Comments

Section 11 already requires comments to explain why. In this repo, also apply that when closing a slice or touching a file for a fix, refactor, or review: add a short note for behavior a reader will not infer (native lifecycle ordering, plugin timing, OEM quirks, one-off layout choices). The `FutureBuilder` rule in Persistence and testing is one of those cases. Use `TODO(name, …)` or an issue link for deliberate follow-ups.

## Strings, theming, and logging

- **Strings:** use Flutter **gen-l10n** (`AppLocalizations`, `lib/l10n/*.arb`) for user-visible text. This repo does not use an `AppStrings` class.
- Prefer **`Theme.of(context)`** / **`ColorScheme`** / **`TextTheme`** over one-off hex colors and raw font sizes. This app still imports Material from `package:flutter/material.dart`. It does not use `package:material_ui` or a `lib/app/constants/` token set. Repeated layout values (padding, radii) should move into the theme or a small shared constants module once the design stabilizes.
- Do not rely on **`print`** for permanent diagnostics in library code; use **`dart:developer`** (`log`) or a small app logger with levels. Never log secrets, tokens, or full note bodies.

## Analyzer

Follow this repo’s [`analysis_options.yaml`](analysis_options.yaml) and `flutter_lints`. Do not replace that file with the section 3.1 snippet. Run `dart format` on changed files before merge. Prefer **`const`** constructors and **`StatelessWidget`** when there is no mutable state.

## User manual

- **Location:** [`docs/USER_MANUAL.md`](docs/USER_MANUAL.md) — written for people using the app, not for implementation details.
- **Why it exists:** Updating this file as features land avoids writing the manual only at the end, and it reduces drift between what the app does and what the docs claim.
- **When to update:** In the **same PR** as a change that adds or materially changes **user-visible** behavior (new flows, buttons, limits, or troubleshooting). A short paragraph or bullet list is enough.
- **What not to duplicate:** Keep architecture, file formats, and contributor setup in this file, [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md), [`README.md`](README.md), or code. The user manual stays task-oriented.
- On merge, `flutter analyze` is clean and `flutter test` passes (or skipped tests are explained). If user-visible behavior changed, update [`README.md`](README.md) when it matters to contributors or users, and update the user manual when it matters to end users.
