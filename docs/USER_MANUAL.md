# Cherrytree Flutter — User manual

This document is maintained **while the app is built**, not only at release time. Each meaningful feature or behavior change should add or adjust a short section here so nothing important is lost.

**Audience:** people using the app day to day.  
**Not covered here:** developer setup, architecture, or internal file formats (see project docs and code comments).

---

## How to keep this manual useful (for contributors)

- When you ship or change a **user-visible** behavior, add or update the matching section in the same PR when practical.
- Prefer **short, task-oriented** text: what the user can do, where to tap, and what to expect.
- If something is **temporary** or **incomplete**, say so in one line (users appreciate honesty).

---

## Notes and the tree

- Notes are organized as a **tree**: each item has a title and body, and can have **child** notes under it.
- Use **Add root** in the app bar to create a top-level note.
- Use the tree panel (sidebar on wide layouts, drawer on narrow) to select a note, add children, or delete a subtree.

---

## Multiple documents (tabs)

- The app can keep **several documents open at once**, each in its own **tab**.
- **Switch tabs** by tapping a tab in the strip below the breadcrumb.
- **New tab** (+): opens a new empty document in a new tab.
- **Close tab** (×): appears when there is more than one tab; closes that document’s tab. At least one tab always stays open.
- **Rename tab**: **long-press** the tab title. Enter a custom name, or leave the field empty and save to show the **first root note’s title** again instead.
- Work is saved automatically (with a short delay after typing); switching tabs or leaving the app triggers saves for the relevant data.

---

## CherryTree import and export

- **Import** (folder icon): choose an unencrypted **`.ctd`** (XML) or **`.ctb`** (SQLite) file. Encrypted **`.ctz` / `.ctx`** is not supported yet.
- After the file is read, choose **Replace current tab** or **New tab** so you do not overwrite another document by accident.
- **Export** (save-as icon): write the current tab’s document to a new `.ctd` or `.ctb` file (or share it), depending on the options shown.

Import limitations (same general class as desktop CherryTree “plain” viewing): rich text may appear simplified; some content types may be omitted or shown as plain text.

---

## Settings

Open **Settings** from the **gear** icon in the app bar (when the app provides it). Choices are grouped into sections; your preferences are saved on the device.

### Appearance

- **Dark theme** — Switch between light and dark appearance. The dark palette uses navy-style surfaces similar in spirit to desktop CherryTree.

### Layout

- **Split layout** — When this is **on**, the tree stays **beside or above** the editor with a **draggable divider** (drag the narrow handle to change how much space the tree uses). **Narrow screens (typical phone portrait):** tree on top, editor below. **Wide screens (e.g. phone landscape above ~720 dp width):** tree on the **left**, editor on the right. The **menu** icon for the drawer is hidden whenever split layout is on, because the tree is always visible.
- When split layout is **off** on a **narrow** screen, the tree opens from the **menu** icon in a **drawer**, and the editor uses the full width below the app bar.
- When split layout is **off** on a **wide** screen, the tree uses a **fixed-width sidebar** (unchanged from classic wide layout).
- **App bar:** the **sidebar** icon next to Settings toggles split layout on or off (same as this setting); each orientation remembers its own divider position.
- **Android:** With **on-screen navigation** (buttons or gestures), the app keeps controls and the editor **clear of the system bar** — including in **landscape**, where the bar often sits along a short edge of the screen.

Tree rows use **compact** spacing so more of each title is visible when the tree column is narrow.

### Language

- Tap **Language** to choose **System default** (follow the device language when supported) or force **English**, **Nederlands**, or **Deutsch** for the app’s translated strings.

---

## Notes editor

- Each note has a **title** field and a **body** area.
- The body uses a **rich text editor** with a small **toolbar** (e.g. checklist toggles where supported). Content is shown on a **subtle shaded background** with a border so the editing area is easy to see.

---

## Troubleshooting

- If saving fails, check **storage space** and **permissions** for the app’s documents area.
- If a tab looks empty after a bad shutdown, try switching away and back, or restart the app; data is stored per tab on disk.

---

## Document history (optional)

| Approx. date | Change |
|--------------|--------|
| 2026-04      | Multi-document **tabs**, per-tab CherryTree paths, **long-press tab rename**, import target (replace vs new tab). |
| 2026-04      | **Settings:** dark theme, **split layout** (tree beside or above editor + draggable ratio per orientation), **language** override. **Editor:** rich body + toolbar. |
| 2026-04      | **Android layout:** system navigation area respected in **landscape** and other edge-to-edge cases so app bar and editor are not hidden behind on-screen buttons. |

_Add new rows when you add notable features._
