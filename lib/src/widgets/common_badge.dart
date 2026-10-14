// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A notification badge, built on Material's [Badge].
///
/// The badge content is chosen from, in order:
///
/// 1. [count], formatted with [maxCount] (for example `99+`). A count of zero
///    or less hides the badge unless [showZero] is `true`.
/// 2. [label], shown as is. An empty string shows a small dot.
/// 3. Neither: a small dot.
///
/// ```dart
/// CommonBadge(
///   count: unread,
///   semanticsLabel: '$unread unread messages',
///   child: const Icon(Icons.mail_outline),
/// )
/// ```
///
/// Screen readers do not see badge text by default because it is painted
/// over another widget. Provide [semanticsLabel] to describe the badge; it is
/// announced as part of the child's semantics.
class CommonBadge extends StatelessWidget {
  /// Creates a badge.
  const CommonBadge({
    super.key,
    this.child,
    this.count,
    this.label,
    this.maxCount = 99,
    this.showZero = false,
    this.isVisible = true,
    this.backgroundColor,
    this.textColor,
    this.offset,
    this.alignment,
    this.semanticsLabel,
  }) : assert(maxCount > 0, 'maxCount must be positive.');

  /// The widget the badge is attached to. Without a child, the badge is
  /// rendered on its own, for example in a list tile trailing slot.
  final Widget? child;

  /// A numeric count. Takes precedence over [label].
  final int? count;

  /// A text label. An empty string renders a small dot.
  final String? label;

  /// The largest count shown in full. Larger counts render as
  /// `'$maxCount+'`. Non-positive values fail an assertion in debug builds and
  /// fall back to 99 in release builds.
  final int maxCount;

  /// Whether a [count] of zero is shown.
  final bool showZero;

  /// Whether the badge is shown at all. The child is always shown.
  final bool isVisible;

  /// The badge color. Defaults to [BadgeThemeData.backgroundColor], which is
  /// [ColorScheme.error] in Material 3.
  final Color? backgroundColor;

  /// The label color. Defaults to [BadgeThemeData.textColor].
  final Color? textColor;

  /// Moves the badge relative to its default position.
  final Offset? offset;

  /// Where the badge is anchored on the child.
  final AlignmentGeometry? alignment;

  /// A description of the badge for screen readers.
  final String? semanticsLabel;

  /// The text the badge displays, or `null` for a small dot.
  ///
  /// Exposed for testing and for widgets that need the same formatting.
  String? get displayText {
    final int? value = count;
    if (value != null) {
      final int limit = maxCount > 0 ? maxCount : 99;
      return value > limit ? '$limit+' : '$value';
    }
    final String? text = label;
    return text == null || text.isEmpty ? null : text;
  }

  /// Whether the badge is visible given [isVisible], [count] and [showZero].
  bool get effectiveVisible {
    if (!isVisible) {
      return false;
    }
    final int? value = count;
    return value == null || value > 0 || showZero;
  }

  @override
  Widget build(BuildContext context) {
    final String? text = displayText;
    final bool visible = effectiveVisible;
    final Widget badge = Badge(
      isLabelVisible: visible,
      label: text == null ? null : Text(text),
      backgroundColor: backgroundColor,
      textColor: textColor,
      offset: offset,
      alignment: alignment,
      child: child,
    );
    final String? description = semanticsLabel;
    if (description == null || !visible) {
      return badge;
    }
    return Semantics(label: description, child: badge);
  }
}
