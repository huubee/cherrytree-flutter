# cherrytree_flutter

An unofficial, community-driven Flutter app for Android and iOS that aims to bring [CherryTree](https://www.giuspen.net/cherrytree/)-style hierarchical notes to mobile. This repository is not the official CherryTree project; it is a separate codebase that uses the desktop app and its published formats as a reference for behavior and compatibility.

**Upstream CherryTree (desktop):** [github.com/giuspen/cherrytree](https://github.com/giuspen/cherrytree)

---

## Why this exists

CherryTree is a mature hierarchical note-taking application for desktop (Linux, Windows, macOS). A **mobile client** has been requested by users for a long time. This project explores that idea in **Flutter**, starting small and growing capability over time instead of attempting a full clone on day one.

**Desktop CherryTree remains the right tool on desktop.** This repo targets **phones and tablets only**; we do not ship web, Windows, Linux, or macOS targets here.

---

## Disclaimer

- This project is **not affiliated with** or endorsed by the CherryTree authors unless they choose to say otherwise.
- It is **experimental / work in progress**. Features and file compatibility will evolve.
- Use the [official CherryTree releases](https://github.com/giuspen/cherrytree/releases) for the canonical desktop application.

---

## Roadmap (high level)

Work is phased so the effort stays manageable:

| Phase | Focus |
| ----- | ----- |
| **Spike A** | Core mobile UX: tree of nodes, simple editing, **local JSON persistence**. |
| **Spike B** | **Read-only import** of unencrypted `.ctd` / `.ctb` (plain text; rich text shown as plain; embedded objects omitted with warnings). |
| **Spike C** | **Round-trip** saves without corrupting documents opened in desktop CherryTree (starting with narrow cases: e.g. unencrypted, single-file). |
| **Later** | Richer parity (imports, encryption, multifile storage, etc.) only after the foundations above are solid. |

Exact milestones may shift; check issues and pull requests for current work.

**Checklist (Spike A → later):** [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) · **Changelog:** [`CHANGELOG.md`](CHANGELOG.md) · **AI assistants:** [`AI_DEVELOPMENT.md`](AI_DEVELOPMENT.md).

### Where we stand (for contributors)

| Doc | Use it for |
| --- | ---------- |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | **How to contribute** — PR expectations, CI, reviews, and links to rules. |
| [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) | **Canonical checklist** — what is done (`[x]`), not started (`[ ]`), or in progress (`[-]`). |
| [`CHANGELOG.md`](CHANGELOG.md) | **What shipped** in each version; **Unreleased** summarizes recent work before a tag. |
| This README (roadmap table above) | **High-level phases** (Spike A/B/C) without duplicating every checkbox. |

**Known issues** are called out in **Unreleased** in the changelog and in **Follow-up** under the relevant spike in [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) (e.g. import file picker on device).

---

## Supported platforms

| Platform | Supported |
| -------- | --------- |
| Android | Yes |
| iOS | Yes |
| Web, Windows, Linux, macOS (Flutter) | **No** — use [upstream CherryTree](https://github.com/giuspen/cherrytree) on desktop. |

---

## Application identifiers

These are the IDs used for store listings and signing:

| Target | Identifier |
| ------ | ---------- |
| Android `applicationId` | `nl.bytesnbits.cherrytree_flutter` |
| iOS bundle ID | `nl.bytesnbits.cherrytreeFlutter` |

The iOS value uses the usual **camelCase** last segment; Android uses **snake_case**, matching the Dart package name `cherrytree_flutter`.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel recommended)
- For **Android:** Android Studio or Android SDK, device or emulator
- For **iOS:** **macOS** with **Xcode** (required to build and archive for the App Store)

---

## Getting started (development)

```bash
git clone https://github.com/huubee/cherrytree-flutter.git
cd cherrytree-flutter
flutter pub get
flutter run
```

Then choose a device or emulator when prompted.

Useful commands:

```bash
flutter analyze          # Static analysis
flutter test             # Unit / widget tests
```

---

## Building for Android

Example:

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

The release APK or App Bundle is produced under `build/app/outputs/`. Configure signing in Android for Play Store uploads (see [Flutter Android deployment](https://docs.flutter.dev/deployment/android)).

---

## Building and archiving for iOS (App Store)

iOS builds must be done on a **Mac**.

1. Install **Xcode** from the Mac App Store and accept the license.
2. Open the iOS workspace in Xcode if you need to adjust signing, capabilities, or version:

   ```bash
   open ios/Runner.xcworkspace
   ```

3. In Xcode, set your **Team** and **Bundle Identifier** (should match `nl.bytesnbits.cherrytreeFlutter` unless you use a fork with a different ID).
4. From the project root, you can also build from the command line:

   ```bash
   flutter build ipa
   ```

   Or use **Product → Archive** in Xcode to create an archive, then **Distribute App** to upload to App Store Connect.

See [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios) for certificates, provisioning profiles, and App Store Connect.

---

## How this relates to the CherryTree source code

The [official CherryTree repository](https://github.com/giuspen/cherrytree) is **C++/GTK** desktop software. It cannot be run on mobile as-is. This Flutter app **reimplements** the product experience and, over time, **document formats** by reading that codebase and its tests as a **guide**, not by copying the UI layer.

If you want a local checkout of upstream for comparison or format work, clone it **next to** this project (or add it as a **git submodule** pinned to a release tag). Do not assume the mobile repo contains a full copy of upstream.

---

## Contributing

Contributions are welcome: issues, documentation, and pull requests. Before large changes, consider opening an issue to align on scope (especially around **file format compatibility** and licensing).

---

## License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html) — see the [`LICENSE`](LICENSE) file in the repository root. This matches the license of [upstream CherryTree](https://github.com/giuspen/cherrytree), which helps when implementing compatible document handling. If you have questions about combining or redistributing code, seek appropriate legal advice.

**Copyright:** © 2026 Hubèrt Huijbregts / bytesnbits.nl and cherrytree_flutter contributors. The domain bytesnbits.nl hosts a small personal page about building and testing apps, not a separate company site. A short summary also appears in [`NOTICE`](NOTICE).

---

## Links

- [CherryTree (home)](https://www.giuspen.net/cherrytree/)
- [CherryTree (GitHub)](https://github.com/giuspen/cherrytree)
- [Flutter documentation](https://docs.flutter.dev/)
- [Development guidelines](DEVELOPMENT_GUIDELINES.md) — architecture, state management, persistence, maintainability (file size, DRY, comments)
- [AGENTS.md](AGENTS.md) — notes for automation / AI assistants
