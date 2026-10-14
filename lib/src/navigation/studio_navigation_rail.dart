// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'internal/nav_utils.dart';
import 'studio_nav_item.dart';
import 'studio_navigation_controller.dart';

/// A navigation rail driven by [StudioNavItem]s.
///
/// A thin layer over Material's [NavigationRail] that adds badges, tooltips
/// for icon-only rails, safe handling of invalid indices, and the same
/// controlled or controller-managed state model as `StudioBottomBar`.
///
/// The rail scrolls when its destinations do not fit vertically, for example
/// on a phone in landscape. An empty [items] list renders nothing, and an
/// out-of-range selection selects nothing.
class StudioNavigationRail extends StatelessWidget {
  /// Creates a navigation rail.
  const StudioNavigationRail({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onSelected,
    this.controller,
    this.labelType = NavigationRailLabelType.all,
    this.extended = false,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.groupAlignment = -1,
    this.minWidth,
    this.minExtendedWidth,
  }) : assert(
         selectedIndex == null || controller == null,
         'Pass either selectedIndex or controller, not both.',
       );

  /// The destinations.
  final List<StudioNavItem> items;

  /// The selected index, when controlled by the parent.
  final int? selectedIndex;

  /// Called with the index of the destination the user selects.
  final ValueChanged<int>? onSelected;

  /// A controller that owns the selection.
  final StudioNavigationController? controller;

  /// How labels are shown. Ignored when [extended] is `true`.
  final NavigationRailLabelType labelType;

  /// Whether the rail shows labels beside the icons.
  final bool extended;

  /// A widget above the destinations, such as a floating action button.
  final Widget? leading;

  /// A widget below the destinations.
  final Widget? trailing;

  /// The rail color.
  final Color? backgroundColor;

  /// The vertical alignment of the destinations, from -1 (top) to 1
  /// (bottom).
  final double groupAlignment;

  /// The width of the collapsed rail.
  final double? minWidth;

  /// The width of the extended rail.
  final double? minExtendedWidth;

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
      return _buildRail(context, selectedIndex);
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) =>
          _buildRail(context, controller.value),
    );
  }

  Widget _buildRail(BuildContext context, int? rawIndex) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool iconOnly =
        !extended && labelType == NavigationRailLabelType.none;
    Widget withTooltip(StudioNavItem item, Widget icon) {
      if (!iconOnly && item.tooltip == null) {
        return icon;
      }
      return Tooltip(
        message: item.tooltip ?? item.label,
        excludeFromSemantics: true,
        child: icon,
      );
    }

    return NavigationRail(
      selectedIndex: validIndex(rawIndex, items.length),
      onDestinationSelected: _select,
      labelType: extended ? NavigationRailLabelType.none : labelType,
      extended: extended,
      leading: leading,
      trailing: trailing,
      backgroundColor: backgroundColor,
      groupAlignment: groupAlignment,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      scrollable: true,
      destinations: <NavigationRailDestination>[
        for (final StudioNavItem item in items)
          NavigationRailDestination(
            icon: withTooltip(item, buildNavIcon(item, selected: false)),
            selectedIcon: withTooltip(item, buildNavIcon(item, selected: true)),
            disabled: !item.enabled,
            label: Semantics(
              label: item.semanticsLabel,
              excludeSemantics: item.semanticsLabel != null,
              child: extended
                  ? Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  // A collapsed rail is narrow; let labels wrap to two lines
                  // and then ellipsize instead of overflowing.
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 72),
                      child: Text(
                        item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
