// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../responsive/studio_breakpoints.dart';
import '../typography/studio_font.dart';
import '../typography/studio_typography.dart';
import 'studio_theme_data.dart';

/// A small, declarative theme configuration that produces a Material 3
/// [ThemeData].
///
/// `StudioTheme` is not a separate theme engine. [toThemeData] produces an
/// ordinary [ThemeData] with a [ColorScheme], component themes and a
/// [StudioThemeData] extension, so standard Flutter widgets and
/// `Theme.of(context)` behave exactly as usual.
///
/// ```dart
/// ScaffoldStudioApp(
///   theme: StudioTheme.light,
///   darkTheme: StudioTheme.dark,
///   fontFamily: StudioFont.roboto,
///   home: const HomePage(),
/// )
/// ```
///
/// Customize with the constructor or [copyWith]:
///
/// ```dart
/// final brand = StudioTheme.light.copyWith(seedColor: Colors.teal);
/// ```
///
/// Interaction states such as disabled, hovered, focused and pressed are
/// derived by the Material components from the [ColorScheme]; this class
/// does not override them. For anything not covered here, use
/// `ScaffoldStudioApp.themeOverride` or edit the result of [toThemeData]
/// with [ThemeData.copyWith].
@immutable
class StudioTheme {
  /// Creates a theme configuration.
  ///
  /// If [colorScheme] is provided, [seedColor], [schemeVariant] and
  /// [brightness] are ignored for color generation, and the scheme's own
  /// brightness is used.
  const StudioTheme({
    this.brightness = Brightness.light,
    this.seedColor = defaultSeedColor,
    this.schemeVariant = DynamicSchemeVariant.tonalSpot,
    this.colorScheme,
    this.linkColor,
    this.breakpoints = StudioBreakpoints.material,
    this.contentMaxWidth = StudioThemeData.defaultContentMaxWidth,
    this.cornerRadius = 16,
    this.scaffoldBackgroundColor,
    this.navigationAnimationDuration = const Duration(milliseconds: 250),
  });

  /// The default seed color, an indigo-blue.
  static const Color defaultSeedColor = Color(0xFF3F51B5);

  /// The default light theme.
  static const StudioTheme light = StudioTheme();

  /// The default dark theme.
  static const StudioTheme dark = StudioTheme(brightness: Brightness.dark);

  /// Whether to generate a light or dark scheme from [seedColor].
  final Brightness brightness;

  /// The color from which the Material 3 tonal palettes are generated.
  final Color seedColor;

  /// How [seedColor] is turned into a scheme.
  ///
  /// [DynamicSchemeVariant.fidelity] keeps colors closer to the seed.
  final DynamicSchemeVariant schemeVariant;

  /// An explicit color scheme that replaces seed-based generation.
  final ColorScheme? colorScheme;

  /// The color for link text. Defaults to a blue from a tonal palette that
  /// matches the theme brightness (see [StudioThemeData.defaultLinkColor]).
  final Color? linkColor;

  /// Width thresholds for responsive layout decisions.
  final StudioBreakpoints breakpoints;

  /// The maximum width of the content area in `ScaffoldStudio`. Use
  /// [double.infinity] to disable the constraint.
  final double contentMaxWidth;

  /// The corner radius of cards (via [ThemeData.cardTheme]).
  final double cornerRadius;

  /// The scaffold background. Defaults to [ColorScheme.surface].
  final Color? scaffoldBackgroundColor;

  /// The duration of navigation indicator animations.
  final Duration navigationAnimationDuration;

  /// The brightness that results from this configuration.
  Brightness get effectiveBrightness => colorScheme?.brightness ?? brightness;

  /// Builds the color scheme for this configuration.
  ColorScheme buildColorScheme() {
    return colorScheme ??
        ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: brightness,
          dynamicSchemeVariant: schemeVariant,
        );
  }

  /// Builds a Material 3 [ThemeData] for this configuration.
  ///
  /// [font] becomes the default font of [ThemeData.textTheme] and
  /// [ThemeData.primaryTextTheme]. [typography] is stored in the
  /// [StudioThemeData] extension and used by the `Common*Text` widgets.
  ThemeData toThemeData({
    StudioFont font = StudioFont.system,
    StudioTypography typography = const StudioTypography(),
  }) {
    final ColorScheme scheme = buildColorScheme();
    final double radius = cornerRadius.isFinite && cornerRadius >= 0
        ? cornerRadius
        : 16;
    final StudioThemeData tokens = StudioThemeData(
      linkColor:
          linkColor ?? StudioThemeData.defaultLinkColor(scheme.brightness),
      breakpoints: breakpoints,
      contentMaxWidth: contentMaxWidth,
      typography: typography,
      navigationAnimationDuration: navigationAnimationDuration,
    );

    return ThemeData(
      colorScheme: scheme,
      // The family is passed fully qualified (for example
      // `packages/scaffold_studio/Roboto`) instead of using the `package`
      // parameter: with a null family, `package` would also be applied to the
      // platform default family and break it.
      fontFamily: font.resolvedFamily,
      fontFamilyFallback: font.resolvedFallback,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? scheme.surface,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 2,
        shadowColor: scheme.shadow,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.error,
        textColor: scheme.onError,
      ),
      extensions: <ThemeExtension<StudioThemeData>>[tokens],
    );
  }

  /// Returns a copy with the given fields replaced.
  StudioTheme copyWith({
    Brightness? brightness,
    Color? seedColor,
    DynamicSchemeVariant? schemeVariant,
    ColorScheme? colorScheme,
    Color? linkColor,
    StudioBreakpoints? breakpoints,
    double? contentMaxWidth,
    double? cornerRadius,
    Color? scaffoldBackgroundColor,
    Duration? navigationAnimationDuration,
  }) {
    return StudioTheme(
      brightness: brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
      schemeVariant: schemeVariant ?? this.schemeVariant,
      colorScheme: colorScheme ?? this.colorScheme,
      linkColor: linkColor ?? this.linkColor,
      breakpoints: breakpoints ?? this.breakpoints,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      navigationAnimationDuration:
          navigationAnimationDuration ?? this.navigationAnimationDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudioTheme &&
        other.brightness == brightness &&
        other.seedColor == seedColor &&
        other.schemeVariant == schemeVariant &&
        other.colorScheme == colorScheme &&
        other.linkColor == linkColor &&
        other.breakpoints == breakpoints &&
        other.contentMaxWidth == contentMaxWidth &&
        other.cornerRadius == cornerRadius &&
        other.scaffoldBackgroundColor == scaffoldBackgroundColor &&
        other.navigationAnimationDuration == navigationAnimationDuration;
  }

  @override
  int get hashCode => Object.hash(
    brightness,
    seedColor,
    schemeVariant,
    colorScheme,
    linkColor,
    breakpoints,
    contentMaxWidth,
    cornerRadius,
    scaffoldBackgroundColor,
    navigationAnimationDuration,
  );
}
