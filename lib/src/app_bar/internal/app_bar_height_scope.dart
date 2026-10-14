// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The largest factor by which an adaptive app bar grows with text scaling.
const double kMaxAppBarHeightScale = 1.5;

/// Returns the toolbar height for [baseHeight] under [textScaler].
///
/// The height grows with the text scale, up to [kMaxAppBarHeightScale], and
/// never drops below [minHeight].
double scaledToolbarHeight({
  required double baseHeight,
  required double minHeight,
  required TextScaler textScaler,
}) {
  final double factor = (textScaler.scale(14) / 14).clamp(
    1.0,
    kMaxAppBarHeightScale,
  );
  return math.max(minHeight, baseHeight * factor);
}

/// Tells a `StudioAppBar` the toolbar height that its `ScaffoldStudio` has
/// reserved for it.
///
/// [PreferredSizeWidget.preferredSize] has no access to the widget tree, so
/// it cannot account for text scaling. `ScaffoldStudio` computes the scaled
/// height, reserves it, and publishes it here so the app bar renders at
/// exactly that height.
class AppBarHeightScope extends InheritedWidget {
  /// Creates a scope.
  const AppBarHeightScope({
    super.key,
    required this.toolbarHeight,
    required super.child,
  });

  /// The reserved toolbar height, excluding any bottom widget.
  final double toolbarHeight;

  /// The reserved height from the nearest scope, if any.
  static double? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppBarHeightScope>()
        ?.toolbarHeight;
  }

  @override
  bool updateShouldNotify(AppBarHeightScope oldWidget) =>
      toolbarHeight != oldWidget.toolbarHeight;
}
