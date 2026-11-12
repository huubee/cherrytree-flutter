# Flutter/Dart Enterprise Development Guidelines & AI Agent Directives

> Synced from huubee/dev-guidelines v2.7.0 (commit d4a6991). Do not edit here; change the master and re-sync.

> **Version:** 2.7.0  
> **Date:** 2026-11-12  
> **Target Ecosystem:** Flutter 3.47.x stable (3.47.7, bundled Dart 3.13.5) | Dart 3.13.x  
> **Status:** Mandatory Architecture & Coding Standard  
> **Usage:** To be provided to human developers and autonomous/assisted AI coding agents (alongside the Product Requirements Document - PRD) at the inception and throughout the lifecycle of any Flutter/Dart project.

Version history is in [CHANGELOG.md](https://github.com/huubee/dev-guidelines/blob/main/CHANGELOG.md).

## Table of Contents
1. [Core Principles & Architectural Philosophy](#1-core-principles--architectural-philosophy)
2. [Architectural Patterns & Layered Structure](#2-architectural-patterns--layered-structure)
3. [Coding Standards & Modern Dart Idioms](#3-coding-standards--modern-dart-idioms)
4. [Design System, Sizing & Foldable Layout Rules](#4-design-system-sizing--foldable-layout-rules)
5. [State Management Frameworks & Decision Matrix](#5-state-management-frameworks--decision-matrix)
6. [Routing, Navigation & Deep Linking](#6-routing-navigation--deep-linking)
7. [Networking, Data Persistence & Caching](#7-networking-data-persistence--caching)
8. [Security, Input Sanitization & Threat Telemetry](#8-security-input-sanitization--threat-telemetry)
9. [Error Handling, Logging & Observability](#9-error-handling-logging--observability)
10. [Testing Strategy & Quality Assurance](#10-testing-strategy--quality-assurance)
11. [Documentation & Code Intent Comments](#11-documentation--code-intent-comments)
12. [AI Agent Directives & Dependency Vetting Protocol](#12-ai-agent-directives--dependency-vetting-protocol)
13. [Modern Android Toolchain & Gradle/KGP Compatibility Policy](#13-modern-android-toolchain--gradlekgp-compatibility-policy)
14. [MCP Server Ecosystem & Tool Integrations](#14-mcp-server-ecosystem--tool-integrations)
15. [Project Bootstrap & Dependency Blueprint](#15-project-bootstrap--dependency-blueprint)
16. [Project-specific exceptions](#16-project-specific-exceptions)

---

## 1. Core Principles & Architectural Philosophy

### 1.1 First Principles
- **Uncompromising Maintainability:** Code is written once but read, modified, and debugged hundreds of times. Clarity always trumps cleverness.
- **Single Responsibility Principle (SRP):** Every class, function, widget, and file must have one, and only one, reason to change.
- **Atomic File Boundaries:** Smaller files are better, and **200–250 lines of code is the target**, but there can be exceptions. Good maintainability is the key goal. A file over the target is fine when splitting it would hurt maintainability, and such an exception should be noted briefly in a code comment or in the project's `GUIDELINES_EXCEPTIONS.md`. This is a guideline with justified exceptions, not a hard cap. When splitting improves maintainability, extract sub-widgets, helper extensions, or domain models.
- **Immutability by Default:** All domain models, state classes, and configuration objects must be immutable (`@immutable`, `freezed`, or records).
- **Strict Separation of Concerns:** UI layers must never execute business logic, manage raw database connections, or format network payloads directly.
- **Deterministic & Unidirectional Data Flow (UDF):** Data flows downward from state providers/stores; user actions (events/intents) flow upward to state mutators/blocs.
- **Same structure, own look:** Design values share one structure across apps. The look belongs to each app. Widgets read colors, strings, dimensions, durations, and breakpoints from central theme, token, or l10n files. Palettes, fonts, sizes, spacing, breakpoints, and brand assets stay app-specific. Mix stylers, when an app uses them, follow the same rule. See sections 4, 4.6, and 4.7.

---

## 2. Architectural Patterns & Layered Structure

We enforce **Feature-First Clean Architecture** with distinct vertical domain slices.

```
lib/
├── app/
│   ├── app.dart                    # Root MaterialApp.router (package:material_ui)
│   ├── theme/                      # AppTheme, Typography, Colors
│   ├── routes/                     # AppRouter configuration (GoRouter)
│   └── constants/                  # Global constants, assets, dimensions
├── core/
│   ├── errors/                     # Failure types, AppExceptions
│   ├── network/                    # Dio/Http clients, interceptors
│   ├── security/                   # Threat detection, input sanitizers, crypto
│   ├── storage/                    # SecureStorage, SharedPreferences/Isar
│   ├── utils/                      # Pure helper functions, extensions
│   └── widgets/                    # Atomic, reusable design system components
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/        # Remote & Local datasources
│       │   ├── models/             # DTOs, JSON serialization (Freezed/json_serializable)
│       │   └── repositories/       # Concrete repository implementations
│       ├── domain/
│       │   ├── entities/           # Pure domain models
│       │   ├── repositories/       # Abstract repository interfaces
│       │   └── usecases/           # Optional single-purpose business interactors
│       └── presentation/
│           ├── controllers/        # Riverpod Notifiers / Blocs / CubitSignals
│           ├── state/              # Immutable UI state models
│           ├── screens/            # Full-page views
│           └── widgets/            # Feature-specific sub-widgets (extracted)
└── main.dart                       # Entry point (initialization only)
```

`lib/app/theme/` and `lib/app/constants/` in the tree above are one valid home for design tokens. The app may use another central folder, for example `lib/core/tokens/` or `lib/theme/`. Section 4 is the rule. Record the chosen folder in the app's README or DESIGN doc.

### 2.1 Layer Boundaries & Dependency Inversion
1. **Domain Layer:** Pure Dart. Zero Flutter UI dependencies. Contains pure entities and repository interfaces (`abstract class UserRepository`).
2. **Data Layer:** Implements domain repository interfaces. Handles API calling, serialization/deserialization, caching, and raw data mapping.
3. **Presentation Layer:** Consumes state controllers/blocs. Renders UI reactively. Does not perform I/O or raw data transformations.

---

## 3. Coding Standards & Modern Dart Idioms

### 3.1 Strict Typing & Analyzer Configuration
Enable maximum analyzer strictness in `analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_relative_lib_imports
    - avoid_shadowing_type_parameters
    - avoid_types_as_parameter_names
    - avoid_unused_constructor_parameters
    - cancel_subscriptions
    - close_sinks
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_iterable_whereType
    - require_trailing_commas
    - unawaited_futures
    - unnecessary_late
    - use_build_context_synchronously
```

### 3.2 Modern Dart 3+ Practices
- **Pattern Matching & Destructuring:** Use switch expressions and pattern matching over nested `if-else` chains.
  ```dart
  final statusLabel = switch (orderState) {
    OrderPending(:final estimatedTime) => 'Pending (ETA: $estimatedTime)',
    OrderShipped(:final trackingCode) => 'Shipped (#$trackingCode)',
    OrderDelivered() => 'Delivered',
    OrderCancelled(:final reason) => 'Cancelled: $reason',
  };
  ```
- **Records & Sealed Classes:** Use sealed class hierarchies for expressive algebraic data types (states, events, failures) and lightweight records for grouped return values.
- **Never use `dynamic`:** Always use `Object?` if a type is truly unknown, followed by type narrowing or generic parameters.
- **Trailing Commas:** Always include trailing commas on all multi-line parameter lists, argument lists, and widget trees to guarantee clean formatting.
- **Primary constructors (Dart 3.13):** Declare fields and the main constructor in the declaration header (`class Point(final int x, final int y);`). Inside the body, a generative or factory constructor may omit the class name and use `new` or `factory` directly. Set the SDK lower bound to `^3.13.0` before using either form.
- **Parameter modifiers:** `final` and `var` are allowed only on declaring parameters (primary constructors). Using them on ordinary function, method, or in-body constructor parameters is a compile error. Use the `parameter_assignments` lint when the goal is "do not reassign this parameter."
- **Dot shorthands (Dart 3.10) and null-aware elements (Dart 3.8):** Use dot shorthands for enum and static values when the type is already known, and null-aware elements (`?value`) in collections. Both are stable and are not optional style experiments.
- **freezed 4:** The generator is 4.0.2 and supports primary constructors. Do not put `final` on parameters of an in-body freezed constructor; Dart 3.13 rejects that, and freezed 4 dropped it (this also means `@unfreezed` can no longer mark fields immutable that way). Declaring parameters on a primary constructor still use `final`. Depend on `freezed_annotation` 3.1.0, which is the annotation package freezed 4.0.2 pins, rather than a 4.x annotation package.

---

## 4. Design System, Sizing & Foldable Layout Rules

**ZERO MAGIC NUMBERS OR HARD-CODED STRINGS IN UI CODE.**

**Same structure, own look.** Every app follows the same structure for design values. Each app owns the values.

- **Structure.** No hard-coded colors, user-facing strings, dimensions, spacing, radii, durations, breakpoints, or other magic values in widgets. Those values live in central files the app owns, so a change is made in one place. Homes include design tokens, `ThemeData` / `ColorScheme` plus `ThemeExtension`, a constants or dimensions file, and gen-l10n ARB files (`flutter: generate: true`) for user-facing strings. Widgets read values from `Theme`, extensions, tokens, or l10n only.
- **Look.** Color palettes, fonts, sizes, the spacing scale, breakpoints, and brand assets belong to that app. Do not copy them from another app. This document says how and where to define them. It does not set the values.
- **Where.** The app chooses one central folder. `lib/core/tokens/`, `lib/theme/`, and the section 2 paths `lib/app/theme/` and `lib/app/constants/` are all valid. Record the chosen folder in the app's README or DESIGN doc.

System text scale is section 4.6. Mix, Remix, and a local Widgetbook are section 4.7. Neither section adds a shared visual theme.

Prefer the standalone `material_ui` package over `package:flutter/material.dart` where the app's dependencies support it. `material_ui` exposes the same `ThemeData`, `ColorScheme`, and `ThemeExtension` API and is released independently of the Flutter SDK. Prefer `cupertino_ui` over `package:flutter/cupertino.dart` on the same terms.

```dart
import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
```

Flutter 3.47 publishes `material_ui` and `cupertino_ui` so design libraries can ship without an SDK release. `package:flutter/material.dart` and `package:flutter/cupertino.dart` still run, and formal deprecation is scheduled for a later stable. Contributions to the in-framework copies were frozen in Flutter 3.44. Migrate with `dart fix --apply --code=migrate_design_widgets`. When a dependency still reads `Theme.of(context)` from the in-framework library, wrap the tree in `MaterialUiCompatibilityBridge`. The bridge does not fix public APIs that take or return in-framework types such as `ColorScheme`, `TextTheme`, or `ThemeExtension`; those packages have to move to `material_ui` first. Material and Cupertino localization delegates now live in those packages. `GlobalMaterialLocalizations.delegates` includes the Cupertino and Widgets delegates.

### 4.1 Central design tokens
Define each color, size, space, radius, duration, breakpoint, and asset path once, in the central files from the rule above. Widget code uses those names.

Example layout. The folder name follows the app's choice in the rule above:

```
lib/theme/
├── app_colors.dart        # Semantic color tokens (light and dark)
├── app_dimensions.dart    # Spacing, padding, radius, elevation
├── app_typography.dart    # TextStyle hierarchies
├── app_durations.dart     # Animation and transition durations
└── app_assets.dart        # SVG, image, and Lottie asset paths
```

Example token definition. The names show the structure. The numbers are this example's scale. Another app picks its own:

```dart
// Example scale for one app. Do not copy these numbers into another app.
abstract final class AppDimensions {
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  static const double radiusSmall = 6.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusCircular = 999.0;
}
```

Color literals live in the color tokens or in `ColorScheme` and `ThemeExtension` values, with a light scheme and a dark scheme when the app has both. Widgets read `Theme.of(context).colorScheme`, a `ThemeExtension`, or the app's color tokens. Font family, size, and weight live in the typography tokens. Section 4.3 keeps those out of the color theme. Those sizes are the unscaled sizes. Section 4.6 is the OS text scaler on top of them.

### 4.2 Responsive, Adaptive & Foldable Layout Rules
- **Breakpoints:** Define the app's widths in the central tokens. Widgets compare against those constants. Example only. One app's scale is phone / folded below `600dp`, tablet / unfolded foldable from `600dp` to `1024dp`, and desktop above `1024dp`. Another app uses a different scale.
- **Dynamic Hinge & Display Feature Awareness:**
  - Avoid rendering interactive elements or primary content directly across physical seams or hinges.
  - Query `MediaQuery.displayFeaturesOf(context)` to detect physical display splits (`DisplayFeatureType.hinge` or `DisplayFeatureType.folding`).
  - Use adaptive multi-column flex layouts when unfolded or in tabletop/flex postures. `TwoPane` from `dual_screen` is not an option on current Dart: `dual_screen` 1.0.4 constrains the SDK to `>=2.12.0 <3.0.0` and does not resolve. The foldable behavior in this section stays; implement it with framework layout widgets and `MediaQuery.displayFeaturesOf`.
- **Aspect Ratio & Posture Resilience:**
  - Never assume fixed 16:9 or 19:9 ratios. Support extreme vertical aspect ratios (clamshell outer/inner displays up to 22:9) and square ratios (unfolded book foldables).
  - Wrap scrollable views in `SingleChildScrollView` or `CustomScrollView` to prevent layout overflow errors during live folding state changes.
- **State Preservation on Posture Shift:**
  - Ensure controller state, form inputs, and scroll positions persist across live fold/unfold display reconfigurations.
- **System text scale:** Large OS text is a layout input, in the same way a narrow width is. Section 4.6 is the rule. Locking `textScaler` to 1.0 does not satisfy it.

### 4.3 Color themes
A color theme contains colors only. Switching variants does not change layout, which widgets are built, font family, font size, font weight, spacing, or radii. Text and icon colors are part of the theme and may differ by variant. Font size in that rule is the token size. A light or dark switch does not change it. The OS text scaler in section 4.6 still multiplies it.

If the app offers a dark variant, it also offers a light variant. Both are color schemes in the central theme files. An app may offer light only.

### 4.4 Catching hard-coded values
- **Analyzer.** The Dart linter and `flutter_lints` do not ship a rule that forbids literal colors, spacing, radii, durations, or breakpoints in widgets. `use_full_hex_values_for_flutter_colors` only requires an eight-digit hex when a `Color` is constructed from an integer. Where a maintained analyzer plugin flags hard-coded colors or strings, enable it after the package check in section 12.1.
- **Review.** UI review includes this checklist item: every color, user-facing string, dimension, duration, and breakpoint in a widget comes from theme, a token, or l10n. Literals stay in the central token and theme files.
- **Text scale.** The same review checks section 4.6. The change does not force a text scaler of 1.0, and a box that holds text does not take a fixed height.
- **CI (optional).** A grep, or a small script, over `lib/` may fail the job on `Color(0x`, `Colors.`, `EdgeInsets`, `BorderRadius.circular(`, and `Duration(` outside the central token and theme files. Exclude those central files, tests, and generated code. The check is optional. `TextScaler.noScaling` and `withNoTextScaling` outside a documented exception are worth the same kind of grep.

### 4.5 Dutch copy: informal address

Dutch text shown to users uses the informal form. This covers UI strings, emails, notifications, and documentation shown to users. Write `je`, `jij`, `jou`, and `jouw`, and the verb forms that go with them. Do not write `u` or `uw`. Keep the tone friendly, clear, and concise.

The rule applies to every app. Each app still has its own look and feel. Color, type, spacing, and brand stay with that app, as in the rule at the top of this section.

| Before | After |
| :--- | :--- |
| U kunt uw wachtwoord wijzigen | Je kunt je wachtwoord wijzigen |
| Controleer uw e-mail | Controleer je e-mail |
| Wilt u doorgaan? | Wil je doorgaan? |

- **Check (recommended).** Add an automated check or test that fails when Dutch (`nl`) strings contain a formal pronoun. Match `u` and `uw` on a word boundary, case-insensitive. Run it over the Dutch l10n files (gen-l10n ARB, for example `app_nl.arb`) and over other Dutch copy the app shows to users, such as email and notification templates.

### 4.6 System text scale

People using svgr-reserveringen and zwitsers_veldschieten set a larger system font, and the layout breaks. Android calls the setting Font size (Settings > Font size). iOS calls it Larger Text, under Settings > Accessibility > Display & Text Size, and that setting is Dynamic Type. The same settings apply to every current store app and to every future store app.

Flutter applies that choice through `MediaQuery.textScaler`. `Text` and other widgets that read the ambient scaler scale their font size with it. On a linear scaler that is a multiply. Apps must honour the scaler. Typography tokens stay the sizes at scale 1.0. They are not a reason to ignore the OS setting.

Sources, checked 2026-11-12: [Large fonts](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling), [TextScaler migration](https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor), [Android 14 nonlinear font scaling](https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration), [`MediaQuery.textScalerOf`](https://api.flutter.dev/flutter/widgets/MediaQuery/textScalerOf.html).

- Do not set `TextScaler.noScaling`, `MediaQuery.withNoTextScaling`, or a `textScaler` of `TextScaler.linear(1.0)` so that a layout stays put. [`TextScaler.noScaling`](https://api.flutter.dev/flutter/painting/TextScaler/noScaling-constant.html) is `TextScaler.linear(1.0)`. `MediaQuery.withClampedTextScaling` with a max of 1.0 is the same refusal. Do not install the Android 14 "temporarily opting out" snippet from the nonlinear-scaling guide. It replaces the platform scaler with a linear one and reads the deprecated `textScaleFactor` getter.
- Do not pass the deprecated `textScaleFactor` argument on `Text`, `RichText`, `EditableText`, or `MediaQueryData`. When code must compute a size, use `MediaQuery.textScalerOf(context).scale(fontSize)`.
- On Android 14 and later the platform scaler can be nonlinear: larger fonts grow by less than smaller ones. Production code keeps the scaler the platform provided. Tests in section 10.2 still pump linear 1.5 and linear 2.0, which is the 200% stress case Android documents.
- **Exception.** A control that cannot reflow, such as a data-dense chart, or an icon font that is not itself a label, may opt out. Flutter's own icon-font example is [`MediaQuery.withNoTextScaling`](https://api.flutter.dev/flutter/widgets/MediaQuery/withNoTextScaling.html). The opt-out is written next to the widget, in a short comment or in the app's `GUIDELINES_EXCEPTIONS.md`. The same information has an accessible alternative that does scale, such as a table, a list, or a text label.

Layout, so scale 1.5 and 2.0 do not break the screen:

- No fixed height on a container that holds text. That includes a tight `SizedBox`, `Container`, or `ConstrainedBox`, and a fixed button height or `toolbarHeight`, when the child is text. Height comes from the child, or the region scrolls.
- A `Row` of labels gives each label a bounded width with `Flexible` or `Expanded`, and the label wraps inside that width. When the labels do not belong on one line, use `Wrap` instead of `Row`.
- `TextOverflow.ellipsis` is not the fix for a string the user has to read. Wrap it, or put it in a scroll view.
- Buttons and app bars grow with their labels, or the labels scroll. They do not clip.
- Touch targets are at least 48dp on the shortest side at text scale 1.0. That meets Android's 48dp minimum and iOS's 44pt minimum ([tap target size](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling)). At a larger scale the target stays usable: the hit area grows with the label, rather than clipping the label inside a fixed 48dp box.
- Before a store build, check a small phone width, about 375 logical pixels (iPhone SE class, 375×667 points), at text scale 1.0, 1.5, and 2.0, in NL and EN, in light and in dark. Dark applies when the app has a dark scheme (section 4.3). Dutch copy is often longer than English. Both locales are part of the check.

Widget tests that lock this in are in section 10.2. A local Widgetbook catalogue of the same three axes is in section 4.7. The catalogue does not replace the tests.

### 4.7 Mix, Remix, and Widgetbook

This section follows the Flutter channel video [The new way to build custom design libraries with Flutter](https://www.youtube.com/watch?v=b-u0t5QF3XY) (Craig, Mix, and Widgetbook, published 2026-11-11).

Mix and Remix are for a new app, and for a new primitive in that app's own design system. They are not a rewrite of an existing app. Apps that already depend on `package:material_ui` keep it. Section 4 still prefers `material_ui` and `cupertino_ui` over `package:flutter/material.dart` and `package:flutter/cupertino.dart` where dependencies allow. Adopting Mix does not mean leaving `material_ui`.

**Mix** is the styling layer. A style is a value, separate from the widget tree, and it resolves with context: padding, color, radius, dark mode, hover. Stylers compose. A later call overrides the fields it sets and leaves the rest. Variants such as `onDark` and `onHovered` carry the states that would otherwise be conditionals in `build`. The app's tokens and stylers live in the central folder from section 4. A styler written beside a widget is still a hard-coded design value when it contains color, font, or dimension literals. Those literals stay in the token files.

Checked on pub.dev 2026-11-12: `mix` 2.4.0 is stable. Its pubspec requires Dart `>=3.12.0 <4.0.0` and Flutter `>=3.44.0`. The Flutter 3.47 / Dart 3.13 baseline in this document satisfies that. The [getting-started](https://fluttermix.com/mix/docs/overview/getting-started/) page on that date listed the same SDK floor and showed a sample pin of `mix: ^2.3.1`, which is behind 2.4.0. The pubspec of the version you add is the constraint. Verify current versions before locking a new app. Docs: [Styling](https://fluttermix.com/mix/docs/guides/styling/), [dynamic styling](https://fluttermix.com/mix/docs/guides/dynamic-styling/), [design tokens](https://fluttermix.com/mix/docs/guides/design-token/). Package: [mix](https://pub.dev/packages/mix). The video's short link [g.dev/flutter/mix](https://g.dev/flutter/mix) resolved to that pub.dev page. Source: [btwld/mix](https://github.com/btwld/mix).

**Remix** is the component layer on Mix. The component supplies interaction, focus, and accessibility. The look is a Mix styler the app owns. Remix is built on Naked UI's unstyled primitives, which sit on Flutter raw widgets. [`RawMenuAnchor`](https://api.flutter.dev/flutter/widgets/RawMenuAnchor-class.html) is one of those widgets: it anchors a menu overlay, and the API docs say it does not manage semantics or focus. The component on top of it does. Remix does not require `MaterialApp`. Flutter has moved Material and Cupertino out of the framework into `material_ui` and `cupertino_ui` ([migration](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui), and section 4). For a custom look, prefer raw widgets plus the app's own styles. Restyling Material widgets to fight the brand is the path this section avoids. An existing Material screen can stay on `material_ui` until that screen is actually rebuilt.

Checked on pub.dev 2026-11-12: `remix` 1.0.0-rc.2 (published 2026-11-11) is a release candidate, not a stable. It requires Dart `>=3.12.0 <4.0.0` and Flutter `>=3.44.0`, and it depends on `mix` ^2.3.1 and `naked_ui` ^2.0.0-rc.1. `flutter pub add remix` resolves the latest stable, which is still `remix` 0.2.0 (2026-04-15), an older publish of the same package. Do not treat 0.2.0 as the 1.0 line from the video. Verify current versions before adding the package. A new app takes the current stable 1.x when one exists. Until then it may use the current 1.0 pre-release, and it names that version in the app README so the next upgrade is visible. The app depends on `remix`. It does not add a direct `naked_ui` dependency for ordinary screens. Docs: [Remix](https://docs.page/btwld/remix). Package: [remix](https://pub.dev/packages/remix). Source: [btwld/remix](https://github.com/btwld/remix).

**Own look.** Each app owns its Mix tokens and stylers. There is no shared Mix theme and no shared Remix skin across apps. This document does not prescribe Fluent UI. Remix's published presets (`vanilla`, `fortal`, `heroui`) are starter files one app may copy into its own tree. They are not a house style, and this document does not require them. Copied preset files become that app's tokens and follow section 4.

Adding `mix`, `remix`, or `widgetbook` for the uses in this section is already approved under section 12.1. A different major, or a different package with a similar name, still needs a package card.

**Widgetbook** is a local catalogue of the app's shared components and screens. It is a dev dependency and a separate target. It is not a route in the production app. The catalogue must switch three axes:

- Locale: NL and EN, through the app's gen-l10n delegates.
- Brightness: light and dark. Dark applies when the app has a dark scheme.
- Text scale: 1.0, 1.5, and 2.0.

Checked on pub.dev 2026-11-12. Stable `widgetbook` is 3.25.0 (published 2026-06-25). It requires Dart `>=3.10.0 <4.0.0` and Flutter `>=3.44.0`. On that line the three axes are addons: [`LocalizationAddon`](https://docs.widgetbook.io/addons/localization-addon), [`MaterialThemeAddon`](https://docs.widgetbook.io/addons/theme-addon) (or `ThemeAddon` when the app does not use `ThemeData`), and [`TextScaleAddon`](https://docs.widgetbook.io/addons/text-scale-addon). In 3.25.0, `TextScaleAddon` defaults to a slider from 0.5 to 2.0, which includes 1.0, 1.5, and 2.0. The `scales` list on that constructor is deprecated. Keep the default max at 2.0 or higher so 2.0 stays selectable.

Widgetbook 4 (Story, Args, Modes, and `build_runner`) is still beta. Checked 2026-11-12: the newest publish is `widgetbook` 4.0.0-beta.15 (2026-11-02). There is no stable 4.0.0. The v4 docs say the beta may be unstable and that API-defining changes can still land in minor releases ([What's new in Widgetbook 4?](https://docs.widgetbook.io/~v4/whats-new-in-v4)). On that beta the same three axes are `LocaleMode`, `MaterialThemeMode`, and `TextScaleMode`. Those names are the beta API, not a pin. The beta package registers its own `build_runner` builders (`story_builder` in its `build.yaml`). It does not use the separate `widgetbook_generator` package. The newest `widgetbook_generator` 4 publish checked was 4.0.0-alpha.4 (2025-11-21), which is older than 4.0.0-beta.15 and is not the generator to add beside it. Prefer the current stable 3.x line until 4.0.0 is stable. On 2026-11-12 that stable was `widgetbook` 3.25.0 with `widgetbook_generator` 3.24.0 and `widgetbook_annotation` 3.11.0. When 4.0.0 is stable, move the catalogue onto Modes and keep the three axes. Verify current versions on [pub.dev](https://pub.dev/packages/widgetbook) before locking. Do not copy the numbers in this section into a pubspec without that check.

Widgetbook Cloud is a hosted review. It is optional, and it is not required to meet this section. Docs: [Widgetbook Cloud](https://docs.widgetbook.io/cloud). The video's short link [g.dev/flutter/widgetbook-cloud](https://g.dev/flutter/widgetbook-cloud) resolved to the product site, [widgetbook.io/cloud](https://www.widgetbook.io/cloud).

**Adoption**

1. **Every app, now.** Honour section 4.6 and add the section 10.2 tests. This includes svgr-reserveringen, zwitsers_veldschieten, and every future store app.
2. **Existing store apps.** Fix the screens that overflow at large text first. Mix is optional on those apps.
3. **New store apps.** Start with per-app Mix and Remix styles and a local Widgetbook. The same start applies to any other new app.
4. **Fleet migration.** A move of existing apps onto Mix starts as a pilot on one app. It does not land in every repo in one change.

---

## 5. State Management Frameworks & Decision Matrix

The team supports three standardized state management paradigms. The specific selection for a project must be declared in the PRD or bootstrap configuration:

| Pattern / Library | Best Suited For | Key Characteristics & Mechanics |
| :--- | :--- | :--- |
| **Riverpod 3.x / Latest Version** (`flutter_riverpod`, `riverpod_annotation`) | General application state, async caching, DI replacement | Compile-safe code generation, fine-grained reactivity (`ref.watch`), built-in `AsyncValue` caching, zero `BuildContext` dependency for logic. |
| **Bloc / Cubit** (`flutter_bloc`, `bloc`) | Enterprise event-driven workflows, strict state machine transitions | Explicit event streams (`Bloc`), simplified imperative state containers (`Cubit`), extensive global middleware & observer (`BlocObserver`), predictable testability. |
| **BlocSignals** (`bloc_signals`, `bloc_signals_flutter`) | High-performance reactive state, hybrid BLoC + Signals | Bridges BLoC structure with synchronous fine-grained Signals (signals v7). Zero microtask delay on state changes, streamless concurrency transformers, and native DevTools telemetry. |

### 5.1 Riverpod Implementation Standard

Current stable line, checked 2026-10-16: `flutter_riverpod` 3.4.3, `riverpod_annotation` 4.0.7, `riverpod_generator` 4.0.9. The annotation and generator packages are major 4 while `flutter_riverpod` is major 3. Pin them as a set; do not "correct" the annotation package down to 3.x.

Riverpod 3 API rules that override older samples:

- Do not import `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider` from `package:flutter_riverpod/flutter_riverpod.dart`. Those types moved to `package:flutter_riverpod/legacy.dart`. New code uses `@riverpod` notifiers.
- `AutoDisposeNotifier` and `FamilyNotifier` are gone. Use `Notifier`. Auto-dispose is `Provider(isAutoDispose: true)` or the generator equivalent, not `Provider.autoDispose()`.
- `AsyncValue.valueOrNull` was removed. `AsyncValue.value` is null while the value is in error.
- `Ref` subclasses such as `FutureProviderRef` were removed. Use `Ref`. Check `ref.mounted` after async gaps.
- `family.overrideWith` is deprecated. Use `family.overrideWith2` until 4.0 renames it back to `overrideWith`.
- `SyncProviderTransformerMixin` is deprecated as of 3.4.0. Use the replacement provider-extension APIs.
- Anything imported from `package:riverpod/experimental/` can break without a major bump.

The generator sample below is still the standard shape (`@riverpod` class, `build()`, `AsyncValue.guard`).

```dart
// presentation/controllers/auth_controller.dart
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthState> build() {
    return const AuthState.unauthenticated();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signIn(email: email, password: password);
      return AuthState.authenticated(user);
    });
  }
}
```

### 5.2 Bloc & BlocSignals Implementation Standard

`flutter_bloc` 9.1.1 and `bloc` 9.2.1 are the current stables. The 9.0 event and `Cubit` model below is unchanged. `bloc_test` is at 10.0.0 and still targets `bloc` ^9.

`bloc_signals` 1.7.0, `bloc_signals_flutter` 1.5.0, and `bloc_signals_test` 1.0.3 were published on 2026-10-11. Confirm `CubitSignal` / `BlocSignal` against that release before copying the names below into an app; this revision did not re-audit the 1.7 API line by line.

When using **Bloc**:
- Subclass `Bloc<Event, State>` for multi-event state machines or `Cubit<State>` for simpler controller domains.
- Never trigger UI side effects (like showing snackbars or dialogs) inside state builders; use `BlocListener` or `BlocConsumer`.

When using **BlocSignals**:
- Use `CubitSignal<State>` or `BlocSignal<Event, State>` for synchronous reactivity.
- Leverage `blocSignalTest` in pure Dart unit tests without needing async stream pumps.

---

## 6. Routing, Navigation & Deep Linking

### 6.1 Declarative Navigation with `go_router`

`go_router` 18.1.0 requires Flutter >=3.44 and Dart ^3.12. `go_router_builder` 4.5.0 generates the typed routes. Version 18.0.0 moved go_router onto `material_ui` and `cupertino_ui`, so a route screen that still imports `package:flutter/material.dart` will not type-check against go_router 18 widgets. `context.goNamed` and `context.pushNamed` stay the navigation calls.

- Centralize routing configuration in `lib/app/routes/app_router.dart`.
- Use **typed routes** (`go_router_builder`) or defined constant route paths.
- Redirection logic (e.g., auth guards) must be attached via `redirect` handlers observing state providers/blocs.

```dart
// lib/app/routes/app_routes.dart
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String details = '/details/:id';
  
  static String detailsPath(String id) => '/details/$id';
}
```

### 6.2 Navigation Guidelines
- Do not use imperative `Navigator.push` in new feature code. Use `context.goNamed(...)` or `context.pushNamed(...)`.
- Deep linking parameters and query arguments must be strictly sanitized and typed before passing to controllers.

---

## 7. Networking, Data Persistence & Caching

### 7.1 Networking with Dio
- Encapsulate `Dio` inside a singleton/provider network client in `lib/core/network/`.
- Attach standard interceptors:
  1. **AuthInterceptor:** Injects Bearer tokens; handles 401 token refresh workflows.
  2. **LoggingInterceptor:** Configured to log payloads only in development mode.
  3. **RetryInterceptor:** Handles transient network drops with exponential backoff.
- Return functional `Result<T, Failure>` or `Either<Failure, T>` (via `fpdart`) to make failure states explicit.

### 7.2 Local Storage Strategy
- **Key-Value & Encrypted Secrets:** Use `flutter_secure_storage` for tokens, refresh keys, and private identifiers. Current stable is 11.2.0. Version 11.0.0 removed the cipher options deprecated in v10 and raised Android minSdk to 24, which matches the Flutter 3.47 template. An existing app still on v9 must migrate through v10 before moving to v11, or previously stored values become unreadable. A new app starts on 11.2.0.
- **Structured Relational/NoSQL Cache:** Use Drift, HiveCE, or Isar for local offline caching.
  - Drift is still major 2. Current is 2.35.2. Drift 2.35.0 removed the `dart:html` `PortToChannel` extension. On web, use the `WebPortToChannel` extension on `MessagePort` from `package:web`.
  - `hive_ce` 2.22.0 is the current HiveCE release.
  - The original `isar` package (3.1.0+1) constrains the SDK to Dart 2 and does not resolve. If a project chooses Isar, use `isar_community` (3.4.1) instead. This is a compatibility flag, not a ban on the Isar-shaped API.
- Enforce cache-first or network-first policies cleanly within repository implementations.

---

## 8. Security, Input Sanitization & Threat Telemetry

### 8.1 Environment Variables & Secret Protection
- Never commit secrets, private keys, or endpoint URLs to version control.
- Use `--dart-define-from-file=.env.<flavor>.json` for multi-flavor setup (Development, Staging, Production).
- Expose typed configurations via an immutable `AppConfig` class.

### 8.2 Security Checklist
- [ ] **Secure Storage:** Sensitive user data and auth tokens stored exclusively in Hardware-backed Keystore / Keychain.
- [ ] **Certificate Pinning:** Enforce SSL pinning for high-security endpoints via custom `HttpOverrides` or `Dio` security context.
- [ ] **Root / Jailbreak Detection:** Implement checks if handling high-risk financial or personal identity data.
- [ ] **Code Obfuscation:** Always build production releases with `--obfuscate --split-debug-info=./symbols`.
- [ ] **Input Sanitization & Threat Telemetry:** Inspect user input for injection payloads and dispatch developer security alerts.

### 8.3 Input Threat Detection & Developer Alerting Protocol
To protect systems and alert the engineering team when malicious input (SQL Injection, XSS, Path Traversal) is attempted:

```dart
// lib/core/security/security_payload_detector.dart
abstract final class SecurityPayloadDetector {
  static final List<RegExp> _maliciousPatterns = [
    // Cross-Site Scripting (XSS)
    RegExp(r'<script\b[^>]*>(.*?)</script>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'onload\s*=', caseSensitive: false),
    RegExp(r'onerror\s*=', caseSensitive: false),
    // SQL Injection Signatures
    RegExp(r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER)\b.*\b(FROM|INTO|TABLE|WHERE)\b)', caseSensitive: false),
    RegExp(r"('|)(OR|AND)\b\s*'?\d+'?\s*=\s*'?\d+'?", caseSensitive: false),
    // Directory / Path Traversal
    RegExp(r'(\.\./|\.\.\\)', caseSensitive: false),
  ];

  static bool containsThreat(String input) {
    if (input.trim().isEmpty) return false;
    return _maliciousPatterns.any((pattern) => pattern.hasMatch(input));
  }
}
```

#### Alerting Pipeline Rules:
1. **Silent Telemetry Dispatch:** When `SecurityPayloadDetector.containsThreat(input)` evaluates to `true`, dispatch a high-severity security event to Sentry, Crashlytics, or a dedicated security webhook without exposing detector internals in UI error messages.
2. **Generic User Feedback:** Display a neutral validation message to the user (e.g., `"Invalid characters entered"`) so attackers cannot reverse-engineer client-side regex rules.
3. **Alert Throttling & Rate-Limiting:** Throttle security alerts per user/device ID to prevent alert fatigue or DoS in case automated fuzzing tools are executed against the client.
4. **Sanitize Alert Payloads:** When relaying captured payload strings to Slack, Discord, or developer dashboards, escape characters to prevent secondary execution in administrative tools.

---

## 9. Error Handling, Logging & Observability

### 9.1 Typed Error Hierarchy
```dart
// lib/core/errors/failures.dart
sealed class Failure {
  final String message;
  final int? statusCode;
  const Failure({required this.message, this.statusCode});
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection detected.'});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Session expired. Please log in again.'});
}
```

### 9.2 Centralized Logging
- Use structured logging (e.g., `talker_flutter` or `logger`).
- Never use `print()` or `debugPrint()` casually.
- Global crash reporting: Connect `FlutterError.onError` and `PlatformDispatcher.instance.onError` to Crashlytics / Sentry.

---

## 10. Testing Strategy & Quality Assurance

### 10.1 Unit Tests (Target: 80%+ Domain & Data Layer Coverage)
- Test all business logic, use cases, repository parsing, and state transitions.
- Use `mocktail` (1.0.5) for dependency mocking. `flutter test` remains the runner.
- For Bloc, use `bloc_test` 10.0.0 (it depends on `bloc` ^9, not on a `bloc` 10). For BlocSignals, use `bloc_signals_test` 1.0.3.

### 10.2 Widget Tests
- Test atomic components and feature screens for state rendering (`AsyncData`, `AsyncLoading`, `AsyncError`).
- Test user interactions (tapping buttons, entering text, validating form triggers).
- Pump feature screens and text-bearing shared widgets at `TextScaler.linear(1.5)` and `TextScaler.linear(2.0)`, at about 375 logical pixels wide, in NL and EN. When the app has a dark scheme, pump light and dark as well. Section 4.6 is the layout rule. These tests lock it in.
- Assert no `RenderFlex` overflow. `tester.takeException()` returns the `FlutterError` an overflow reports during the pump. `expect(tester.takeException(), isNull)` fails the test when that error was reported.
- Where the screen puts labels inside an `InteractiveViewer`, the test finds those labels and checks they are not clipped away. A label under a clip, with no scroll or pan that can bring it on screen, fails the test. `takeException()` does not catch that clip.
- At text scale 1.0, `meetsGuideline(androidTapTargetGuideline)` and `meetsGuideline(iOSTapTargetGuideline)` from [accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing) cover the 48dp and 44pt floors. They do not replace the overflow pumps at 1.5 and 2.0.

`MaterialApp` builds its own `MediaQuery` from the view, so a `MediaQuery` placed above `MaterialApp` does not win. Put the scaler on the `builder`, under the app's media query. The root widget in the sample is the app's. On `material_ui` that is `MaterialApp` or `MaterialApp.router` from `package:material_ui`. `physicalSize` is in physical pixels. With `devicePixelRatio` 1.0, 375×667 is the iPhone SE-class logical size from section 4.6. Repeat the pump with `TextScaler.linear(1.5)` and with `Locale('en')`.

```dart
testWidgets('screen does not overflow at text scale 2', (tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(375, 667);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('nl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2.0),
          ),
          child: child!,
        );
      },
      home: const ReservationScreen(),
    ),
  );

  expect(tester.takeException(), isNull);
});
```

### 10.3 Integration Tests
- End-to-end user journeys tested in the `integration_test/` directory, with the SDK package `integration_test` (not the older `flutter_driver` flow).

---

## 11. Documentation & Code Intent Comments

### 11.1 The "Why" vs The "How" Rule
- **Self-Documenting Code:** Choose expressive, intentional variable and function names.
- **Explain Intent and Context:** Comments must explain **why** a decision was made, constraints imposed by external APIs, or complex domain rules—not repeat what the code does.

```dart
// ❌ BAD: Stating the obvious
// Increments counter by one
counter++;

// ✅ GOOD: Documenting constraint and architectural intent
// We debounce search queries by 350ms to prevent exceeding the backend API 
// rate limit (Tier-2 quota: max 10 req/sec) while keeping the UI responsive.
final debouncedStream = queryStream.debounceTime(const Duration(milliseconds: 350));
```

### 11.2 Public API Documentation
All public methods, models, and widgets must have standard Dartdoc comments (`///`).

---

## 12. AI Agent Directives & Dependency Vetting Protocol

When AI agents (Claude, GPT, Gemini, Cursor, Copilot, Windsurf) scaffold, write, refactor, or review code, they MUST adhere to the following strict governance:

### 12.1 Strict Package Curation & Human Approval Gate
1. **Trusted Publishers Pre-Approved:** Packages published by the Dart team (`dart.dev`), Flutter team (`flutter.dev`), Google, Very Good Ventures, or universally recognized core ecosystem maintainers (e.g., Remi Rousselet, Felix Angelov) are pre-approved for inclusion.
2. **Third-Party / Non-Standard Packages Require Human Vetting:** If the AI agent proposes adding a package from an unfamiliar or individual publisher, the AI **MUST NOT** silently add it to `pubspec.yaml`. Instead, it must pause and present a structured **Package Evaluation Card** to the human developer:
   ```markdown
   ### 📦 Proposed Package Evaluation: [<package_name>](https://pub.dev/packages/<package_name>)
   - **Publisher / Maintainer:** [Verified / Unverified Publisher Name]
   - **Metrics:** Pub Points: X/160 | Popularity: Y% | Likes: Z | Last Updated: [Date]
   - **Purpose & Justification:** Why this package is needed and what problem it solves.
   - **Established Alternatives:** (e.g., Alternative A, Alternative B) and comparison.
   - **Maintenance Risk Assessment:** (e.g., active updates, open issue backlog, Flutter 3 compatibility).
   - **Android Toolchain Compatibility:** Verified compatible with Built-in Kotlin (no legacy imperative KGP plugin application) and latest AGP.
   - **Decision Required:** Human developer confirmation needed before updating `pubspec.yaml`.
   ```

Flag on the Android toolchain line in that card: Flutter 3.47 still builds many plugins that apply the Kotlin Gradle Plugin, with `android.builtInKotlin=false`. Record whether the plugin has migrated. Do not treat a not-yet-migrated plugin as an automatic reject while Flutter's temporary KGP support is in place. See section 13.2.

### 12.2 Operational AI Coding Rules
1. **Consult PRD & Guidelines First:** Never invent unapproved business logic or substitute architecture without confirmation.
2. **File Size Guideline:** Smaller files are better, and **200–250 lines is the target**, but there can be exceptions. Good maintainability is the key goal. A generated file over the target is fine when splitting it would hurt maintainability, and such an exception should be noted briefly in a code comment or in the project's `GUIDELINES_EXCEPTIONS.md`. This is a guideline with justified exceptions, not a hard cap. Modularize screens into sub-widgets when that split improves maintainability.
3. **No Truncated Placeholders:** Never emit lazy comments like `// ... rest of code unchanged ...`. Always provide valid, compilable code or targeted diffs.
4. **Automated Code Generation:** Whenever modifying Freezed, Riverpod, JSON Serializable models, or Widgetbook use-cases and stories, trigger or instruct running `dart run build_runner build --delete-conflicting-outputs`. Widgetbook's generators are in section 4.7.
5. **Zero hard-coded design values:** Keep colors, user-facing strings, dimensions, spacing, radii, durations, breakpoints, and other magic values out of widgets. Read them from the app's theme, tokens, or l10n. User-facing strings go in gen-l10n ARB files (`flutter: generate: true`). Do not copy another app's palette, type scale, spacing, or breakpoints. See section 4.
6. **System text scale:** Honour `MediaQuery.textScaler`. Do not set `TextScaler.noScaling`, `MediaQuery.withNoTextScaling`, or a scaler of 1.0 except the documented exception in section 4.6. Layout and the widget tests are sections 4.6 and 10.2.
7. **Mix, Remix, Widgetbook:** Do not add them to an existing app unless the task says so. Do not invent a shared Mix theme, a shared Remix skin, or a Fluent UI house style. New apps follow section 4.7. Do not rewrite an app off `package:material_ui` in order to adopt Mix.

---

## 13. Modern Android Toolchain & Gradle/KGP Compatibility Policy

To prevent build failures, deprecation notices, and unmaintained dependency lock-in when bootstrapping and developing new Flutter projects:

### 13.1 Mandatory Toolchain Baselines

Match the Flutter 3.47.7 app template. On 2026-10-16, Android's latest AGP is 9.4.1 (the 9.4 line wants Gradle 9.6.0) and Kotlin's latest stable is 2.4.21. `gradle_utils.dart` on the 3.47.7 tag sets the template to the versions below and sets `maxKnownAndSupportedKgpVersion` to 2.4.0. Stay on that template until a newer Flutter stable raises it.

- **Gradle:** 9.3.1 (`android/gradle/wrapper/gradle-wrapper.properties`).
- **Android Gradle Plugin (AGP):** 9.1.0.
- **Kotlin Gradle Plugin (KGP):** 2.4.0, for as long as the app still applies KGP. See section 13.2 before removing it.
- **Java:** 17. Gradle 9's minimum is 17.
- **SDK levels:** compileSdk 36, targetSdk 36, minSdk 24. AGP 9 removed the `compileSdkVersion` property; set `compileSdk`.
- **NDK:** 28.2.13676358 (r28), which is what the Flutter template uses for 16 KB page alignment.
- **Declarative plugins block:** Use the Kotlin DSL plugins block in `android/settings.gradle.kts`. Do not inject AGP with a legacy `classpath` line in `build.gradle`.

```kotlin
// android/settings.gradle.kts — Flutter 3.47 template
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}
```

`kotlinOptions { jvmTarget = ... }` does not compile on this Kotlin line. When the app module still applies KGP, set the JVM target with `kotlin { compilerOptions { jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17 } }`.

### 13.2 Built-in Kotlin Support & Legacy Plugin Ban

**Current status (Flutter 3.47).** AGP 9 enables built-in Kotlin by default on native Android projects, which means those projects stop applying `org.jetbrains.kotlin.android`. Flutter does not follow that default yet:

- Flutter 3.44 can build AGP 9 only with `android.builtInKotlin=false`.
- Flutter 3.47 can set `android.builtInKotlin=true` after the app module and every Flutter plugin have migrated.
- The Flutter migrator still writes `android.builtInKotlin=false` and `android.newDsl=false` into `gradle.properties`.
- The 3.47 template still applies `org.jetbrains.kotlin.android` in `settings.gradle.kts`.
- Apps that do not apply KGP at all should not be migrated to built-in Kotlin. They only need `android.newDsl=false` until the new DSL is the default they actually use.

Enable built-in Kotlin by removing `kotlin-android` from the app module, replacing `kotlinOptions` with `kotlin.compilerOptions`, and then setting `android.builtInKotlin=true`. If `flutter run` fails on an unmigrated plugin, turn the flag back off and keep KGP until that plugin ships a migration. Flutter has said the temporary KGP support will be removed later.

The rules below are the target. The status note above qualifies them: a plugin that still applies KGP is not an automatic reject on Flutter 3.47.

1. **Zero Legacy KGP Dependency Acceptance (target):** At the start of a project and when adding packages, prefer plugins that do not imperatively apply the legacy Kotlin Gradle Plugin (`apply plugin: 'kotlin-android'`) in their native Android module. Flag, not a hard reject today: Flutter 3.47 still builds those plugins while `android.builtInKotlin=false`. Reject a plugin for this reason when it is also unmaintained and blocks a project that is ready to turn built-in Kotlin on.
2. **Built-in Kotlin Adherence (target):** Prefer plugins that support Flutter's **Built-in Kotlin** architecture ([migration guide for app developers](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)). Do not set `android.builtInKotlin=true` until every plugin in the app has migrated.
3. **Pre-Bootstrap Dependency Audit:**
   - Before finalizing `pubspec.yaml`, verify plugins against their latest changelog.
   - Run `flutter pub outdated` and note any plugin that triggers:
     `"WARNING: Your app uses plugins that apply Kotlin Gradle Plugin (KGP)..."`.
   - If an unmaintained package triggers this warning and has no maintained fork or Built-in Kotlin update, it is **strictly rejected** in favor of modern alternatives or custom platform channel implementations. A maintained plugin that still applies KGP is recorded, not rejected, while Flutter's compatibility flag exists.

### 13.3 Store submission baselines

**Google Play**

- Since 2026-08-31, new apps and updates must target Android 16 (API 36) or higher. Wear OS and Android Automotive stay on API 35 for that rule; Android TV and Android XR stay on API 34. The Flutter template's targetSdk 36 meets the phone and tablet rule.
- Apps that target API 35 or higher and ship native code must support 16 KB memory page sizes on 64-bit devices. Java/Kotlin-only apps are compatible by default. Starting 2027-02-01, an update that does not support 16 KB page sizes cannot be released. AGP 8.5.1+ and NDK r28+ (the Flutter template NDK is 28.2.13676358) are the alignment baseline. Still check prebuilt native SDKs.

**App Store**

- Since 2026-04-28, uploads must be built with Xcode 26 or later using the iOS 26, iPadOS 26, tvOS 26, visionOS 26, or watchOS 26 SDK.
- Since 2026-09-09, iOS and iPadOS apps must target iOS 13 or later.
- Not yet in force: starting April 2027, iOS and iPadOS apps must be built with the iOS 27 SDK or later and target iOS 15 or later.

---

## 14. MCP Server Ecosystem & Tool Integrations

Modern AI-assisted development leverages the **Model Context Protocol (MCP)** to allow AI coding agents direct, secure, and typed access to the development environment, tooling, and backend services.

### 14.1 Standard Recommended MCP Servers for Flutter

```
+-----------------------------------------------------------------------+
|                              AI Agent                                 |
+-----------------------------------+-----------------------------------+
                                    | Model Context Protocol (MCP)
     +------------------------------+------------------------------+
     |                              |                              |
     v                              v                              v
+------------------------+  +------------------------+  +------------------------+
|   Dart & Flutter MCP   |  |     Firebase MCP       |  |  Filesystem & Git MCP  |
|  - Static analysis     |  |  - Firestore schemas   |  |  - Directory structure |
|  - DevTools telemetry  |  |  - Security rules      |  |  - Git history & diffs |
|  - Pub dependency ops  |  |  - Emulator management |  |  - Atomic refactorings |
|  - Test runner         |  |  - Cloud Functions     |  |                        |
+------------------------+  +------------------------+  +------------------------+
```

#### 1. Official Dart & Flutter MCP Server
- **Capabilities:** Analyzes code with the Dart analyzer, runs `dart analyze` / `flutter test`, inspects live running widgets and runtime errors, and runs pub operations. Not every tool is on by default. `dart mcp-server --help` lists tools and categories. Enable a category with `--enable`, for example `flutter_app_lifecycle`.
- **Invocation:** `dart mcp-server`. The `--experimental-mcp-server` flag is only for Dart older than 3.9. Do not launch this server with `dart run flutter_mcp`. A pub package named `flutter_mcp` (2.0.2) exists; it is a third-party plugin, not this official server.
- **Setup (IDE / Agent Configuration):**
  ```json
  {
    "mcpServers": {
      "dart": {
        "command": "dart",
        "args": ["mcp-server"]
      }
    }
  }
  ```

#### 2. Firebase MCP server (official)
- **CLI:** Part of the Firebase CLI. It needs Node.js and npm. It runs locally using the Firebase CLI login credentials (`firebase login`).
- **Cursor, recommended:** Install the Firebase plugin from the Cursor Marketplace. That also adds Firebase agent skills.
- **Cursor, manual:** `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (global):
  ```json
  {
    "mcpServers": {
      "firebase": {
        "command": "npx",
        "args": ["-y", "firebase-tools@latest", "mcp"]
      }
    }
  }
  ```
- **Antigravity:** Agent pane `…` menu > MCP Servers > Firebase > Install. This writes `mcp_config.json` with server key `firebase-mcp-server` and the same command and args.
- **Optional args:** `--dir <absolute path containing firebase.json>`. `--only <comma list, e.g. firestore,auth,functions>` limits tools. Core tools stay on.
- **Tool approval:** Agents must ask before any write, deploy, or delete tool (for example `firestore_delete_*`, `firebase_deploy`, `auth_update_user`).
- **Scope:** Only for Firebase projects, such as zwitsers_veldschieten. An app that does not use Firebase records that in its local copy of this file or in `GUIDELINES_EXCEPTIONS.md`.

#### 3. Filesystem & Git MCP Server
- **Capabilities:** Provides structured tree navigation, safe atomic file manipulation, and Git branch/diff analysis to verify no breaking regressions are introduced during refactors.
- **Package:** This document does not name an npm or pub package for this server. No single official "Filesystem & Git MCP" command was verified on 2026-10-16, so none is invented here. Use the editor's own filesystem and git tools unless a project explicitly adopts a named server.

---

## 15. Project Bootstrap & Dependency Blueprint

### 15.1 Standard `pubspec.yaml` Baseline

Pins below were checked against pub.dev and the Flutter 3.47.7 SDK on 2026-10-16. They are a starting baseline, not a freeze. Use the current stable versions, still subject to the package-vetting rules in section 12.1. Re-check pub.dev before locking a new app. An app repo may record a different pin in its local exceptions.

`mix`, `remix`, and `widgetbook` are not in this baseline. Existing apps are not required to add them. Section 4.7 says when a new app adds them, and which versions were current on 2026-11-12. Verify current versions before locking. Do not copy those numbers here.

`riverpod_annotation` and `riverpod_generator` are major 4 beside `flutter_riverpod` 3.4.3. `freezed` 4.0.2 uses `freezed_annotation` 3.1.0. `dual_screen` is omitted because 1.0.4 does not resolve on Dart 3. `gap` 3.0.1 is the latest release and still resolves; it was last published 2023-06-24, so treat it as unmaintained and replace it when a vetted alternative is chosen. `hooks_riverpod` is not in this baseline: its `flutter_hooks` 0.21.3+1 constraint is `sdk: >=2.17.0 <3.0.0`, which does not resolve on Dart 3.13.

```yaml
name: app_name
description: "A modern, robust Flutter application."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.0
  flutter: ">=3.47.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Standalone design libraries (Flutter 3.47+). Prefer these over
  # package:flutter/material.dart where dependencies support it.
  # Same ThemeData, ColorScheme, and ThemeExtension API. See section 4.
  material_ui: ^1.7.0
  # cupertino_ui: ^1.1.3

  # State Management (Select according to PRD: Riverpod / Bloc / BlocSignals)
  flutter_riverpod: ^3.4.3
  riverpod_annotation: ^4.0.7
  # flutter_bloc: ^9.1.1
  # bloc_signals_flutter: ^1.5.0

  freezed_annotation: ^3.1.0

  # Routing & Navigation
  go_router: ^18.1.0

  # Networking & Serialization
  dio: ^5.11.1
  json_annotation: ^4.12.0
  fpdart: ^1.2.0

  # Storage & Security
  flutter_secure_storage: ^11.2.0
  shared_preferences: ^2.5.6

  # UI, Icons, Layout & Adaptive Screen Support
  flutter_svg: ^2.3.0
  gap: ^3.0.1
  cached_network_image: ^4.0.4
  intl: ^0.20.3

  # Logging & Observability
  talker_flutter: ^5.1.20

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.17.1
  go_router_builder: ^4.5.0
  riverpod_generator: ^4.0.9
  freezed: ^4.0.2
  json_serializable: ^6.14.1
  mocktail: ^1.0.5
  # bloc_test: ^10.0.0
  # bloc_signals_test: ^1.0.3

flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/icons/
    - assets/images/
    - assets/vectors/
```

### 15.2 WebAssembly for Flutter web

`flutter build web --wasm` and `flutter run -d chrome --wasm` are stable. The tool still emits a JavaScript build and uses it when the browser has no WasmGC. Multi-threaded rendering requires the server to send `Cross-Origin-Embedder-Policy: credentialless` (or `require-corp`) and `Cross-Origin-Opener-Policy: same-origin`.

Do not import `dart:html` or `package:js` in code that must compile to Wasm. Use `package:web` and `dart:js_interop`. `flutter build web` without `--wasm` still runs a Wasm dry run and prints incompatibilities as warnings.

Wasm deferred loading (`--enable-wasm-deferred-loading`) is experimental and is planned for the Flutter 3.50 stable. It is not available as a stable flag on 3.47.

Browser limits, from the Flutter Wasm page: Chromium supports WasmGC. Firefox and Safari have known renderer bugs that block Flutter's Wasm renderer. No browser on iOS can run a Flutter Wasm build, because every iOS browser uses WebKit. Those clients get the JavaScript fallback.

---

## 16. Project-specific exceptions

Each app repo keeps its own exceptions in its local copy of this file, or in a `GUIDELINES_EXCEPTIONS.md` next to that copy. Where those exceptions conflict with the general rules above, the app's exceptions win for that repo only.

---
*End of Development Guidelines. Pass this document to your AI coding agents alongside the feature PRD to bootstrap and build new features reliably.*
