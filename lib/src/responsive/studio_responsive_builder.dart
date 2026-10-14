// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../theme/studio_theme_data.dart';
import 'studio_breakpoints.dart';

/// Builds a widget for the [StudioWindowSize] of the space it is given.
typedef StudioResponsiveWidgetBuilder =
    Widget Function(
      BuildContext context,
      StudioWindowSize size,
      BoxConstraints constraints,
    );

/// Rebuilds its child for the width class of the space it is given.
///
/// The decision uses the *parent's constraints*, not the screen size, so a
/// widget inside a sidebar, a split view or a dialog adapts to the room it
/// actually has. Use [StudioResponsiveBuilder.windowSizeOf] when you need the
/// size class of the whole window instead.
///
/// ```dart
/// StudioResponsiveBuilder(
///   builder: (context, size, constraints) => GridView.count(
///     crossAxisCount: switch (size) {
///       StudioWindowSize.compact => 1,
///       StudioWindowSize.medium => 2,
///       StudioWindowSize.expanded => 4,
///     },
///     children: cards,
///   ),
/// )
/// ```
///
/// Breakpoints default to [StudioThemeData.breakpoints].
class StudioResponsiveBuilder extends StatelessWidget {
  /// Creates a responsive builder.
  const StudioResponsiveBuilder({
    super.key,
    required this.builder,
    this.breakpoints,
  });

  /// Builds the child for the current size class.
  final StudioResponsiveWidgetBuilder builder;

  /// Overrides the theme breakpoints.
  final StudioBreakpoints? breakpoints;

  /// The size class of the whole window (the nearest [MediaQuery]).
  static StudioWindowSize windowSizeOf(
    BuildContext context, {
    StudioBreakpoints? breakpoints,
  }) {
    final StudioBreakpoints effective =
        breakpoints ?? StudioThemeData.of(context).breakpoints;
    return effective.sizeFor(MediaQuery.sizeOf(context).width);
  }

  @override
  Widget build(BuildContext context) {
    final StudioBreakpoints effective =
        breakpoints ?? StudioThemeData.of(context).breakpoints;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return builder(context, effective.sizeFor(width), constraints);
      },
    );
  }
}
