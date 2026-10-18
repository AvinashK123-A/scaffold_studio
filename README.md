# scaffold_studio

[![pub package](https://img.shields.io/pub/v/scaffold_studio.svg)](https://pub.dev/packages/scaffold_studio)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)

Responsive, themeable building blocks for Flutter apps: an adaptive app shell,
configurable app bars, bottom bar / rail / sidebar navigation, a typography
system with an optional bundled Roboto font, and a small set of common
widgets.

Add one dependency and import one library. There are no other packages to
install and no font assets or configuration files to copy.

```dart
import 'package:scaffold_studio/scaffold_studio.dart';
```

> **Status:** `0.2.0`, pre-release. The API may still change before `1.0.0`.

## Contents

- [Features](#features)
- [Installation](#installation)
- [Quick start](#quick-start)
- [App shell and navigation](#app-shell-and-navigation)
- [App bars](#app-bars)
- [Typography and fonts](#typography-and-fonts)
- [Common widgets](#common-widgets)
- [Search field](#search-field)
- [Theming](#theming)
- [Responsive behavior](#responsive-behavior)
- [Accessibility](#accessibility)
- [Known limitations](#known-limitations)
- [Example app](#example-app)
- [License and attribution](#license-and-attribution)

## Features

| Module | What you get |
| --- | --- |
| `ScaffoldStudioApp` | A `MaterialApp` (and `.router`) wrapper that builds the theme from `StudioTheme`, `StudioFont` and `StudioTypography`. Every `MaterialApp` option is passed through. |
| `ScaffoldStudio` | A responsive `Scaffold`: app bar, body, adaptive navigation, drawers, FAB, safe areas, keyboard handling and a maximum content width. |
| `StudioAppBar` | One app bar with 10 styles: standard, centered, minimal, transparent, gradient, image, rounded, search, profile and flexible. Includes logo, avatar, search field, badges and an overflow menu for actions. |
| `StudioBottomBar` | A bottom bar with 7 styles: material, floating, rounded, minimal, labeled, animated and notched (FAB). Badges, custom colors, backgrounds, indicators and item builders work with every style. |
| `StudioNavigationRail`, `StudioSidebar` | A rail and a sidebar/drawer driven by the same `StudioNavItem`s. |
| `StudioFont`, `StudioTypography` | An app-wide font (system, bundled Roboto or your own) and per-role text styles. |
| Common widgets | `CommonHeaderText`, `CommonBodyText`, `CommonLabelText` (each with a link mode), `CommonButton`, `CommonIconButton`, `CommonBadge`, `CommonCard`, `CommonDivider`, `CommonSearchField`. |
| Responsive utilities | `StudioBreakpoints`, `StudioWindowSize`, `StudioResponsiveBuilder`. |

Every widget also works on its own inside a plain `MaterialApp` and `Scaffold`.
The package has no state-management dependency and no dependencies outside
the Flutter SDK.

## Installation

```yaml
dependencies:
  scaffold_studio: ^0.2.0
```

Then run `flutter pub get`.

Requirements: Flutter 3.38.0 or later, Dart 3.10.0 or later. The package was
developed and tested with Flutter 3.44.7 and Dart 3.12.2. Compatibility with
the minimum versions was checked by confirming that every framework API the
package uses exists in Flutter 3.38.0. The test suite has not been run on that
version.

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

void main() {
  runApp(
    const ScaffoldStudioApp(
      fontFamily: StudioFont.roboto,
      theme: StudioTheme.light,
      darkTheme: StudioTheme.dark,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const List<StudioNavItem> _destinations = <StudioNavItem>[
    StudioNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    StudioNavItem(icon: Icons.inbox_outlined, label: 'Inbox', badgeCount: 4),
    StudioNavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldStudio(
      appBar: StudioAppBar(
        titleText: 'Dashboard',
        actions: <Widget>[
          StudioAction(
            icon: Icons.notifications_outlined,
            tooltip: 'Notifications',
            badge: '3',
            onPressed: () {},
          ),
        ],
      ),
      navigation: StudioNavigation(
        items: _destinations,
        selectedIndex: _index,
        onSelected: (int i) => setState(() => _index = i),
      ),
      body: IndexedStack(
        index: _index,
        children: const <Widget>[
          Center(child: CommonHeaderText('Home')),
          Center(child: CommonHeaderText('Inbox')),
          Center(child: CommonHeaderText('Profile')),
        ],
      ),
    );
  }
}
```

On a phone this shows a bottom bar. On a tablet or a resized desktop window it
switches to a navigation rail, and on wide windows to a sidebar. The selected
destination stays the same across these switches.

## App shell and navigation

`ScaffoldStudio` composes a Material `Scaffold`. All of its parts are
optional: you can omit the app bar, the navigation or the drawer.

```dart
ScaffoldStudio(
  appBar: const StudioAppBar(titleText: 'Orders'),
  floatingActionButton: FloatingActionButton(onPressed: create, child: const Icon(Icons.add)),
  navigation: StudioNavigation(
    items: destinations,
    selectedIndex: index,
    onSelected: (i) => setState(() => index = i),
    // Optional: fix the presentation instead of adapting it.
    // mode: StudioNavigationMode.drawer,
    bottomBarStyle: StudioBottomBarStyle.floating,
  ),
  contentMaxWidth: 960,
  body: content,
)
```

### Navigation modes

| Window size | Default (`StudioNavigationMode.adaptive`) | Override per size |
| --- | --- | --- |
| Compact (< 600) | `bottomBar` | `compactMode` |
| Medium (600 to < 840) | `rail` (the FAB moves into the rail) | `mediumMode` |
| Expanded (≥ 840) | `sidebar` | `expandedMode` |

Set `mode` to `bottomBar`, `rail`, `sidebar` or `drawer` to fix the
presentation regardless of width.

### State ownership

The navigation widgets never own the selected index. There are two ways to
manage it:

- **Controlled:** pass `selectedIndex` and `onSelected`, and call `setState`
  yourself, as in the quick start above.
- **Controller-managed:** pass a `StudioNavigationController`, a
  `ValueNotifier<int>` that you create and dispose. You can then build the body
  with `bodyBuilder: (context, index) => pages[index]`.

### Preserving page state

Switching destinations does not, by itself, preserve each page's state.
`ScaffoldStudio` only decides which navigation widget to show; your body
decides how pages are kept. To keep scroll positions and form input, put the
pages in an `IndexedStack` (as in the quick start) or give scrollables a
`PageStorageKey`.

### Invalid input

- An empty `items` list shows no navigation.
- A `selectedIndex` outside the valid range selects nothing. It never throws,
  because a stale index is normal while item lists change. `bodyBuilder`
  receives `-1` in that case.
- Disabled items (`enabled: false`) ignore taps.
- Configuration mistakes, such as passing both `selectedIndex` and
  `controller`, fail an assertion in debug builds with a descriptive message.

## App bars

```dart
StudioAppBar(
  style: StudioAppBarStyle.flexible,
  leading: const CircleAvatar(child: Icon(Icons.person)),
  titleText: 'Dashboard',
  subtitleText: 'Welcome back',
  actions: [
    StudioAction(
      icon: Icons.notifications_outlined,
      tooltip: 'Notifications',
      badge: '3',
      onPressed: () {},
    ),
  ],
)
```

Every style is rendered by the same implementation, which is built on
Material's `AppBar`. Back navigation, drawer buttons, status bar styling,
safe areas and scroll elevation therefore behave as they do in Flutter. A style
only supplies defaults, and any argument overrides them: `backgroundColor`,
`foregroundColor`, `gradient`, `backgroundImage`, `elevation`, `height`,
`minHeight`, `borderRadius`, `centerTitle`, `titleSpacing`, `actionSpacing`,
`systemOverlayStyle`, `primary` (safe area) and `onBackPressed`.

Custom widgets can go in `leading`, `title`, `subtitle`, `logo`, `profile` and
`actions`.

How the app bar adapts:

- **Long titles** stay on one line and are ellipsized. A subtitle gets one
  line below the title.
- **Many actions:** when the bar is too narrow, trailing `StudioAction`s that
  have a tooltip move into an overflow menu, so the title keeps about 40% of
  the width. If a hidden action has a badge, the overflow button shows a dot.
  Use `maxVisibleActions` to control this directly. Widgets other than
  `StudioAction` are never moved.
- **Search:** `StudioAppBarStyle.search` replaces the title with a search
  field (title and field side by side on wider screens). Other styles with a
  `search` configuration show a search button on compact widths that expands
  the field in place.
- **Text scaling:** inside a `ScaffoldStudio`, the toolbar height grows with
  the system text scale, up to 1.5×. In a plain `Scaffold` the height is fixed,
  because Flutter reads `preferredSize` before the widget tree is available.
  Text that does not fit is clipped and never overflows.

## Typography and fonts

```dart
ScaffoldStudioApp(
  fontFamily: StudioFont.roboto,           // or StudioFont.system (default)
  typography: const StudioTypography(
    header: TextStyle(fontWeight: FontWeight.w700),
    link: TextStyle(fontWeight: FontWeight.w500),
  ),
  home: const HomePage(),
)
```

- `StudioFont.system` uses the platform's default Material font and bundles
  nothing. This is the default.
- `StudioFont.roboto` uses Roboto 2.138, which is bundled with this package.
  It includes Light (300), Regular (400), Italic (400), Medium (500) and Bold
  (700). A weight with no bundled face, such as `w600`, is drawn with the
  nearest bundled weight chosen by the platform's font matcher; it is not a
  true semibold. Use `StudioFont.roboto.supportsWeight(...)` to check.
- `StudioFont.custom('Inter', package: 'my_fonts')` refers to a font that your
  app or another package declares.

**How loading works.** Roboto is declared in this package's `pubspec.yaml`. The
Flutter tool adds it to every consuming app's font manifest as
`packages/scaffold_studio/Roboto`, and the engine registers it at startup. You
do not need to declare it in your app. No runtime `FontLoader` is used, so
there is no initialization step and no flash of fallback text. The font files
add about 1.7 MB to every app that depends on this package, including apps
that use only `StudioFont.system`. Flutter cannot leave out declared fonts that
an app does not use.

**What the global font affects.** The font becomes the default family of the
theme's `textTheme` and `primaryTextTheme`. That covers `Text` widgets and
Material widgets that take their style from the theme. It does **not**
override a `TextStyle` that sets its own `fontFamily`, or third-party widgets
that set their own fonts. A single `Common*Text` widget can override the font
with `fontFamily:`. `StudioFont.system` there restores the platform font even
when the app uses Roboto.

### `CommonHeaderText`, `CommonBodyText`, `CommonLabelText`

```dart
CommonHeaderText(
  'Hi Alex, how are you?',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.black,
  maxLines: 2,
)

CommonHeaderText('View profile', link: true, onTap: openProfile)                   // underlined link
CommonHeaderText('Open dashboard', link: true, underline: false, onTap: openDash)  // link, no underline
```

Styles are resolved in this order, lowest priority first:

1. The role's base style from the theme (`titleLarge` at w600, `bodyMedium`
   or `labelLarge`).
2. The `StudioTypography` override for that role.
3. Link color and underline, when `link: true`.
4. `style`.
5. Individual arguments: `fontFamily`, `fontSize`, `fontWeight`, `fontStyle`,
   `color`, `letterSpacing`, `lineHeight`, `decoration`.

Link behavior:

- The default link color is a blue derived from a Material tonal palette for
  the current brightness (light or dark). Set `StudioTheme.linkColor` to change
  it.
- Links are underlined by default. `underline: false` removes the underline
  but keeps the color, interaction and semantics. You can also set
  `underlineColor`, `underlineStyle` and `underlineThickness`.
- `link: true` without `onTap` fails an assertion in debug builds with a clear
  message. In release builds the text keeps its link styling but is not
  interactive.
- Interactive text can take keyboard focus, is activated with Enter or Space,
  shows a focus ring, shows a click cursor on hover, and is announced as a
  link (or as a button when `link` is false). Its touch target is padded to
  48 px when the theme's `materialTapTargetSize` is `padded`.
- Text without `onTap` is a plain `Text` with no gesture detector, so it stays
  selectable inside a `SelectionArea`.

## Common widgets

| Widget | Built on | Notes |
| --- | --- | --- |
| `CommonButton` | `FilledButton`, `FilledButton.tonal`, `ElevatedButton`, `OutlinedButton`, `TextButton` | `variant`, `size`, `icon`, `trailingIcon`, `isLoading` (shows progress, ignores presses, announces `loadingLabel`), `expand`, `style` |
| `CommonIconButton` | `IconButton` and its variants | Requires a `tooltip` or `semanticsLabel`. Takes `badge` / `badgeCount` and a selected state. |
| `CommonBadge` | `Badge` | `count` with `maxCount` (`99+`), `label`, dot, `showZero`, `semanticsLabel` |
| `CommonCard` | `Card`, `Card.filled`, `Card.outlined` | Padding, `onTap` with ink ripple and focus, `borderRadius` |
| `CommonDivider` | `Divider`, `VerticalDivider` | An optional centered `label` (for example "OR") that wraps instead of overflowing |
| `CommonSearchField` | `TextField` | Four variants, a debounced `onSearch`, clear button, loading indicator, trailing widgets and a `CommonSearchFieldStyle` that controls every visual detail. See [Search field](#search-field). |

## Search field

`CommonSearchField` is a search box built on Material's `TextField`, so
editing, selection, input methods and screen readers behave like any Flutter
text field. Every visual detail is configurable.

```dart
CommonSearchField(
  hintText: 'Search products',
  onSearch: (String query) => repository.search(query), // debounced
)
```

### Behavior

| Parameter | What it does |
| --- | --- |
| `onChanged` | Called on every edit with the raw text. |
| `onSearch` | Called once typing pauses for `searchDebounce` (300 ms by default), and immediately on submit or clear. Trimmed when `trimSearchQuery` is `true`; non-empty queries shorter than `minSearchLength` are skipped; repeated queries are not reported twice. |
| `onSubmitted`, `onCleared`, `onTap`, `onTapOutside`, `onFocusChange` | The usual events. |
| `controller`, `focusNode`, `initialValue` | Bring your own, or let the field create and dispose them. |
| `isLoading`, `loadingLabel` | Shows a progress indicator at the end of the field. |
| `clearButtonMode` | `never`, `whenNotEmpty` (default), `whenFocusedAndNotEmpty` or `always`. Use `clearButtonBuilder` for a custom button and `clearTooltip` to localize. |
| `clearOnEscape` | Escape on a hardware keyboard clears a non-empty field. |
| `prefix`, `showPrefixIcon`, `trailing` | Replace or hide the search icon; add buttons such as voice or filters. |
| `enabled`, `readOnly`, `autofocus` | A read-only field with `onTap` makes a good entry point to a separate search page. |
| `keyboardType`, `textInputAction`, `textCapitalization`, `textAlign`, `textDirection`, `autocorrect`, `enableSuggestions`, `inputFormatters`, `maxLength`, `keyboardAppearance`, `autofillHints`, `contextMenuBuilder`, `mouseCursor` | Passed to the `TextField`. |
| `decorationBuilder` | Last-chance access to the final `InputDecoration`, for anything not covered by the style. |

### Style

Pick a `variant` (`filled`, `outlined`, `underlined` or `plain`) and override
any value with `CommonSearchFieldStyle`. Unset values fall back to the theme
and then to the variant defaults.

```dart
CommonSearchField(
  variant: CommonSearchFieldVariant.outlined,
  style: CommonSearchFieldStyle(
    height: 44,
    maxWidth: 480,
    font: StudioFont.roboto,
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
    cursorColor: Colors.deepPurple,
    backgroundColor: Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    borderWidth: 1,
    focusedBorderWidth: 2,
    borderColor: const Color(0xFFD0D5DD),
    hoverBorderColor: const Color(0xFF98A2B3),
    focusedBorderColor: Colors.deepPurple,
    shadows: const <BoxShadow>[
      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
    prefixIcon: Icons.manage_search,
    focusedPrefixIconColor: Colors.deepPurple,
    clearIcon: Icons.cancel,
  ),
)
```

| Group | Properties |
| --- | --- |
| Size | `height` (minimum; grows with large text), `width`, `maxWidth`, `contentPadding` |
| Text | `textStyle`, `hintStyle`, `font`, `cursorColor`, `cursorWidth`, `cursorHeight`, `cursorRadius`, `selectionColor`, `selectionHandleColor` |
| Fill | `backgroundColor`, `hoverBackgroundColor`, `focusedBackgroundColor`, `disabledBackgroundColor` |
| Border | `borderRadius`, `borderWidth`, `focusedBorderWidth`, `borderColor`, `hoverBorderColor`, `focusedBorderColor`, `disabledBorderColor` |
| Shadow | `shadows`, `focusedShadows` |
| Icons | `prefixIcon`, `prefixIconSize`, `prefixIconColor`, `focusedPrefixIconColor`, `prefixIconConstraints`, `clearIcon`, `clearIconSize`, `clearIconColor`, `clearButtonStyle`, `suffixIconColor`, `suffixIconSize` |
| Loading | `loadingIndicatorColor`, `loadingIndicatorSize`, `loadingIndicatorStrokeWidth` |
| Motion | `animationDuration`, `animationCurve` |

`CommonSearchFieldStyle` is a `ThemeExtension`, so you can set app-wide
defaults once:

```dart
ScaffoldStudioApp(
  themeOverride: (ThemeData theme) => theme.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ...theme.extensions.values,
      const CommonSearchFieldStyle(
        variant: CommonSearchFieldVariant.outlined,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ],
  ),
  home: const HomePage(),
)
```

`CommonSearchField.defaultStyle(theme, variant)` returns the complete default
style, a handy starting point for `copyWith`. The field sets every border
slot itself, so an app-wide `InputDecorationTheme` does not change it. In a
place with unbounded width, such as directly in a `Row`, it falls back to a
width of 360 instead of throwing; wrap it in `Expanded` to fill the row.

## Theming

`StudioTheme` is a small configuration object, not a separate theme engine.
`toThemeData()` returns an ordinary Material 3 `ThemeData` with a
`ColorScheme`, component themes (app bar, navigation bar, rail, drawer, card,
divider, badge) and a `StudioThemeData` `ThemeExtension`. The extension holds
the values Flutter has no slot for: link color, breakpoints, maximum content
width, typography roles and navigation animation timing.

```dart
ScaffoldStudioApp(
  theme: const StudioTheme(seedColor: Colors.teal, contentMaxWidth: 1080),
  // darkTheme defaults to a dark variant of `theme` when it is seed-based.
  themeMode: ThemeMode.system,
  themeOverride: _tweak, // final ThemeData adjustments
  home: const HomePage(),
)

ThemeData _tweak(ThemeData theme) => theme.copyWith(visualDensity: VisualDensity.compact);
```

Disabled, hover, focus and pressed states come from the Material components
and the `ColorScheme`. Under a plain `MaterialApp` without the extension,
`StudioThemeData.of(context)` falls back to sensible defaults, so every widget
still works.

## Responsive behavior

Breakpoints use **logical pixels of available width**, not device models:

| Width | `StudioWindowSize` |
| --- | --- |
| < 600 | `compact` |
| 600 to < 840 | `medium` |
| ≥ 840 | `expanded` |

Change them with `StudioTheme(breakpoints: StudioBreakpoints(medium: 640, expanded: 1024))`
or per shell with `ScaffoldStudio.breakpoints`. Decisions use the parent's
constraints, so split screen, multi-window, resizable desktop windows and
foldables that report a smaller window all work. `StudioResponsiveBuilder`
lets your own content adapt the same way.

**What the package controls:**

- The navigation structure (bottom bar, rail, sidebar or drawer) and keeping
  the selection when it changes.
- A maximum content width on wide screens (`StudioTheme.contentMaxWidth`,
  default 1200), so content is not stretched edge to edge.
- Safe areas (status bar, cutouts, gesture area, the floating bottom bar).
  Turn this off with `useSafeArea: false` for edge-to-edge bodies.
- Keyboard handling: the body resizes, and the bottom bar hides while the
  keyboard is open.
- App bar actions moving into an overflow menu, collapsible search, and
  height that grows with text scale.
- Bottom bar items moving into a "More" sheet when there are more items than
  fit at a usable width (64 px per item by default), and bar height that grows
  with text scale.

**What your body content controls:** scrolling when content can be taller than
the screen, avoiding fixed widths, changing its own layout (for example grid
column counts) with `StudioResponsiveBuilder`, and preserving page state.

The widget test suite renders the shell at logical widths 320, 360, 390, 430,
600, 768, 840, 1024, 1280 and 1440, in portrait and landscape, at 1× and 2×
text scale. It checks every app bar style and every bottom bar style with two
to five destinations at 2× text. A test matrix like this is no substitute for
checking on real devices.

## Accessibility

- Semantic labels throughout: headings for `CommonHeaderText`, link and button
  roles for interactive text, "Tab 2 of 4" position and selected state for
  bottom bar items, and badge text included in labels.
- Keyboard navigation and visible focus for links, buttons, navigation items
  and cards.
- Touch targets of at least 48 px on icon buttons, navigation items and padded
  text links.
- Text scaling is respected everywhere. Bars grow taller instead of clipping
  labels, and long labels are ellipsized while staying available as tooltips
  and to screen readers.
- Default colors come from Material 3 tonal palettes. The default link color
  meets 4.5:1 contrast against the theme surface in both light and dark mode,
  and a test checks this.
- Reduced motion: navigation animations are skipped when the platform
  requests it (`MediaQuery.disableAnimations`).
- Icon-only controls need a label: `CommonIconButton` asserts that it has one,
  and `StudioAction` should always be given a `tooltip`.
- Strings that are announced or shown by default ("More", "More options",
  "Search", "Clear", "Close search", "Loading") are English. Each can be
  overridden through a constructor argument for localization.

## Known limitations

- The ~1.7 MB of Roboto font files are included in every consuming app, even
  if it never uses `StudioFont.roboto`.
- Roboto 2.138 has no semibold (600) face. See [Typography and fonts](#typography-and-fonts).
- The app bar height adapts to text scale only inside `ScaffoldStudio`.
- Foldable hinge and posture APIs are not used. Layout follows the window
  width that the platform reports.
- The bottom bar "More" sheet, the overflow menu and the search field use the
  default English labels listed above unless you override them.
- Bottom bar and rail labels are kept to one or two lines. At very large text
  scales they are ellipsized, and the full label is available as a tooltip and
  to screen readers.
- Only Material is supported. There is no Cupertino-specific presentation.
- `StudioAppBar.onBackPressed` replaces the app bar back button's action
  only. To intercept the system back gesture or button, wrap the page in
  `PopScope`.
- Like most Flutter `copyWith` methods, `StudioTheme.copyWith` cannot reset a
  nullable field (such as `colorScheme` or `linkColor`) back to `null`.
  Construct a new `StudioTheme` instead.
- Automated tests run with Flutter's test font and in a macOS integration
  test. They do not replace checking on physical devices.

## Example app

The [`example/`](example/) directory contains a showcase app. It covers every
app bar and bottom bar style; 2 to 5 (and 7) destinations; adaptive, rail,
sidebar and drawer navigation; light and dark themes; font switching; text
widgets with links; badges; large accessibility text; and keyboard focus.

```bash
cd example
flutter run            # pick a device, or add -d macos / -d chrome
flutter test integration_test -d macos   # integration tests
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License and attribution

- **Package source code:** Copyright (c) 2026 Avinash Reddy Kommareddy,
  licensed under the BSD 3-Clause License. See [LICENSE](LICENSE).
- **Roboto font** (`assets/fonts/roboto/`): unmodified Roboto 2.138 files from
  the official [googlefonts/roboto](https://github.com/googlefonts/roboto/releases/tag/v2.138)
  release. Copyright 2011 Google Inc. Licensed under the Apache License,
  Version 2.0. The full license text is in
  [`assets/fonts/roboto/LICENSE.txt`](assets/fonts/roboto/LICENSE.txt) and in
  the second section of [LICENSE](LICENSE).

Because the font ships inside your app, its Apache-2.0 notice ships with it.
Flutter collects the notices from this package's `LICENSE` file into your
app's license registry, so they appear in `showLicensePage` and
`LicenseRegistry` without extra work. If you distribute your app in other
ways, include the Apache-2.0 notice for Roboto as that license requires.

No third-party source code is included in this package.
