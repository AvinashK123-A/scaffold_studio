// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A navigation destination shared by the bottom bar, rail, sidebar and
/// drawer.
///
/// The same list of items drives every navigation layout, which is how the
/// selected destination is preserved when `ScaffoldStudio` switches between
/// layouts as the window is resized.
///
/// ```dart
/// const StudioNavItem(
///   icon: Icons.inbox_outlined,
///   selectedIcon: Icons.inbox,
///   label: 'Inbox',
///   badgeCount: 4,
/// )
/// ```
///
/// Use [StudioNavItem.custom] to supply arbitrary icon widgets, such as an
/// avatar or an animated icon.
@immutable
class StudioNavItem {
  /// Creates a destination with icon glyphs.
  const StudioNavItem({
    required IconData this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.badgeCount,
    this.tooltip,
    this.semanticsLabel,
    this.enabled = true,
  }) : iconWidget = null,
       selectedIconWidget = null;

  /// Creates a destination with custom icon widgets.
  const StudioNavItem.custom({
    required Widget icon,
    required this.label,
    Widget? selectedIcon,
    this.badge,
    this.badgeCount,
    this.tooltip,
    this.semanticsLabel,
    this.enabled = true,
  }) : iconWidget = icon,
       selectedIconWidget = selectedIcon,
       icon = null,
       selectedIcon = null;

  /// The icon glyph, when created with the default constructor.
  final IconData? icon;

  /// The icon glyph used while selected. Defaults to [icon].
  final IconData? selectedIcon;

  /// The icon widget, when created with [StudioNavItem.custom].
  final Widget? iconWidget;

  /// The icon widget used while selected, when created with
  /// [StudioNavItem.custom]. Defaults to [iconWidget].
  final Widget? selectedIconWidget;

  /// The destination label. Always required: it is the accessible name even
  /// when the label is visually hidden.
  final String label;

  /// A text badge. An empty string shows a small dot.
  final String? badge;

  /// A numeric badge. Takes precedence over [badge]. Zero hides it.
  final int? badgeCount;

  /// A tooltip. Defaults to [label] wherever the label is visually hidden.
  final String? tooltip;

  /// A label for screen readers that replaces [label].
  final String? semanticsLabel;

  /// Whether the destination can be selected.
  final bool enabled;

  @override
  bool operator ==(Object other) {
    return other is StudioNavItem &&
        other.icon == icon &&
        other.selectedIcon == selectedIcon &&
        other.iconWidget == iconWidget &&
        other.selectedIconWidget == selectedIconWidget &&
        other.label == label &&
        other.badge == badge &&
        other.badgeCount == badgeCount &&
        other.tooltip == tooltip &&
        other.semanticsLabel == semanticsLabel &&
        other.enabled == enabled;
  }

  @override
  int get hashCode => Object.hash(
    icon,
    selectedIcon,
    iconWidget,
    selectedIconWidget,
    label,
    badge,
    badgeCount,
    tooltip,
    semanticsLabel,
    enabled,
  );

  @override
  String toString() => 'StudioNavItem($label)';
}
