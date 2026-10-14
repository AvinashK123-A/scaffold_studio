## 0.1.0

Initial pre-release. Not yet published to pub.dev.

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
