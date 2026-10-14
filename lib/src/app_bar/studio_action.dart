// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../widgets/common_badge.dart';

/// An app bar action: an icon button with an optional notification badge.
///
/// ```dart
/// StudioAction(
///   icon: Icons.notifications_outlined,
///   tooltip: 'Notifications',
///   badge: '3',
///   onPressed: openNotifications,
/// )
/// ```
///
/// When a `StudioAppBar` is too narrow for all its actions, actions that have
/// a [tooltip] move into an overflow menu, where the tooltip becomes the menu
/// item text. Actions without a tooltip always stay visible.
///
/// Always provide a [tooltip]: it is also the label announced by screen
/// readers. Visible badge text is announced together with it.
class StudioAction extends StatelessWidget {
  /// Creates an app bar action.
  const StudioAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge,
    this.badgeCount,
    this.color,
  });

  /// The icon.
  final IconData icon;

  /// Called when the action is activated. `null` disables it.
  final VoidCallback? onPressed;

  /// The tooltip, semantic label and overflow menu text.
  final String? tooltip;

  /// A text badge such as `'3'` or `'New'`. An empty string shows a dot.
  final String? badge;

  /// A numeric badge. Takes precedence over [badge]. Zero hides the badge;
  /// values over 99 show as `99+`.
  final int? badgeCount;

  /// The icon color. Defaults to the app bar foreground color.
  final Color? color;

  /// The badge wrapped around [child], or `null` when there is no badge.
  CommonBadge? _badge(Widget? child) {
    if (badge == null && badgeCount == null) {
      return null;
    }
    return CommonBadge(count: badgeCount, label: badge, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = Icon(icon);
    return IconButton(
      icon: _badge(iconWidget) ?? iconWidget,
      tooltip: tooltip,
      color: color,
      onPressed: onPressed,
    );
  }
}
