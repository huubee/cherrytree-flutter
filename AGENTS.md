# Agent / automation notes

Guidance for AI assistants and automation working in this repository.

**Start here for orientation:** [`AI_DEVELOPMENT.md`](AI_DEVELOPMENT.md) (short context for tools like Gemini/Cursor), then return to this file for rules. **Planned work (checkboxes):** [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md). **Release history:** [`CHANGELOG.md`](CHANGELOG.md).

For human-oriented development practices, see [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md).

## Project identity

- **Name:** `cherrytree_flutter` (Dart package) / GitHub repo `cherrytree-flutter`.
- **Purpose:** Unofficial Flutter client for CherryTree-style hierarchical notes on **Android and iOS** — not the official [giuspen/cherrytree](https://github.com/giuspen/cherrytree) desktop app.

## Boundaries

- **Do not** modify the upstream CherryTree C++ repository as part of this work unless the user explicitly asks for a separate contribution flow.
- **Do not** reintroduce `web/`, `windows/`, `linux/`, or `macos/` platform folders unless the maintainers change scope.
- **Keep diffs focused:** match existing style; avoid unrelated refactors and drive-by dependency upgrades.

## Commands to verify changes

```bash
cd cherrytree_flutter   # or the full path on the contributor’s machine
flutter pub get
flutter analyze
flutter test
```

Optional: `flutter build apk --debug` (Android) — iOS builds require macOS/Xcode.

## Architecture hints for agents

- **Models** should stay free of Flutter when possible (`lib/models/`).
- **Persistence** belongs in services/repositories; **widgets** should not construct file paths directly.
- **Stateful async loading:** If using `FutureBuilder`, do not assign mutable app state from `snapshot.data` on every rebuild if that snapshot is stale — it will overwrite user edits. Prefer `??=` or loading exactly once into state.
- **File size:** prefer **~300 lines or fewer** per file; split widgets and helpers instead of growing one file indefinitely.
- **DRY:** extract repeated UI into widgets or shared helpers; avoid copy-paste across screens.
- **Comments:** explain **why** (intent, invariants, gotchas), not what the code already says.
- For more detail, see [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md) § Maintainability.

## Licensing

- GPLv3 — see [`LICENSE`](LICENSE). When suggesting code derived from CherryTree upstream, remind the user about license compatibility.

## Documentation

- Prefer updating [`README.md`](README.md) for user-visible behavior.
- Use [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md) for engineering conventions; update it when state-management or layering decisions change.
