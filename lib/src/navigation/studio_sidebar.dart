// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'internal/nav_utils.dart';
import 'studio_nav_item.dart';
import 'studio_navigation_controller.dart';

/// A sidebar of labeled destinations driven by [StudioNavItem]s.
///
/// Built on Material's [NavigationDrawer], so it can be shown permanently
/// beside the content on wide layouts or as a modal drawer:
///
/// * `modal: false` (default): a flat, square-cornered panel of [width]
///   logical pixels without elevation, for use in a [Row].
/// * `modal: true`: a standard Material drawer for [Scaffold.drawer].
///
/// The sidebar scrolls when its content does not fit. [header] and [footer]
/// are placed before and after the destinations within the scrolling list.
/// An empty [items] list still shows the header and footer; an out-of-range
/// selection selects nothing.
class StudioSidebar extends StatelessWidget {
  /// Creates a sidebar.
  const StudioSidebar({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onSelected,
    this.controller,
    this.header,
    this.footer,
    this.width = 280,
    this.modal = false,
    this.backgroundColor,
    this.indicatorColor,
  }) : assert(
         selectedIndex == null || controller == null,
         'Pass either selectedIndex or controller, not both.',
       ),
       assert(width > 0, 'width must be positive.');

  /// The destinations.
  final List<StudioNavItem> items;

  /// The selected index, when controlled by the parent.
  final int? selectedIndex;

  /// Called with the index of the destination the user selects.
  final ValueChanged<int>? onSelected;

  /// A controller that owns the selection.
  final StudioNavigationController? controller;

  /// A widget above the destinations, such as a logo or account summary.
  final Widget? header;

  /// A widget below the destinations, such as settings or sign-out.
  final Widget? footer;

  /// The sidebar width.
  final double width;

  /// Whether the sidebar is presented as a modal drawer.
  final bool modal;

  /// The sidebar color.
  final Color? backgroundColor;

  /// The selected destination indicator color.
  final Color? indicatorColor;

  void _select(int index) {
    if (index < 0 || index >= items.length || !items[index].enabled) {
      return;
    }
    controller?.select(index);
    onSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final StudioNavigationController? controller = this.controller;
    if (controller == null) {
      return _buildSidebar(context, selectedIndex);
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) =>
          _buildSidebar(context, controller.value),
    );
  }

  Widget _buildSidebar(BuildContext context, int? rawIndex) {
    final DrawerThemeData drawerTheme = DrawerTheme.of(context);
    final double effectiveWidth = width.isFinite && width > 0 ? width : 280;
    final Widget drawer = NavigationDrawer(
      selectedIndex: validIndex(rawIndex, items.length),
      onDestinationSelected: _select,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      elevation: modal ? null : 0,
      children: <Widget>[
        ?header,
        for (final StudioNavItem item in items)
          NavigationDrawerDestination(
            icon: buildNavIcon(item, selected: false),
            selectedIcon: buildNavIcon(item, selected: true),
            enabled: item.enabled,
            label: Flexible(
              child: Semantics(
                label: item.semanticsLabel,
                excludeSemantics: item.semanticsLabel != null,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ?footer,
      ],
    );
    return DrawerTheme(
      data: drawerTheme.copyWith(
        width: effectiveWidth,
        shape: modal ? null : const RoundedRectangleBorder(),
        endShape: modal ? null : const RoundedRectangleBorder(),
      ),
      child: drawer,
    );
  }
}
