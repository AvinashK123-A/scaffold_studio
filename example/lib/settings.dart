// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

/// A named seed color offered on the Settings page.
@immutable
class SeedChoice {
  /// Creates a seed color choice.
  const SeedChoice(this.name, this.color);

  /// The display name.
  final String name;

  /// The seed color passed to [StudioTheme.seedColor].
  final Color color;
}

/// The seed colors the showcase offers.
const List<SeedChoice> seedChoices = <SeedChoice>[
  SeedChoice('Indigo', StudioTheme.defaultSeedColor),
  SeedChoice('Teal', Color(0xFF00897B)),
  SeedChoice('Orange', Color(0xFFF57C00)),
  SeedChoice('Pink', Color(0xFFD81B60)),
  SeedChoice('Green', Color(0xFF2E7D32)),
];

/// The text scale choices. `null` follows the system setting.
const List<double?> textScaleChoices = <double?>[null, 1.0, 1.5, 2.0];

/// A short label for a text scale choice.
String textScaleLabel(double? scale) =>
    scale == null ? 'System' : '${scale.toStringAsFixed(1)}×';

/// The app-level settings of the showcase.
///
/// Kept deliberately small: a plain immutable value that the root
/// [StatefulWidget] owns and replaces. No state-management package is
/// needed.
@immutable
class ShowcaseSettings {
  /// Creates settings.
  const ShowcaseSettings({
    this.themeMode = ThemeMode.system,
    this.font = StudioFont.system,
    this.seedColor = StudioTheme.defaultSeedColor,
    this.textScale,
  });

  /// Light, dark or system theme.
  final ThemeMode themeMode;

  /// The app-wide font.
  final StudioFont font;

  /// The seed of the generated color scheme.
  final Color seedColor;

  /// A text scale override, or `null` to follow the system setting.
  final double? textScale;

  /// Returns a copy with the given fields replaced.
  ShowcaseSettings copyWith({
    ThemeMode? themeMode,
    StudioFont? font,
    Color? seedColor,
  }) {
    return ShowcaseSettings(
      themeMode: themeMode ?? this.themeMode,
      font: font ?? this.font,
      seedColor: seedColor ?? this.seedColor,
      textScale: textScale,
    );
  }

  /// Returns a copy with [textScale] replaced; `null` follows the system.
  ShowcaseSettings withTextScale(double? textScale) {
    return ShowcaseSettings(
      themeMode: themeMode,
      font: font,
      seedColor: seedColor,
      textScale: textScale,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShowcaseSettings &&
        other.themeMode == themeMode &&
        other.font == font &&
        other.seedColor == seedColor &&
        other.textScale == textScale;
  }

  @override
  int get hashCode => Object.hash(themeMode, font, seedColor, textScale);
}

/// Makes the [ShowcaseSettings] and a way to change them available to every
/// route of the app.
class ShowcaseScope extends InheritedWidget {
  /// Creates a scope.
  const ShowcaseScope({
    super.key,
    required this.settings,
    required this.onChanged,
    required super.child,
  });

  /// The current settings.
  final ShowcaseSettings settings;

  /// Replaces the settings.
  final ValueChanged<ShowcaseSettings> onChanged;

  /// The nearest scope.
  static ShowcaseScope of(BuildContext context) {
    final ShowcaseScope? scope = context
        .dependOnInheritedWidgetOfExactType<ShowcaseScope>();
    assert(scope != null, 'No ShowcaseScope found in context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShowcaseScope oldWidget) =>
      settings != oldWidget.settings || onChanged != oldWidget.onChanged;
}
