// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../theme/studio_theme.dart';
import '../typography/studio_font.dart';
import '../typography/studio_typography.dart';

/// Adjusts a generated [ThemeData] before it is used.
typedef StudioThemeOverride = ThemeData Function(ThemeData theme);

/// A [MaterialApp] that is themed from [StudioTheme], [StudioFont] and
/// [StudioTypography].
///
/// ```dart
/// void main() {
///   runApp(
///     const ScaffoldStudioApp(
///       fontFamily: StudioFont.roboto,
///       theme: StudioTheme.light,
///       home: HomePage(),
///     ),
///   );
/// }
/// ```
///
/// Every [MaterialApp] option is available and passed through unchanged:
/// routes, navigator keys and observers, localization delegates and
/// supported locales, shortcuts and actions, scroll behavior, restoration
/// and debug flags. Use [ScaffoldStudioApp.router] for `Router`-based
/// navigation (for example with `go_router`).
///
/// ## Theme
///
/// [theme], [darkTheme], [highContrastTheme] and [highContrastDarkTheme] are
/// converted with [StudioTheme.toThemeData] using [fontFamily] and
/// [typography]. When [darkTheme] is `null` and [theme] is seed-based, a dark
/// variant of [theme] is used, so a custom seed color carries over to dark
/// mode. Use [themeOverride] to change anything else on the final
/// [ThemeData].
///
/// The generated themes are cached and only rebuilt when one of these inputs
/// changes. [themeOverride] is compared by identity; pass a top-level or
/// static function (not a new closure on every build) to keep the cache
/// effective.
///
/// ## Fonts
///
/// [fontFamily] becomes the default font of the theme's text themes, so it
/// applies to [Text] and to Material widgets that take their style from the
/// theme. It does not override an explicit `fontFamily` in a [TextStyle], nor
/// third-party widgets that set their own font. Bundled fonts are registered
/// by the engine at startup, so there is no loading step and no flash of
/// fallback text on any platform.
class ScaffoldStudioApp extends StatefulWidget {
  /// Creates an app that uses a [Navigator] (like [MaterialApp]).
  const ScaffoldStudioApp({
    super.key,
    this.theme = StudioTheme.light,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.fontFamily = StudioFont.system,
    this.typography = const StudioTypography(),
    this.themeOverride,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.onNavigationNotification,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.themeAnimationDuration = kThemeAnimationDuration,
    this.themeAnimationCurve = Curves.linear,
    this.themeAnimationStyle,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
  }) : routerConfig = null,
       routeInformationProvider = null,
       routeInformationParser = null,
       routerDelegate = null,
       backButtonDispatcher = null,
       _usesRouter = false;

  /// Creates an app that uses a [Router] (like [MaterialApp.router]).
  ///
  /// Provide either [routerConfig], or [routerDelegate] with the optional
  /// router arguments.
  const ScaffoldStudioApp.router({
    super.key,
    this.theme = StudioTheme.light,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.fontFamily = StudioFont.system,
    this.typography = const StudioTypography(),
    this.themeOverride,
    this.scaffoldMessengerKey,
    this.routerConfig,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.onNavigationNotification,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.themeAnimationDuration = kThemeAnimationDuration,
    this.themeAnimationCurve = Curves.linear,
    this.themeAnimationStyle,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
  }) : assert(
         routerDelegate != null || routerConfig != null,
         'ScaffoldStudioApp.router requires a routerConfig or a '
         'routerDelegate.',
       ),
       navigatorKey = null,
       home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       navigatorObservers = const <NavigatorObserver>[],
       _usesRouter = true;

  final bool _usesRouter;

  /// The light theme configuration.
  final StudioTheme theme;

  /// The dark theme configuration. See the class documentation for the
  /// default.
  final StudioTheme? darkTheme;

  /// The theme used when the platform requests high contrast in light mode.
  final StudioTheme? highContrastTheme;

  /// The theme used when the platform requests high contrast in dark mode.
  final StudioTheme? highContrastDarkTheme;

  /// Which theme to use. See [MaterialApp.themeMode].
  final ThemeMode themeMode;

  /// The app-wide default font.
  final StudioFont fontFamily;

  /// Per-role text style overrides for the `Common*Text` widgets.
  final StudioTypography typography;

  /// A final adjustment applied to every generated [ThemeData].
  final StudioThemeOverride? themeOverride;

