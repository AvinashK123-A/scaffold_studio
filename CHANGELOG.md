## 0.2.0

- New `CommonSearchField`: a search text field built on `TextField` with
  four variants (`filled`, `outlined`, `underlined`, `plain`), a debounced
  `onSearch` callback (`searchDebounce`, `minSearchLength`,
  `trimSearchQuery`), a clear button with four visibility modes and a custom
  builder, Escape-to-clear, a loading indicator, a custom prefix and
  trailing widgets, read-only and disabled states, and pass-through of the
  usual `TextField` input options.
- New `CommonSearchFieldStyle`: controls every visual detail of the search
  field (size, text and hint style, font, cursor, selection colors, fill and
  border per interaction state, border radius and width, shadows, icons and
  loading indicator). It is also a `ThemeExtension` for app-wide defaults.

## 0.1.0

Initial release.

- `ScaffoldStudioApp` and `ScaffoldStudioApp.router`: `MaterialApp` wrappers
  that build themes from `StudioTheme`, `StudioFont` and `StudioTypography`
  and pass every `MaterialApp` option through.
- `ScaffoldStudio`: responsive application shell with adaptive navigation
  (bottom bar, rail, sidebar, drawer), maximum content width, safe-area and
  keyboard handling, and text-scale-aware app bar height.
- `StudioAppBar` with ten styles, `StudioAction` (badges, overflow menu) and
  `StudioAppBarSearch`.
- `StudioBottomBar` with seven styles, "More" overflow, badges, custom
  backgrounds, indicators and item builders; `StudioNavigationRail`;
  `StudioSidebar`; `StudioNavigation`; `StudioNavigationController`.
- `StudioFont` (system, bundled Roboto 2.138, custom) and `StudioTypography`.
- `StudioTheme` and the `StudioThemeData` theme extension.
- `StudioBreakpoints`, `StudioWindowSize`, `StudioResponsiveBuilder`.
- Common widgets: `CommonHeaderText`, `CommonBodyText`, `CommonLabelText`
  (with link mode), `CommonButton`, `CommonIconButton`, `CommonBadge`,
  `CommonCard`, `CommonDivider`.
