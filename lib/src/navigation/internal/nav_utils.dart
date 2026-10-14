// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../widgets/common_badge.dart';
import '../studio_nav_item.dart';

/// Returns [index] if it addresses an item in a list of [length] items, or
/// `null` when it does not.
///
/// Out-of-range indices are a normal, recoverable situation (for example,
/// when the item list shrinks before the selection is updated), so they
/// result in no selection rather than an exception.
int? validIndex(int? index, int length) {
  if (index == null || index < 0 || index >= length) {
    return null;
  }
  return index;
}

/// Returns [duration], or [Duration.zero] when the platform asks for reduced
/// motion or the duration is negative.
Duration effectiveDuration(BuildContext context, Duration duration) {
  if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
    return Duration.zero;
  }
  return duration.isNegative ? Duration.zero : duration;
}

/// Builds the icon of [item] for its [selected] state, with its badge.
Widget buildNavIcon(
  StudioNavItem item, {
  required bool selected,
  double? size,
  Color? color,
}) {
  // Exactly one of `icon` and `iconWidget` is set by the StudioNavItem
  // constructors; the final fallback only guards against future changes.
  final Widget? custom = selected
      ? (item.selectedIconWidget ?? item.iconWidget)
      : item.iconWidget;
  final IconData? data = selected
      ? (item.selectedIcon ?? item.icon)
      : item.icon;
  Widget icon =
      custom ??
      (data == null
          ? const SizedBox.square(dimension: 24)
          : Icon(data, size: size, color: color));
  if (item.badge != null || item.badgeCount != null) {
    icon = CommonBadge(count: item.badgeCount, label: item.badge, child: icon);
  }
  return icon;
}

/// The text of [item]'s badge as announced to screen readers, or `null`.
String? badgeSemantics(StudioNavItem item) {
  if (item.badge == null && item.badgeCount == null) {
    return null;
  }
  final CommonBadge badge = CommonBadge(
    count: item.badgeCount,
    label: item.badge,
  );
  return badge.effectiveVisible ? badge.displayText : null;
}

/// The accessible label for [item], including its badge.
String navSemanticsLabel(StudioNavItem item) {
  final String label = item.semanticsLabel ?? item.label;
  final String? badge = badgeSemantics(item);
  return badge == null ? label : '$label, $badge';
}