  /// See [MaterialApp.navigatorKey].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// See [MaterialApp.scaffoldMessengerKey].
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// See [MaterialApp.home].
  final Widget? home;

  /// See [MaterialApp.routes].
  final Map<String, WidgetBuilder> routes;

  /// See [MaterialApp.initialRoute].
  final String? initialRoute;

  /// See [MaterialApp.onGenerateRoute].
  final RouteFactory? onGenerateRoute;

  /// See [MaterialApp.onGenerateInitialRoutes].
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// See [MaterialApp.onUnknownRoute].
  final RouteFactory? onUnknownRoute;

  /// See [MaterialApp.onNavigationNotification].
  final NotificationListenerCallback<NavigationNotification>?
  onNavigationNotification;

  /// See [MaterialApp.navigatorObservers].
  final List<NavigatorObserver> navigatorObservers;

  /// See [MaterialApp.routerConfig].
  final RouterConfig<Object>? routerConfig;

  /// See [MaterialApp.routeInformationProvider].
  final RouteInformationProvider? routeInformationProvider;

  /// See [MaterialApp.routeInformationParser].
  final RouteInformationParser<Object>? routeInformationParser;

  /// See [MaterialApp.routerDelegate].
  final RouterDelegate<Object>? routerDelegate;

  /// See [MaterialApp.backButtonDispatcher].
  final BackButtonDispatcher? backButtonDispatcher;

  /// See [MaterialApp.builder].
  final TransitionBuilder? builder;

  /// See [MaterialApp.title].
  final String title;

  /// See [MaterialApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// See [MaterialApp.color].
  final Color? color;

  /// See [MaterialApp.themeAnimationDuration].
  final Duration themeAnimationDuration;

  /// See [MaterialApp.themeAnimationCurve].
  final Curve themeAnimationCurve;

  /// See [MaterialApp.themeAnimationStyle].
  final AnimationStyle? themeAnimationStyle;

  /// See [MaterialApp.locale].
  final Locale? locale;

  /// See [MaterialApp.localizationsDelegates].
  final Iterable<LocalizationsDelegate<Object?>>? localizationsDelegates;

  /// See [MaterialApp.localeListResolutionCallback].
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// See [MaterialApp.localeResolutionCallback].
  final LocaleResolutionCallback? localeResolutionCallback;

  /// See [MaterialApp.supportedLocales].
  final Iterable<Locale> supportedLocales;

  /// See [MaterialApp.debugShowMaterialGrid].
  final bool debugShowMaterialGrid;

  /// See [MaterialApp.showPerformanceOverlay].
  final bool showPerformanceOverlay;

  /// See [MaterialApp.checkerboardRasterCacheImages].
  final bool checkerboardRasterCacheImages;

  /// See [MaterialApp.checkerboardOffscreenLayers].
  final bool checkerboardOffscreenLayers;

  /// See [MaterialApp.showSemanticsDebugger].
  final bool showSemanticsDebugger;

  /// See [MaterialApp.debugShowCheckedModeBanner].
  final bool debugShowCheckedModeBanner;

  /// See [MaterialApp.shortcuts].
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// See [MaterialApp.actions].
  final Map<Type, Action<Intent>>? actions;

  /// See [MaterialApp.restorationScopeId].
  final String? restorationScopeId;

  /// See [MaterialApp.scrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// The dark configuration that is actually used: [darkTheme], or a dark
  /// variant of a seed-based [theme].
  StudioTheme? get effectiveDarkTheme {
    final StudioTheme? dark = darkTheme;
    if (dark != null) {
      return dark;
    }
    if (theme.colorScheme != null) {
      return null;
    }
    return theme.copyWith(brightness: Brightness.dark);
  }

  @override
  State<ScaffoldStudioApp> createState() => _ScaffoldStudioAppState();
}

class _ScaffoldStudioAppState extends State<ScaffoldStudioApp> {
  late ThemeData _light;
  ThemeData? _dark;
  ThemeData? _highContrastLight;
  ThemeData? _highContrastDark;

  @override
  void initState() {
    super.initState();
    _buildThemes();
  }

