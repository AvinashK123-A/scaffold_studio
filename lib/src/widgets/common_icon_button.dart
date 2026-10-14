// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'common_badge.dart';

/// The visual style of a [CommonIconButton], matching the Material 3 icon
/// button types.
enum CommonIconButtonVariant {
  /// No container. [IconButton].
  standard,

  /// A filled container. [IconButton.filled].
  filled,

  /// A tonal container. [IconButton.filledTonal].
  tonal,

  /// An outlined container. [IconButton.outlined].
  outlined,
}

/// An icon-only button with an accessible label and an optional badge.
///
/// Icon-only controls must be described for screen readers, so either
/// [tooltip] or [semanticsLabel] is required; omitting both fails an
/// assertion in debug builds. The tooltip, when present, also serves as the
/// semantic label.
///
/// ```dart
/// CommonIconButton(
///   icon: Icons.notifications_outlined,
///   tooltip: 'Notifications',
///   badgeCount: 3,
///   onPressed: openNotifications,
/// )
/// ```
///
/// Built on [IconButton], so it has a 48×48 minimum touch target, focus and
/// hover states and keyboard activation.
class CommonIconButton extends StatelessWidget {
  /// Creates an icon button.
  const CommonIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.selectedIcon,
    this.isSelected,
    this.tooltip,
    this.semanticsLabel,
    this.variant = CommonIconButtonVariant.standard,
    this.size,
    this.color,
    this.badge,
    this.badgeCount,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
         tooltip != null || semanticsLabel != null,
         'CommonIconButton needs a tooltip or a semanticsLabel so that screen '
         'readers can describe it.',
       );

  /// The icon.
  final IconData icon;

  /// The icon shown when [isSelected] is `true`.
  final IconData? selectedIcon;

  /// Whether the button is in a selected (toggled on) state. `null` means the
  /// button is not a toggle.
  final bool? isSelected;

  /// Called when the button is activated. `null` disables the button.
  final VoidCallback? onPressed;

  /// Text shown on long press or hover, and used as the semantic label.
  final String? tooltip;

  /// A label for screen readers. Used when [tooltip] is `null`.
  final String? semanticsLabel;

  /// The Material 3 icon button type.
  final CommonIconButtonVariant variant;

  /// The icon size in logical pixels.
  final double? size;

  /// The icon color.
  final Color? color;

  /// A text badge. An empty string shows a small dot.
  final String? badge;

  /// A numeric badge. Takes precedence over [badge]; zero hides the badge.
  final int? badgeCount;

  /// An optional focus node.
  final FocusNode? focusNode;

  /// Whether to request focus when first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // Without a tooltip, the semantic label is attached to the icon so that
    // it merges into the button's own semantics node.
    Widget iconWidget = Icon(
      icon,
      semanticLabel: tooltip == null ? semanticsLabel : null,
    );
    if (badge != null || badgeCount != null) {
      iconWidget = CommonBadge(
        count: badgeCount,
        label: badge,
        child: iconWidget,
      );
    }
    final Widget? selected = selectedIcon == null ? null : Icon(selectedIcon);

    return switch (variant) {
      CommonIconButtonVariant.standard => IconButton(
        icon: iconWidget,
        selectedIcon: selected,
        isSelected: isSelected,
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: size,
        color: color,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
      CommonIconButtonVariant.filled => IconButton.filled(
        icon: iconWidget,
        selectedIcon: selected,
        isSelected: isSelected,
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: size,
        color: color,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
      CommonIconButtonVariant.tonal => IconButton.filledTonal(
        icon: iconWidget,
        selectedIcon: selected,
        isSelected: isSelected,
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: size,
        color: color,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
      CommonIconButtonVariant.outlined => IconButton.outlined(
        icon: iconWidget,
        selectedIcon: selected,
        isSelected: isSelected,
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: size,
        color: color,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    };
  }
}
