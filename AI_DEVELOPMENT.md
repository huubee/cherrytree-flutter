# AI development context (Gemini, Copilot, Cursor, etc.)

Short, **task-oriented** context for automated and assistant-driven work. Humans should still read [`README.md`](README.md) for the full picture.

## Read order (do not skip)

1. This file — **current intent** and constraints.
2. [`AGENTS.md`](AGENTS.md) — boundaries, verify commands, architecture rules.
3. [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) — what is done vs planned (checkboxes).
4. [`CHANGELOG.md`](CHANGELOG.md) — what changed recently; align version in [`pubspec.yaml`](pubspec.yaml) when you cut a release.
5. [`CONTRIBUTING.md`](CONTRIBUTING.md) — for **human** PRs: CI expectations, reviews, and scope (automation should still follow [`AGENTS.md`](AGENTS.md)).
6. [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md) — style and maintainability (if present).

## What this project is

- **Unofficial** Flutter app for **Android and iOS** only: CherryTree-*style* hierarchical notes.
- **Not** the [official CherryTree](https://github.com/giuspen/cherrytree) desktop repo; do not edit upstream unless the user asks for a separate contribution.
- **Spike A:** local tree + editor + JSON persistence.
- **Spike B:** read-only import of unencrypted `.ctd` / `.ctb` (see `lib/cherrytree/`); no write-back to CherryTree files yet ([`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md)). On Android 11+, the manifest must include `OPEN_DOCUMENT` `<queries>` and `MainActivity` must extend `FlutterFragmentActivity` so the file picker opens reliably.

## Default workflow for agents

1. Make the **smallest change** that satisfies the user request and [`AGENTS.md`](AGENTS.md) boundaries.
2. Run **`flutter pub get`** if dependencies changed; otherwise run **`flutter analyze`** and **`flutter test`** from the `cherrytree_flutter` directory.
3. Update **[`CHANGELOG.md`](CHANGELOG.md)** under **Unreleased** when the change is user-visible or architecturally significant.
4. If you complete a **planned milestone** item, check it off in **[`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md)** in the same change.

## Versioning (when you touch releases)

- `pubspec.yaml` field **`version:`** uses `MAJOR.MINOR.PATCH+BUILD`.
- **Now:** **`0.x.y`** — early development, **not** store-ready. Bump **MINOR** for meaningful milestones, **PATCH** for fixes; breaking changes are still acceptable during 0.x.
- **Later:** when targeting store release, move to **`1.0.0`** and treat **MAJOR** as breaking for app/data.
- Increment **+BUILD** for every store submission (Android/iOS) once you ship.
- Add a dated section in **`CHANGELOG.md`** when the maintainer tags a release (e.g. `0.1.1` or `0.2.0`).

## Tech anchors

| Area | Location |
| ---- | -------- |
| Document model | `lib/models/note_document.dart` |
| Persistence | `lib/services/note_repository.dart` (JSON file) |
| CherryTree import (read-only) | `lib/cherrytree/` (`.ctd` XML, `.ctb` SQLite) |
| Main UI | `lib/notes_home_page.dart` |
| Localization | `lib/l10n/*.arb`, generated `lib/l10n/app_localizations*.dart` |
| Theme / spacing / debounce | `lib/theme/`; `shared_preferences` (`use_dark_theme`) and **`SettingsPage`** (`lib/settings_page.dart`) from **`NotesHomePage`** |

## Anti-patterns (see `AGENTS.md` for detail)

- Overwriting mutable document state from **`FutureBuilder.snapshot`** on every rebuild — use one-shot load into state (current code uses explicit `_loadDocument()`).
- Nesting scrollables in the drawer (e.g. `ListView` inside `ListView`) without bounded height — use `Column` + `Expanded` + inner `ListView`.
- Adding **web/desktop** platform folders without an explicit scope change.

## Licensing

- **GPLv3** — see [`LICENSE`](LICENSE). Preserve notices when copying from upstream CherryTree.