  @override
  void didUpdateWidget(ScaffoldStudioApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme ||
        widget.effectiveDarkTheme != oldWidget.effectiveDarkTheme ||
        widget.highContrastTheme != oldWidget.highContrastTheme ||
        widget.highContrastDarkTheme != oldWidget.highContrastDarkTheme ||
        widget.fontFamily != oldWidget.fontFamily ||
        widget.typography != oldWidget.typography ||
        widget.themeOverride != oldWidget.themeOverride) {
      _buildThemes();
    }
  }

  void _buildThemes() {
    _light = _convert(widget.theme);
    _dark = _convertOptional(widget.effectiveDarkTheme);
    _highContrastLight = _convertOptional(widget.highContrastTheme);
    _highContrastDark = _convertOptional(widget.highContrastDarkTheme);
  }

  ThemeData? _convertOptional(StudioTheme? config) =>
      config == null ? null : _convert(config);

  ThemeData _convert(StudioTheme config) {
    final ThemeData data = config.toThemeData(
      font: widget.fontFamily,
      typography: widget.typography,
    );
    return widget.themeOverride?.call(data) ?? data;
  }

  @override
  Widget build(BuildContext context) {
    final ScaffoldStudioApp app = widget;
    if (app._usesRouter) {
      return MaterialApp.router(
        scaffoldMessengerKey: app.scaffoldMessengerKey,
        routerConfig: app.routerConfig,
        routeInformationProvider: app.routeInformationProvider,
        routeInformationParser: app.routeInformationParser,
        routerDelegate: app.routerDelegate,
        backButtonDispatcher: app.backButtonDispatcher,
        onNavigationNotification: app.onNavigationNotification,
        builder: app.builder,
        title: app.title,
        onGenerateTitle: app.onGenerateTitle,
        color: app.color,
        theme: _light,
        darkTheme: _dark,
        highContrastTheme: _highContrastLight,
        highContrastDarkTheme: _highContrastDark,
        themeMode: app.themeMode,
        themeAnimationDuration: app.themeAnimationDuration,
        themeAnimationCurve: app.themeAnimationCurve,
        themeAnimationStyle: app.themeAnimationStyle,
        locale: app.locale,
        localizationsDelegates: app.localizationsDelegates,
        localeListResolutionCallback: app.localeListResolutionCallback,
        localeResolutionCallback: app.localeResolutionCallback,
        supportedLocales: app.supportedLocales,
        debugShowMaterialGrid: app.debugShowMaterialGrid,
        showPerformanceOverlay: app.showPerformanceOverlay,
        checkerboardRasterCacheImages: app.checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: app.checkerboardOffscreenLayers,
        showSemanticsDebugger: app.showSemanticsDebugger,
        debugShowCheckedModeBanner: app.debugShowCheckedModeBanner,
        shortcuts: app.shortcuts,
        actions: app.actions,
        restorationScopeId: app.restorationScopeId,
        scrollBehavior: app.scrollBehavior,
      );
    }
    return MaterialApp(
      navigatorKey: app.navigatorKey,
      scaffoldMessengerKey: app.scaffoldMessengerKey,
      home: app.home,
      routes: app.routes,
      initialRoute: app.initialRoute,
      onGenerateRoute: app.onGenerateRoute,
      onGenerateInitialRoutes: app.onGenerateInitialRoutes,
      onUnknownRoute: app.onUnknownRoute,
      onNavigationNotification: app.onNavigationNotification,
      navigatorObservers: app.navigatorObservers,
      builder: app.builder,
      title: app.title,
      onGenerateTitle: app.onGenerateTitle,
      color: app.color,
      theme: _light,
      darkTheme: _dark,
      highContrastTheme: _highContrastLight,
      highContrastDarkTheme: _highContrastDark,
      themeMode: app.themeMode,
      themeAnimationDuration: app.themeAnimationDuration,
      themeAnimationCurve: app.themeAnimationCurve,
      themeAnimationStyle: app.themeAnimationStyle,
      locale: app.locale,
      localizationsDelegates: app.localizationsDelegates,
      localeListResolutionCallback: app.localeListResolutionCallback,
      localeResolutionCallback: app.localeResolutionCallback,
      supportedLocales: app.supportedLocales,
      debugShowMaterialGrid: app.debugShowMaterialGrid,
      showPerformanceOverlay: app.showPerformanceOverlay,
      checkerboardRasterCacheImages: app.checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: app.checkerboardOffscreenLayers,
      showSemanticsDebugger: app.showSemanticsDebugger,
      debugShowCheckedModeBanner: app.debugShowCheckedModeBanner,
      shortcuts: app.shortcuts,
      actions: app.actions,
      restorationScopeId: app.restorationScopeId,
      scrollBehavior: app.scrollBehavior,
    );
  }
}
