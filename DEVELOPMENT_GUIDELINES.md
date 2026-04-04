# Development guidelines

This document sets expectations for humans and tools working on **cherrytree_flutter**. It is intentionally short; expand it when patterns stabilize.

For a **generic, framework-wide** checklist (security, workflow, AI-assisted coding), see [`old_DEVELOPMENT_GUIDELINES.md`](old_DEVELOPMENT_GUIDELINES.md) in this repo — useful as extra reference; **this file** is the maintained source of truth for *this* project.

## Product scope

- **Platforms:** Android and iOS only. Do not re-add desktop/web targets unless the project direction changes.
- **Upstream:** The [official CherryTree](https://github.com/giuspen/cherrytree) desktop app remains the reference for behavior and, later, file formats. This repo does not ship or fork that C++ codebase.
- **License:** GPLv3 — see [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). Be careful when copying or adapting upstream concepts; compatibility work may have licensing implications.

## Architecture (current direction)

| Layer | Responsibility |
| ----- | ---------------- |
| **UI** (`lib/…`, widgets, screens) | Layout, navigation, user input. Keep widgets as dumb as practical. |
| **Domain / models** (`lib/models/`) | Data structures (nodes, document graph). No Flutter imports if avoidable. |
| **Persistence** (`lib/services/` or `lib/data/`) | Load/save; file paths; JSON or future formats. No UI. |

Spike A uses a **single JSON file** per device for local notes. That will evolve when CherryTree-compatible import/export appears.

## State management

- **Today:** `StatefulWidget` + a small amount of mutable document state + async `NoteRepository`. That is enough for early spikes.
- **When to introduce a global solution** (Riverpod, Bloc, Provider, etc.): when you have multiple screens that must share the same document, complex undo/redo, or testability pain from deeply nested `setState`.
- **Rule of thumb:** Prefer one clear owner of the document (e.g. a notifier or repository facade) before adding more feature screens.

## Persistence and testing

- Documents live under the app’s **application documents** directory (see `path_provider`). Paths differ per OS/emulator.
- **Widget tests** do not get real plugin paths unless you mock channels or inject a fake repository. Smoke tests that only mount `MaterialApp` are fine; deeper tests should use fakes or `path_provider` test setup.
- After load, **never** reassign the in-memory document from an immutable `FutureBuilder` snapshot on every rebuild — that resets user edits. Use `??=` or a dedicated “loaded once” flag.

## Dependencies

- Add packages with a **one-line rationale** in the PR/commit (e.g. “path_provider: OS document directory”).
- Prefer **small, maintained** packages; avoid pulling in a large framework for a single call site unless the team agrees.
- **Versions:** add dependencies at **stable** releases that satisfy [`pubspec.yaml`](pubspec.yaml) **`environment.sdk`** and Flutter’s constraints. Use normal **SemVer** ranges from pub.dev (typically **`^x.y.z`**, e.g. via `flutter pub add` or a hand-edited constraint); commit **`pubspec.lock`** with the change.
- Do **not** treat “always the newest version on pub.dev” as a standing rule — that creates unnecessary churn. **Dependabot** (see [`.github/dependabot.yml`](.github/dependabot.yml)) and intentional PRs handle upgrades; skim **changelogs** for **major** bumps and mention breaking changes in the PR when relevant.

## Maintainability: file size, DRY, comments

These ideas align with common practice and with the generic template in [`old_DEVELOPMENT_GUIDELINES.md`](old_DEVELOPMENT_GUIDELINES.md); they are adapted for Flutter and this codebase.

### File size and structure

- **Soft limit:** aim for **about 300 lines or fewer** per library file. If a file keeps growing, it is usually doing too much — split out widgets, models, or helpers.
- **One primary public type per file** when practical (e.g. one screen widget, one repository class). Small `part` files or private classes in the same file are fine if they stay easy to navigate.

### DRY and reusable pieces

- **Don’t copy-paste** identical UI or logic; extract **widgets** (`lib/widgets/` or under a feature folder) or **functions** / **extensions** when the same pattern appears three times or is clearly reusable.
- **Prefer composition** over giant widgets: small, named widgets are easier to test and reuse.
- Repeated **layout values** (padding, radii) should eventually live in **theme** or a small shared constants module — avoid scattering magic numbers once the design stabilizes.

### Comments: explain **why**, not **what**

- Prefer comments that capture **intent**, **tradeoffs**, **invariants**, or **non-obvious bugs** (e.g. why a `FutureBuilder` must not overwrite mutable state every frame).
- Avoid comments that only repeat the next line of code (`// increment i`).
- Use `TODO(name, …)` or issue links for deliberate follow-ups.

### User-facing strings and theming

- **Long term:** plan for **internationalization** (Flutter gen-l10n / `AppLocalizations`) so strings are not hardcoded forever.
- **Short term (Spike A):** literal strings in UI are acceptable; when adding new screens, keep strings in obvious places so they are easy to migrate to ARB files later.
- Prefer **`Theme.of(context)`** / **`ColorScheme`** / **`TextTheme`** over one-off hex colors and raw font sizes where it keeps the UI consistent.

### Logging

- Do not rely on **`print`** for permanent diagnostics in library code; use **`dart:developer`** (`log`) or a small app logger with levels, especially in release-oriented paths.
- Never log secrets, tokens, or full note bodies if they could be sensitive.

## Code style

- Follow [`analysis_options.yaml`](analysis_options.yaml) and `flutter_lints`.
- Run `dart format` / IDE format on changed files before merge.
- Prefer **`const`** constructors where possible; prefer **`StatelessWidget`** when there is no mutable state.

## What not to do

- Don’t commit secrets, keystores, or App Store Connect tokens.
- Don’t expand scope into “full desktop parity” in one PR; use spikes and issues to slice work.

## Pre-merge checklist (lightweight)

- `flutter analyze` clean; `flutter test` passing (or explain skipped tests).
- No stray `print` / debug noise intended only for local debugging.
- If you touched user-visible behavior, update [`README.md`](README.md) when it matters to contributors or users.
