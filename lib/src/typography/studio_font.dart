// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// The name of this package, used to address fonts it bundles.
const String _packageName = 'scaffold_studio';

/// A font family that can be applied app-wide or to a single widget.
///
/// Use one of the predefined fonts:
///
/// * [StudioFont.system] – the platform's default Material font (Roboto on
///   Android, San Francisco on Apple platforms, and so on). Nothing is
///   bundled or loaded.
/// * [StudioFont.roboto] – Roboto 2.138, bundled with this package under the
///   Apache License 2.0. Apps do **not** need to declare it in their own
///   `pubspec.yaml`.
///
/// Or reference a font that your app (or another package) declares:
///
/// ```dart
/// const brand = StudioFont.custom('Inter', fallback: ['Roboto']);
/// ```
///
/// ## How bundled fonts are loaded
///
/// Bundled fonts are declared in this package's `pubspec.yaml`. The Flutter
/// tool adds them to every consuming app's font manifest under the family
/// name `packages/scaffold_studio/Roboto`, and the engine registers them at
/// startup. No runtime `FontLoader` is used, so there is no asynchronous
/// initialization step and no race between loading and first paint.
///
/// ## Weights
///
/// [StudioFont.roboto] bundles the weights listed in [availableWeights]
/// (300, 400, 500 and 700, plus a 400 italic). Requesting another weight,
/// such as [FontWeight.w600], renders with the nearest bundled weight chosen
/// by the platform's font matcher; it does not synthesize a true semibold.
@immutable
class StudioFont {
  /// Creates a reference to a font family declared by an app or a package.
  ///
  /// [family] is the family name used in the declaring `pubspec.yaml`. When
  /// the font is declared by a package rather than by the app, pass that
  /// package's name as [package].
  ///
  /// [availableWeights] is informational: list the weights you actually
  /// bundle so that [supportsWeight] can answer accurately. Leave it empty if
  /// unknown.
  const StudioFont.custom(
    String this.family, {
    this.package,
    this.fallback = const <String>[],
    this.availableWeights = const <FontWeight>[],
    this.label,
  });

  const StudioFont._({
    required this.family,
    required this.package,
    required this.availableWeights,
    required this.label,
  }) : fallback = const <String>[];

  /// The platform's default Material font. Nothing is bundled.
  static const StudioFont system = StudioFont._(
    family: null,
    package: null,
    availableWeights: <FontWeight>[],
    label: 'System',
  );

  /// Roboto 2.138, bundled with this package (Apache License 2.0).
  ///
  /// Bundled faces: Light (300), Regular (400), Italic (400 italic),
  /// Medium (500) and Bold (700).
  static const StudioFont roboto = StudioFont._(
    family: 'Roboto',
    package: _packageName,
    availableWeights: <FontWeight>[
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w700,
    ],
    label: 'Roboto',
  );

  /// The fonts bundled with this package, for building font pickers.
  static const List<StudioFont> bundled = <StudioFont>[roboto];

  /// The family name as declared in `pubspec.yaml`, or `null` for [system].
  final String? family;

  /// The package that declares [family], or `null` if the app declares it.
  final String? package;

  /// Families to try, in order, when a glyph is missing from [family].
  ///
  /// These are interpreted relative to [package] as well.
  final List<String> fallback;

  /// The weights for which a real font face exists.
  ///
  /// Empty when unknown, as for [system] or a custom font created without
  /// this information.
  final List<FontWeight> availableWeights;

  /// A human-readable name for UI such as font pickers. Defaults to [family].
  final String? label;

  /// Whether this is the platform default font.
  bool get isSystem => family == null;

  /// A display name for this font.
  String get displayName => label ?? family ?? 'System';

  /// The fully qualified family name that the engine registers, such as
  /// `packages/scaffold_studio/Roboto`, or `null` for [system].
  String? get resolvedFamily => _qualify(family);

  /// [fallback] with each entry qualified by [package].
  List<String>? get resolvedFallback {
    if (fallback.isEmpty) {
      return null;
    }
    return <String>[for (final String name in fallback) _qualify(name)!];
  }

  String? _qualify(String? name) {
    if (name == null) {
      return null;
    }
    return package == null ? name : 'packages/$package/$name';
  }

  /// Whether a dedicated face exists for [weight].
  ///
  /// Returns `true` when [availableWeights] is empty, because the available
  /// faces are unknown and the platform will pick the best match.
  bool supportsWeight(FontWeight weight) {
    return availableWeights.isEmpty || availableWeights.contains(weight);
  }

  /// Returns [style] with this font applied.
  ///
  /// For [system], the family is replaced with the platform default for
  /// [platform] so that a per-widget `StudioFont.system` override can undo an
  /// app-wide custom font.
  TextStyle applyTo(TextStyle style, {required TargetPlatform platform}) {
    if (isSystem) {
      final String? platformFamily = _platformDefaultFamily(platform);
      return style.copyWith(
        fontFamily: platformFamily,
        fontFamilyFallback: const <String>[],
      );
    }
    return style.copyWith(
      fontFamily: resolvedFamily,
      fontFamilyFallback: resolvedFallback ?? const <String>[],
    );
  }

  static String? _platformDefaultFamily(TargetPlatform platform) {
    // Typography knows the default Material family for each platform, for
    // example `CupertinoSystemText` on iOS and `Roboto` on Android.
    return Typography.material2021(
      platform: platform,
    ).black.bodyMedium?.fontFamily;
  }

  @override
  bool operator ==(Object other) {
    return other is StudioFont &&
        other.family == family &&
        other.package == package &&
        other.label == label &&
        listEquals(other.fallback, fallback) &&
        listEquals(other.availableWeights, availableWeights);
  }

  @override
  int get hashCode => Object.hash(
    family,
    package,
    label,
    Object.hashAll(fallback),
    Object.hashAll(availableWeights),
  );

  @override
  String toString() => 'StudioFont(${resolvedFamily ?? 'system'})';
}
