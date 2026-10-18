# Architecture

This document explains how `scaffold_studio` is organized and why. It is for
contributors and for users who want to understand the package's behavior in
depth.

## Layers

```text
ScaffoldStudioApp         MaterialApp wrapper, theme caching
  └─ StudioTheme ─────────► ThemeData + StudioThemeData (ThemeExtension)
ScaffoldStudio            Scaffold composition, adaptive decisions
  ├─ StudioAppBar         one AppBar-based implementation, ten style specs
  ├─ StudioNavigation     configuration (items, selection, modes)
  │    ├─ StudioBottomBar
  │    ├─ StudioNavigationRail  (NavigationRail)
  │    └─ StudioSidebar         (NavigationDrawer)
  └─ body                 developer content
Common* widgets           thin layers over Text, TextField and Material buttons/cards
```

Each layer can be used without the ones above it. Every widget reads its
tokens with `StudioThemeData.of(context)`, which falls back to defaults when
the extension is not installed. That is what lets the widgets work under a
plain `MaterialApp`.

## Design decisions

**The theme comes from Flutter, not a parallel engine.** `StudioTheme`
produces an ordinary `ThemeData`. Only values Flutter has no slot for (link
color, breakpoints, content width, typography roles, navigation animation)
live in the `StudioThemeData` extension. Component defaults are expressed as
Flutter component themes, so `Theme.of(context)` and standard widgets behave
as developers expect.

**One app bar with style specs.** All ten `StudioAppBarStyle`s are entries in a
single table (`AppBarStyleSpec`) consumed by one layout built on Material's
`AppBar`. Back buttons, drawer buttons, status bar styling and scroll
elevation are inherited instead of reimplemented. Explicit arguments always
override the spec.

**Navigation state lives outside the layout widgets.** The selected index is
owned by the app (controlled) or by a `StudioNavigationController`. Because no
navigation widget holds it, the selection survives when `ScaffoldStudio`
replaces a bottom bar with a rail on resize.

**Responsive decisions use constraints.** `ScaffoldStudio`, `StudioAppBar`
and `StudioResponsiveBuilder` use `LayoutBuilder` constraints rather than the
screen size, so nested and split layouts behave correctly.

**Text scaling grows containers instead of clipping text.** The bottom bar
computes its height from the scaled label line height. `ScaffoldStudio`
reserves a scaled app bar height and publishes it to `StudioAppBar` through
an internal `InheritedWidget`, because `PreferredSizeWidget.preferredSize`
cannot read the widget tree.

**Fonts are declared, not loaded.** Roboto is declared in the package
`pubspec.yaml`, so the engine registers it at startup on every platform. This
avoids runtime `FontLoader` races and flashes of fallback text. The cost is
that the font files ship with every consuming app.

**Recoverable input does not throw.** Out-of-range indices select nothing,
empty item lists render nothing, and invalid dimensions are sanitized in
release builds. Developer mistakes such as a link without `onTap` fail an
`assert` in debug builds.

## Directory layout

```text
lib/
  scaffold_studio.dart      the only public entry point
  src/
    app/                    ScaffoldStudioApp
    app_bar/                StudioAppBar, StudioAction, search, styles
      internal/             style specs, overflow menu, height scope, search
    navigation/             items, bottom bar, rail, sidebar, configuration
      internal/             index validation, icon and semantics helpers
    responsive/             breakpoints, responsive builder
    scaffold/               ScaffoldStudio
    theme/                  StudioTheme, StudioThemeData
    typography/             StudioFont, StudioTypography
    widgets/                Common* widgets
      internal/             StudioTapRegion (interactive text)
assets/fonts/roboto/        Roboto 2.138 (Apache-2.0) and its license
test/                       unit and widget tests, responsive matrix
example/                    showcase app and integration tests
```
