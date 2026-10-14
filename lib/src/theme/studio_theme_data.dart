// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../responsive/studio_breakpoints.dart';
import '../typography/studio_typography.dart';

/// Package-specific design tokens, stored as a [ThemeExtension].
///
/// Everything that Flutter's [ThemeData] already models (colors, text theme,
/// component themes) stays in [ThemeData]. This extension only holds values
/// that Flutter has no slot for: the link color, responsive breakpoints, the
/// maximum content width and typography role overrides.
///
/// `StudioTheme.toThemeData` installs this extension automatically. If you
/// build your own [ThemeData], add it yourself:
///
/// ```dart
/// ThemeData(
///   extensions: [StudioThemeData.fallback(Brightness.light)],
/// )
/// ```
///
/// When no extension is installed, [StudioThemeData.of] returns
/// [StudioThemeData.fallback] for the ambient brightness, so every widget in
/// this package also works under a plain `MaterialApp`.
@immutable
class StudioThemeData extends ThemeExtension<StudioThemeData> {
  /// Creates package design tokens.
  const StudioThemeData({
    required this.linkColor,
    this.breakpoints = StudioBreakpoints.material,
    this.contentMaxWidth = defaultContentMaxWidth,
    this.typography = const StudioTypography(),
    this.navigationAnimationDuration = const Duration(milliseconds: 250),
    this.navigationAnimationCurve = Curves.easeOutCubic,
  });

  /// Default tokens for [brightness].
  ///
  /// The link color is a blue taken from a Material tonal palette generated
  /// for [brightness], so it keeps readable contrast on light and dark
  /// surfaces.
  factory StudioThemeData.fallback(Brightness brightness) {
    return StudioThemeData(linkColor: defaultLinkColor(brightness));
  }

  /// The default maximum width of the content area on wide layouts.
  static const double defaultContentMaxWidth = 1200;

  /// The seed used to derive the default link color.
  static const Color linkSeedColor = Color(0xFF1A73E8);

  // Generating a tonal palette is relatively expensive, so the two default
  // link colors are computed once, lazily, and then reused. They are
  // immutable values, not mutable global state.
  static final Color _lightLinkColor = _linkColorFor(Brightness.light);
  static final Color _darkLinkColor = _linkColorFor(Brightness.dark);

  static Color _linkColorFor(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: linkSeedColor,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).primary;
  }

  /// The default link color for [brightness].
  static Color defaultLinkColor(Brightness brightness) {
    return brightness == Brightness.dark ? _darkLinkColor : _lightLinkColor;
  }

  /// The color of link text.
  final Color linkColor;

  /// Width thresholds used for responsive layout decisions.
  final StudioBreakpoints breakpoints;

  /// The maximum width of the content area in `ScaffoldStudio`.
  ///
  /// Use [double.infinity] to let content stretch edge to edge.
  final double contentMaxWidth;

  /// Per-role text style overrides.
  final StudioTypography typography;

  /// The duration of navigation indicator animations.
  ///
  /// Animations are skipped when the platform requests reduced motion
  /// (see [MediaQueryData.disableAnimations]).
  final Duration navigationAnimationDuration;

  /// The curve of navigation indicator animations.
  final Curve navigationAnimationCurve;

  /// Returns the tokens from the ambient [Theme], or
  /// [StudioThemeData.fallback] when none are installed.
  static StudioThemeData of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.extension<StudioThemeData>() ??
        StudioThemeData.fallback(theme.brightness);
  }

  @override
  StudioThemeData copyWith({
    Color? linkColor,
    StudioBreakpoints? breakpoints,
    double? contentMaxWidth,
    StudioTypography? typography,
    Duration? navigationAnimationDuration,
    Curve? navigationAnimationCurve,
  }) {
    return StudioThemeData(
      linkColor: linkColor ?? this.linkColor,
      breakpoints: breakpoints ?? this.breakpoints,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
      typography: typography ?? this.typography,
      navigationAnimationDuration:
          navigationAnimationDuration ?? this.navigationAnimationDuration,
      navigationAnimationCurve:
          navigationAnimationCurve ?? this.navigationAnimationCurve,
    );
  }

  @override
  StudioThemeData lerp(covariant StudioThemeData? other, double t) {
    if (other == null) {
      return this;
    }
    // Non-numeric layout tokens switch at the midpoint; animating
    // breakpoints would make layouts jump between structures mid-animation.
    final bool useOther = t >= 0.5;
    final double? maxWidth =
        contentMaxWidth.isFinite && other.contentMaxWidth.isFinite
        ? lerpDouble(contentMaxWidth, other.contentMaxWidth, t)
        : (useOther ? other.contentMaxWidth : contentMaxWidth);
    return StudioThemeData(
      linkColor: Color.lerp(linkColor, other.linkColor, t) ?? other.linkColor,
      breakpoints: useOther ? other.breakpoints : breakpoints,
      contentMaxWidth: maxWidth ?? other.contentMaxWidth,
      typography: StudioTypography.lerp(typography, other.typography, t),
      navigationAnimationDuration: useOther
          ? other.navigationAnimationDuration
          : navigationAnimationDuration,
      navigationAnimationCurve: useOther
          ? other.navigationAnimationCurve
          : navigationAnimationCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudioThemeData &&
        other.linkColor == linkColor &&
        other.breakpoints == breakpoints &&
        other.contentMaxWidth == contentMaxWidth &&
        other.typography == typography &&
        other.navigationAnimationDuration == navigationAnimationDuration &&
        other.navigationAnimationCurve == navigationAnimationCurve;
  }

  @override
  int get hashCode => Object.hash(
    linkColor,
    breakpoints,
    contentMaxWidth,
    typography,
    navigationAnimationDuration,
    navigationAnimationCurve,
  );
}
