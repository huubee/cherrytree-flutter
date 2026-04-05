# Companion app — reflection notes from design discussions

This file captures themes from recent conversations so you can **read them in one place**, adjust expectations, and decide **what to pursue now vs later**. It is not a committed roadmap; update or replace it as your plan solidifies.

**Audience:** maintainers planning scope for **cherrytree_flutter** as a **mobile companion** to desktop CherryTree — not a feature‑for‑feature clone.

---

## 1. Product positioning (your words, summarized)

- **Desktop CherryTree** remains where **power users** do most work (syntax highlighting for 50+ languages, deep rich features, etc.).
- **This app** targets **on the go**: quick capture, small edits, reading — when an idea appears or something must be fixed away from the desk.
- **Popularity hinge:** users must trust **import → edit on phone → export → open on desktop** without **silent loss** of structure or formatting they care about. That round‑trip story is more critical for adoption than matching every desktop bell and whistle on mobile.

Use this when prioritizing: **fidelity on the paths users actually round‑trip** beats **parity on features they rarely need on a phone**.

---

## 2. Inter‑app copy / paste (rich paste from browser)

**CherryTree author’s hint:** prioritise **inter‑app copy/paste**, including **keeping formatting when pasting from a browser** — a core desktop power‑user habit.

**Assessment:**

- On **mobile**, clipboard behaviour is **less consistent** than on desktop; HTML on the pasteboard depends on the source app.
- **flutter_quill** thinks in **Deltas**, not arbitrary HTML. Rich paste implies **HTML (or RTF) → Delta** with **bounded** support (bold, links, simple lists) and **sanitisation**; full “like desktop” coverage is a **large** follow‑on.
- **Reasonable phasing:** rock‑solid **plain text** paste first; then **HTML when the OS exposes it**, mapped only to attributes you already round‑trip to CherryTree; treat “every site’s HTML” as non‑goals at first.

---

## 3. Syntax highlighting (50+ languages on desktop)

**Assessment:**

- Desktop CherryTree leans on a **real code‑editor stack** (many languages = many lexers + one code widget).
- Mobile body is **Quill** — not a code editor. Highlighting **50+ languages** means **separate code‑block UX** (dedicated widget + grammar pack) plus **import/export** of `codebox` / `syntax`, not “turn Quill into GtkSourceView.”
- **Feasible in pieces**; **full desktop matrix** is a **large** spike. A **narrow** later step might be: store **language id** + **monospace** body for code nodes **without** live highlighting, or **few** languages as a proof of concept.

**Conclusion:** sensible to **defer** full syntax‑highlighting parity and document that mobile is **companion**, not IDE‑replacement.

---

## 4. How `.ctb` / `.ctd` actually store the tree and bodies

**Goal of the discussion:** correct an overly “spreadsheet” mental model and clarify what “leave data untouched” really requires.

### `.ctb` (SQLite)

- Real **tables**: e.g. `node`, `children`, `codebox`, `grid`, `image`, `bookmark` (see `lib/cherrytree/ctb_schema.dart`).
- **One row per tree node** in `node` (name, flags, timestamps, `syntax`, etc.).
- **Hierarchy** in `children` (father, sequence).
- **Code boxes, tables, images** are **separate rows** in their own tables (e.g. `codebox` has `txt`, `syntax`, layout fields) — not “extra columns on `node`” for the code text.
- **Rich text:** the **`node.txt`** column is usually **one text field** holding **XML**: a wrapper (often `<node>`) with multiple **`<rich_text>`** children. Formatting is **XML attributes** on each `<rich_text>` (weight, style, underline, foreground, background, link, …) — **not** one database row per bold/italic.

### `.ctd` (XML)

- Same **ideas**: nested `<node>` elements; child slots like `<rich_text>`, `<codebox>`, `<table>`, …
- Inline formatting again: **attributes on `<rich_text>`**, with text inside the element.

### “Use what we handle; leave the rest untouched”

- **Spirit:** right for **trust** (no silent stripping).
- **Reality:** **not automatic**.
  - If you **deserialize** to Quill and **write back** only what Quill knows, **unknown `<rich_text>` attributes** can be **dropped** unless you add **pass‑through** (extra storage, merge rules, tests).
  - **Codebox / table / image** slots you **never load** into the editor can be **lost on full file rewrite** unless the pipeline **preserves** those rows/elements for unedited nodes — or you adopt a **copy‑through** strategy for the whole archive (harder with SQLite rewrite).
- So: **round‑trip safety** is an **explicit engineering goal**, not “don’t delete SQL rows we didn’t touch” without a data model that still **carries** those rows through export.

---

## 5. Engineering work already done (context)

Briefly, for alignment with the codebase and docs:

- **Android 15+ / edge‑to‑edge:** `MainActivity` applies **system bar + cutout** insets on the content root and clears those inset types for descendants so Flutter does not **double‑apply** padding — fixes UI under the **nav bar** (e.g. landscape) when `MediaQuery` insets are wrong. Documented in `CHANGELOG.md`, `PATH_OF_ATTACK.md`, `AI_DEVELOPMENT.md`, `USER_MANUAL.md`.
- **App shell:** thin `lib/main.dart`; `lib/app/cherrytree_flutter_app.dart` + `lib/app/app_settings.dart` for prefs and `MaterialApp`.
- **Tabs:** **vertical dividers** between document tabs in the tab strip (`notes_home_page.dart`).
- **Docs / process:** reminder to add **why**‑comments when finishing a change (`DEVELOPMENT_GUIDELINES.md`, `AGENTS.md`).

---

## 6. Suggested planning prompts (for your own doc or PATH_OF_ATTACK)

When you “mull this over,” you might answer explicitly:

1. **Round‑trip MVP:** Which **node types** and **rich_text attributes** must survive **one** edit‑and‑export cycle for v1 trust? (List them; everything else is “known limitation” in the manual.)
2. **Pass‑through:** For **unedited** nodes, do we aim to **byte‑preserve** subtrees (CTD) or **row‑preserve** (CTB), or accept **lossy** export until a later milestone?
3. **Mobile‑only features:** What is **in scope** for “on the go” (tabs, split layout, l10n) vs **explicitly out of scope** for the first store‑ready release (e.g. 50‑language live highlighting).
4. **User honesty:** What do we **say in the user manual** about paste, code boxes, tables, and unknown formatting so desktop users are **not surprised**?

---

## 7. Document history

| Approx. date | Note |
|--------------|------|
| 2026-04 | Initial summary from maintainer design chats (Android insets, app shell, tabs, comments policy, paste/syntax/round‑trip/storage model). |

_Edit this table when you revise the plan or ship milestones._
