// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../studio_app_bar_style.dart';

/// The defaults a [StudioAppBarStyle] contributes. Explicit `StudioAppBar`
/// arguments always win over these.
///
/// Keeping all style differences in this one table is what lets a single
/// layout implementation serve every style.
@immutable
class AppBarStyleSpec {
  /// Creates a style spec.
  const AppBarStyleSpec({
    required this.height,
    required this.centerTitle,
    required this.elevation,
    required this.scrolledUnderElevation,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.bottomRadius = 0,
    this.compactTitle = false,
    this.inlineLeading = false,
    this.profileLeads = false,
    this.imageScrim,
  });

  /// Resolves the defaults for [style] against [scheme].
  factory AppBarStyleSpec.resolve(StudioAppBarStyle style, ColorScheme scheme) {
    switch (style) {
      case StudioAppBarStyle.standard:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
        );
      case StudioAppBarStyle.centered:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
        );
      case StudioAppBarStyle.minimal:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          compactTitle: true,
        );
      case StudioAppBarStyle.transparent:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: scheme.onSurface,
        );
      case StudioAppBarStyle.gradient:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: scheme.onPrimary,
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: <Color>[scheme.primary, scheme.tertiary],
          ),
        );
      case StudioAppBarStyle.image:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          // Shown while the image loads (or if it fails): a neutral dark
          // tone that keeps the white foreground legible in both themes.
          backgroundColor: const Color(0xFF2B2B2B),
          foregroundColor: Colors.white,
          imageScrim: Colors.black.withValues(alpha: 0.4),
        );
      case StudioAppBarStyle.rounded:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          bottomRadius: 24,
        );
      case StudioAppBarStyle.search:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
        );
      case StudioAppBarStyle.profile:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          profileLeads: true,
        );
      case StudioAppBarStyle.flexible:
        return AppBarStyleSpec(
          height: defaultHeight(style),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          inlineLeading: true,
        );
    }
  }

  /// The default toolbar height for [style], before text scaling.
  static double defaultHeight(StudioAppBarStyle style) {
    return switch (style) {
      StudioAppBarStyle.minimal => 56,
      StudioAppBarStyle.profile => 72,
      _ => 64,
    };
  }

  /// The toolbar height.
  final double height;

  /// Whether the title is centered.
  final bool centerTitle;

  /// The resting elevation.
  final double elevation;

  /// The elevation when content scrolls underneath.
  final double scrolledUnderElevation;

  /// The background color, or `null` when [gradient] paints the background.
  final Color? backgroundColor;

  /// The color of icons and text.
  final Color? foregroundColor;

  /// A background gradient.
  final Gradient? gradient;

  /// The radius of the bottom corners.
  final double bottomRadius;

  /// Whether to use the smaller [TextTheme.titleMedium] for the title.
  final bool compactTitle;

  /// Whether the leading widget is laid out inline with the title instead of
  /// in a fixed-width slot.
  final bool inlineLeading;

  /// Whether the profile avatar is placed in the leading slot.
  final bool profileLeads;

  /// The scrim drawn over a background image.
  final Color? imageScrim;
}
