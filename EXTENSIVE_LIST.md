# CherryTree — broad feature checklist (reference)

Unofficial, high-level inventory of **desktop CherryTree** capabilities (useful for product discussions). **Parity tracking** (T/L/S tags, checkboxes, upstream pointers) lives in [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) under **CherryTree parity inventory**.

Official project site: [giuspen.net/cherrytree](https://www.giuspen.net/cherrytree).

---

## 1. Core structure and hierarchy

- **Tree navigation:** Hierarchical nodes with deep nesting.
- **Node management:** Create, rename, delete, duplicate, move (including drag-and-drop on desktop).
- **Node types:**
  - **Rich text:** Formatted notes.
  - **Plain text:** No rich formatting; good for raw or portable text.
  - **Automatic syntax highlighting:** Code-oriented nodes (many languages).
- **Node metadata:** Per-node stock icon, title color, bold title, read-only; tags for search; exclude-from-search flags (see upstream `CtNodeData`).
- **Bookmarks:** Pin nodes for quick access from the Bookmarks menu.
- **Recent nodes:** “Last visited” trail (desktop tree/header preferences).

### 2. Rich text editing (editor)

- **Basic formatting:** Bold, italic, underline, strikethrough.
- **Typography:** Subscript, superscript, small, monospace.
- **Headers:** Multiple levels (H1–H6-style in desktop).
- **Colors:** Foreground and background (highlight).
- **Alignment:** Left, center, right, justified.
- **Lists:** Bulleted, numbered, **to-do** lines with checkbox state.
- **Special elements:** Horizontal rule, date/time stamp, special-character palette.

### 3. Advanced content

- **Images:** Insert, resize, rotate; save/export as PNG where supported.
- **Tables:** Insert/delete rows and columns; cell styling; CSV import/export; sorting (desktop).
- **Codeboxes:** Embedded code regions with syntax highlighting inside rich text.
- **Code execution:** Run snippets via external terminal/interpreter (desktop).
- **LaTeX:** Math rendering where enabled.
- **Embedded files:** Attach files into the document; extract to disk later.
- **TOC:** Generate a table of contents from headings inside a node.

### 4. Links and navigation

- **External:** Web URLs, file paths, folder paths.
- **Internal:** Links to another node; links to an **anchor** inside a node.
- **Auto-linking:** Options to treat URLs (and related patterns) as links.

### 5. Search and replace

- **Scopes:** Current node; selected node + subnodes; whole tree.
- **Modes:** Case sensitivity, regex, whole-word (as in desktop Find dialog).
- **Replace:** In body text and in node names/tags (batch where supported).
- **Quick navigation:** Find by node name / tags for fast tree jumps.

### 6. Storage and security

- **Formats:** SQLite (`.ctb` / `.ctx`) and XML (`.ctd` / `.ctz`); multifile XML layouts on desktop.
- **Encryption:** Password-protected stores (e.g. 7-zip–based pipeline in CherryTree).
- **Auto-save:** Interval and on-quit behaviour (configurable).
- **Backups:** Rotating `.bak` copies (configurable).

### 7. Import and export

- **Export:** PDF, HTML (often with navigation), plain text; table/CSV where applicable.
- **Import:** Many foreign note formats (HTML, plain-text folders, and various apps — see desktop Import menu / manual §5.4).

### 8. UI and customization

- **Themes:** Light/dark and custom palette options (tree + editor).
- **Fonts:** Separate defaults for tree and editor (and code) on desktop.
- **Layouts:** Persistent Split-Screen options on tall/portrait bounds instead of drawer.
- **Localization:** System-responsive automatic language detection, alongside manual `Settings` dialog overrides.
- **Toolbar:** Customizable actions/layout.
- **Shortcuts:** Large shortcut set (relevant for tablets with hardware keyboards).
- **Focus mode:** Hide tree or chrome for minimal UI (desktop).

### Developer note (mobile)

SQLite-based **`.ctb`** maps well to large trees and partial saves; this app currently uses **local JSON** for Spike A and **read-only** CherryTree import (see [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md)). **Inter-app copy/paste** with rich text is a strong usability target once the editor matures.

---

## Sync with the repo roadmap

When you promote an item from “idea” to “planned work,” add or update a row in [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) (**CherryTree parity inventory** and **Supplemental checklist**) with a **T**/**L**/**S** tag and optional `[ ]` checkbox for **T** items.
