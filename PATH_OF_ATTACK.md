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

- [x] Export to CherryTree `.ctd` / `.ctb` (app bar **save as** → format sheet → system save dialog; [`CherrytreeDocumentExport`](lib/cherrytree/cherrytree_document_export.dart))
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

## CherryTree parity inventory (manual + upstream code)

Cross-check desktop behaviour against the **CherryTree User Manual** ([giuspen.net/cherrytreemanual](http://giuspen.net/cherrytreemanual/), mirror [giuspen.com/cherrytreemanual](https://giuspen.com/cherrytreemanual/)) and the **reference C++ sources** in [giuspen/cherrytree](https://github.com/giuspen/cherrytree) (notably [`src/ct/ct_treestore.h`](https://github.com/giuspen/cherrytree/blob/master/src/ct/ct_treestore.h) `CtNodeData`, [`src/ct/ct_config.h`](https://github.com/giuspen/cherrytree/blob/master/src/ct/ct_config.h) `CtConfig`). The HTML manual may lag the current app; confirm renamed or new features in upstream when implementing.

A **broader feature narrative** (third-party checklist) lives in [`EXTENSIVE_LIST.md`](EXTENSIVE_LIST.md); rows below remain the **authoritative T/L/S** tracking tables. Merge new ideas from `EXTENSIVE_LIST.md` here when you commit to implementing them.

**Triage tags (this section only):**

| Tag | Meaning |
|-----|---------|

| **T** | Target for this Flutter app — use `- [ ]` / `- [x]` when tracking backlog. |
| **L** | Later — desirable parity but blocked on spikes, editor depth, or scope. |
| **S** | Skip — desktop-only or explicitly out of scope for mobile unless revisited. |

Only **T** rows use task checkboxes so **L** / **S** items do not imply commitment.

### Upstream per-node model (`CtNodeData`)

Fields in `CtNodeData` (persistence for ordinary nodes; shared-node fields omitted here): `nodeId`, `sequence`, `name`, `syntax`, `tags`, `isReadOnly`, `customIconId`, `isBold`, `excludeMeFromSearch`, `excludeChildrenFromSearch`, `foregroundRgb24`, `tsCreation`, `tsLastSave`, plus text buffer / anchored widgets for body content.

### Per-node: New / Change Node Properties (manual §6.1; dialog)

| Feature | Tag | Notes |
|---------|-----|-------|

| Node name | T | [x] `NoteNode.title` |
| Bold title in tree | T | [ ] not in `NoteNode`; XML `is_bold` not round-tripped |
| Custom title color | T | [ ] `foregroundRgb24` |
| Custom stock icon | T | [x] import + tree display `customIconId`; [ ] in-app picker + edit properties UI |
| Node type: rich / plain / code + language | L | `syntax`; Spike B reads; editor is rich-first |
| Tags for search | T | [ ] `tags` |
| Read-only | T | [ ] `isReadOnly` |
| Exclude this node / subnodes from search | L | `excludeMeFromSearch`, `excludeChildrenFromSearch` |
| Unique id (read-only in dialog) | S | informational; maps to storage ids |

### Tree operations (manual §6.2)

| Feature | Tag | Notes |
|---------|-----|-------|

| Add sibling / subnode | T | [x] structural actions in app (verify parity with desktop semantics) |
| Rename node title | T | [x] `NodeEditor` title field (not tree inline-F2) |
| Duplicate node | L | |
| Bookmarks add/remove | L | |
| Insert today’s node | S | desktop convenience; optional **L** |
| Tree info (counts) | L | |
| Move up/down/left/right, change parent | L | drag reorder **S** on mobile; buttons **L** |
| Sort tree / sort branch | L | |
| Find / replace in node names and tags | L | |
| Inherit syntax from parent | L | code nodes |
| Delete node | T | [x] |
| Selection history back/forward | L | |

### Files & storage (manual §5)

| Feature | Tag | Notes |
|---------|-----|-------|

| New / open / recent | L | mobile uses JSON + import; full “recent docs” **L** |
| Save / Save As | L | Spike C writes `.ctd`/`.ctb` |
| SQLite vs XML, `.ctx`/`.ctz` encrypted | L | encryption **Later** (see Spike C / Later) |
| Save and Vacuum (SQLite) | L | |
| Password change via Save As | L | |
| Page setup / print | S | |
| Import from other apps (HTML, folder, …) | L | narrow import may stay CherryTree-only |
| Export PDF/HTML/txt/CT | L | |
| CLI open/export | S | |

### Text & formatting (manual §7)

| Feature | Tag | Notes |
|---------|-----|-------|

| Plain / rich / syntax node bodies | L | rich path via Quill; plain/code **L** |
| Editing, formatting, lists, etc. | L | rich text phase 2; see Spike B omissions |
| Search in node content (manual §7.6) | L | |

### Search & replace (advanced; desktop “Find” dialog)

| Feature | Tag | Notes |
|---------|-----|-------|

| Case-sensitive / match whole word / regex | L | |
| Scope: current node, node + subnodes, whole tree | L | |
| Replace in body (incl. multi-node / batch) | L | |
| Replace in node names / tags (see tree ops) | L | overlaps “Find in node names” |

### Supplemental checklist (Gemini / `EXTENSIVE_LIST.md` gaps)

Items called out in [`EXTENSIVE_LIST.md`](EXTENSIVE_LIST.md) that are not spelled out in the tables above; **L** unless the app explicitly skips them (**S**).

| Feature | Tag | Notes |
|---------|-----|-------|

| Rich text headers H4–H6 (not only H1–H3) | L | desktop supports scalable tags |
| Table: column sort; export table to CSV | L | |
| Image: rotate; save image as PNG | L | import of images partial |
| Multifile XML (document as folder) | L | multifile storage in “Later” |
| Focus / distraction-free mode (hide tree or toolbar) | L | mobile layout differs |
| Extensive keyboard shortcut map (tablet + keyboard) | L | optional cheat sheet |
| Inter-app copy/paste preserving rich text | L | strong mobile UX target |
| Competitor imports (KeepNote, Zim, Tomboy, …) | L | CherryTree-only import for now |

### Embedded objects (manual §8)

| Feature | Tag | Notes |
|---------|-----|-------|

| Images | L | import warns / omits |
| Tables | L | |
| Codebox | L | |
| Embedded files | L | |
| Links (web, file, node, folder) | L | partial rich handling |
| Anchors, TOC, timestamps, special chars, horizontal rule | L | |

### App-wide preferences (manual §9; `CtConfig`)

**Text & code (§9.1–9.4):** tab width, spaces/tabs, wrapping, indent, line numbers, vertical spacing, timestamp format, horizontal rule, special chars, double-click word chars, smart quotes, symbol replace, spell check, RT/PT themes, whitespace / current line / codebox / embedded file / undo limit, PT/code style schemes, **code execution** + terminal — mostly **L**; spell check **L**; execution **S** on mobile.

**Tree (§9.5–9.6):** tree light/dark/custom colors; **default node icons** (cherries per level / single icon / none) — **T** partial ([`CherrytreeNodeIconTheme`](lib/cherrytree/cherrytree_node_icon_theme.dart), [ ] load in UI + Settings); aux icon hide; restore expand/collapse; expand all / collapse all; bookmarks visible — **L** (expand state [x] session-only); tree right side **S**/minimal **L**; click-to-focus text, click-to-expand — **L**; last visited nodes in header **S**.

**Fonts (§9.7):** RT/PT/code/tree fonts — **L** (mobile system + theme tokens first).

**Links (§9.8):** custom actions, link colors, underline, relative paths, anchor size — **L**.

**Toolbar (§9.9):** configurable toolbar — **S**.

**Keyboard shortcuts (§9.10):** — **L** (platform conventions; optional cheat sheet).

**Misc (§9.11):** autosave, backups, systray, proxy, word count, etc. — **L** / **S** as appropriate (autosave [x] app debounce; backup copies **L**).

### Quick reference: manual TOC → sections

| Manual § | Topic |
|----------|-------|

| 4 | Quick start: interface, node management, insert objects, save, export |
| 5 | Files: open/save, vacuum, storage types, password, print, import/export formats, CLI |
| 6 | Nodes: create properties, manage tree |
| 7 | Text: plain, rich, syntax highlighting, editing, formatting, search |
| 8 | Objects: images, tables, codebox, files, links, anchors, TOC, timestamps, … |
| 9 | Settings: text/code, tree, fonts, links, toolbar, shortcuts, misc |

---

## How to update this file

When you complete a step, turn `[ ]` into `[x]` in the same PR as the code change, and add a short note under [`CHANGELOG.md`](CHANGELOG.md) **Unreleased** (or the release section you are cutting).

**Parity inventory:** Rows in [CherryTree parity inventory](#cherrytree-parity-inventory-manual--upstream-code) follow the same rule: when a **T** item is implemented, set its checkbox to `[x]` in the same PR and mention the behaviour in **Unreleased**. If the manual and code disagree, prefer **`CtNodeData` / `CtConfig`** and add a short note in the table. Re-skim the manual or upstream on major CherryTree releases if parity matters. Narrative checklists such as [`EXTENSIVE_LIST.md`](EXTENSIVE_LIST.md) should be merged into the parity tables when work is scheduled, not left as a second source of truth for **T**/**L**/**S**.
