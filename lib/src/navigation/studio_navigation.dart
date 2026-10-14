// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../responsive/studio_breakpoints.dart';
import 'studio_bottom_bar_style.dart';
import 'studio_nav_item.dart';
import 'studio_navigation_controller.dart';

/// How `ScaffoldStudio` presents navigation.
enum StudioNavigationMode {
  /// Choose per window size, using [StudioNavigation.compactMode],
  /// [StudioNavigation.mediumMode] and [StudioNavigation.expandedMode].
  adaptive,

  /// A bottom navigation bar.
  bottomBar,

  /// A navigation rail at the start edge.
  rail,

  /// A permanent sidebar of labeled destinations at the start edge.
  sidebar,

  /// A modal drawer opened from the app bar menu button.
  drawer,
}

/// Builds a custom bottom bar for `ScaffoldStudio`.
///
/// [selectedIndex] is `null` when no valid destination is selected. Call
/// [onSelected] when the user picks a destination.
typedef StudioBottomBarBuilder =
    Widget Function(
      BuildContext context,
      List<StudioNavItem> items,
      int? selectedIndex,
      ValueChanged<int> onSelected,
    );

/// The navigation configuration of a `ScaffoldStudio`.
///
/// One set of [items] drives every layout, and the selection lives outside
/// the layout widgets (in your state, or in a [controller]). When the window
/// is resized and the layout switches, for example from a bottom bar to a
/// rail, the selected destination therefore stays the same.
///
/// ```dart
/// ScaffoldStudio(
///   navigation: StudioNavigation(
///     items: destinations,
///     selectedIndex: index,
///     onSelected: (i) => setState(() => index = i),
///   ),
///   body: pages[index],
/// )
/// ```
///
/// ## Page state
///
/// Switching destinations does not, by itself, preserve the state of the
/// pages you show (scroll positions, form input). To keep page state, build
/// all pages into an [IndexedStack]:
///
/// ```dart
/// body: IndexedStack(index: index, children: pages),
/// ```
///
/// or give each page a [PageStorageKey] for its scroll position.
@immutable
class StudioNavigation {
  /// Creates a navigation configuration.
  const StudioNavigation({
    required this.items,
    this.selectedIndex,
    this.onSelected,
    this.controller,
    this.mode = StudioNavigationMode.adaptive,
    this.compactMode = StudioNavigationMode.bottomBar,
    this.mediumMode = StudioNavigationMode.rail,
    this.expandedMode = StudioNavigationMode.sidebar,
    this.bottomBarStyle = StudioBottomBarStyle.material,
    this.labelBehavior,
    this.bottomBarBuilder,
    this.railLabelType = NavigationRailLabelType.all,
    this.railLeading,
    this.railTrailing,
    this.sidebarHeader,
    this.sidebarFooter,
    this.sidebarWidth = 280,
    this.hideBottomBarOnKeyboard = true,
    this.floatingActionButtonInRail = true,
    this.showDivider = true,
  }) : assert(
         selectedIndex == null || controller == null,
         'Pass either selectedIndex or controller, not both.',
       ),
       assert(
         compactMode != StudioNavigationMode.adaptive &&
             mediumMode != StudioNavigationMode.adaptive &&
             expandedMode != StudioNavigationMode.adaptive,
         'Per-size modes must be concrete, not adaptive.',
       );

  /// The destinations.
  final List<StudioNavItem> items;

  /// The selected index, when controlled by the parent.
  final int? selectedIndex;

  /// Called with the index of the destination the user selects.
  final ValueChanged<int>? onSelected;

  /// A controller that owns the selection.
  final StudioNavigationController? controller;

  /// The presentation. [StudioNavigationMode.adaptive] picks one per window
  /// size; any other value fixes it.
  final StudioNavigationMode mode;

  /// The presentation for compact widths when [mode] is adaptive.
  final StudioNavigationMode compactMode;

  /// The presentation for medium widths when [mode] is adaptive.
  final StudioNavigationMode mediumMode;

  /// The presentation for expanded widths when [mode] is adaptive.
  final StudioNavigationMode expandedMode;

  /// The style of the default bottom bar.
  final StudioBottomBarStyle bottomBarStyle;

  /// The label behavior of the default bottom bar.
  final StudioNavLabelBehavior? labelBehavior;

  /// Replaces the default bottom bar, for full control over its options.
  final StudioBottomBarBuilder? bottomBarBuilder;

  /// How rail labels are shown.
  final NavigationRailLabelType railLabelType;

  /// A widget above the rail destinations.
  final Widget? railLeading;

  /// A widget below the rail destinations.
  final Widget? railTrailing;

  /// A widget above the sidebar and drawer destinations.
  final Widget? sidebarHeader;

  /// A widget below the sidebar and drawer destinations.
  final Widget? sidebarFooter;

  /// The width of the permanent sidebar.
  final double sidebarWidth;

  /// Whether to hide the bottom bar while the on-screen keyboard is visible,
  /// leaving more room for the focused input.
  final bool hideBottomBarOnKeyboard;

  /// Whether the scaffold's floating action button moves into the top of
  /// the rail when the rail is shown, as Material 3 recommends.
  final bool floatingActionButtonInRail;

  /// Whether a divider separates a rail or sidebar from the content.
  final bool showDivider;

  /// The presentation for [size].
  StudioNavigationMode modeFor(StudioWindowSize size) {
    if (mode != StudioNavigationMode.adaptive) {
      return mode;
    }
    final StudioNavigationMode resolved = switch (size) {
      StudioWindowSize.compact => compactMode,
      StudioWindowSize.medium => mediumMode,
      StudioWindowSize.expanded => expandedMode,
    };
    // Guards release builds against an adaptive per-size value.
    return resolved == StudioNavigationMode.adaptive
        ? StudioNavigationMode.bottomBar
        : resolved;
  }
}
