// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The width class of the space a layout is given.
///
/// Window sizes are derived from *available width in logical pixels*, not
/// from device models. A tablet in split-screen can therefore be [compact],
/// and a phone in landscape can be [medium].
enum StudioWindowSize {
  /// Narrow layouts, such as phones in portrait. Bottom navigation by default.
  compact,

  /// Intermediate layouts, such as large phones in landscape, small tablets,
  /// or narrow desktop windows. Navigation rail by default.
  medium,

  /// Wide layouts, such as tablets in landscape and desktop windows. Sidebar
  /// navigation by default.
  expanded;

  /// Whether this size is [compact].
  bool get isCompact => this == compact;

  /// Whether this size is [medium] or wider.
  bool get isMediumOrLarger => this != compact;

  /// Whether this size is [expanded].
  bool get isExpanded => this == expanded;
}

/// Width thresholds, in logical pixels, that map a width to a
/// [StudioWindowSize].
///
/// The defaults follow the Material 3 window size classes:
///
/// | Width            | Size                         |
/// | ---------------- | ---------------------------- |
/// | `< 600`          | [StudioWindowSize.compact]   |
/// | `600` to `< 840` | [StudioWindowSize.medium]    |
/// | `>= 840`         | [StudioWindowSize.expanded]  |
///
/// These are defaults, not assumptions about particular devices; override
/// them to suit your content.
@immutable
class StudioBreakpoints {
  /// Creates breakpoints.
  ///
  /// [medium] must be positive and [expanded] must be greater than [medium].
  /// In release builds, invalid values are sanitized by [sizeFor] rather than
  /// throwing: a non-positive or non-finite [medium] falls back to `600`, and
  /// an [expanded] value that is not greater than [medium] collapses the
  /// medium range so that every width at or above [medium] is expanded.
  const StudioBreakpoints({this.medium = 600, this.expanded = 840})
    : assert(medium > 0, 'StudioBreakpoints.medium must be positive.'),
      assert(
        expanded > medium,
        'StudioBreakpoints.expanded must be greater than medium.',
      );

  /// The default Material 3 breakpoints.
  static const StudioBreakpoints material = StudioBreakpoints();

  /// The smallest width, in logical pixels, that is [StudioWindowSize.medium].
  final double medium;

  /// The smallest width, in logical pixels, that is
  /// [StudioWindowSize.expanded].
  final double expanded;

  /// Returns the window size for [width] logical pixels.
  ///
  /// An infinite width (an unbounded layout) is treated as
  /// [StudioWindowSize.expanded]. A NaN or negative width is treated as
  /// [StudioWindowSize.compact].
  StudioWindowSize sizeFor(double width) {
    if (width.isNaN || width < 0) {
      return StudioWindowSize.compact;
    }
    final double mediumMin = medium.isFinite && medium > 0 ? medium : 600;
    final double expandedMin = expanded.isNaN || expanded < mediumMin
        ? mediumMin
        : expanded;
    if (width < mediumMin) {
      return StudioWindowSize.compact;
    }
    if (width < expandedMin) {
      return StudioWindowSize.medium;
    }
    return StudioWindowSize.expanded;
  }

  /// Returns a copy of these breakpoints with the given fields replaced.
  StudioBreakpoints copyWith({double? medium, double? expanded}) {
    return StudioBreakpoints(
      medium: medium ?? this.medium,
      expanded: expanded ?? this.expanded,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudioBreakpoints &&
        other.medium == medium &&
        other.expanded == expanded;
  }

  @override
  int get hashCode => Object.hash(medium, expanded);

  @override
  String toString() =>
      'StudioBreakpoints(medium: $medium, expanded: $expanded)';
}
