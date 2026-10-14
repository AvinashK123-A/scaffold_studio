// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../widgets/common_badge.dart';
import '../studio_action.dart';

/// The width an icon action occupies, matching [IconButton]'s minimum size.
const double kActionExtent = kMinInteractiveDimension;

/// Splits [actions] into visible actions and an overflow menu so that at most
/// [capacity] slots are used.
///
/// Only [StudioAction]s with a tooltip can overflow, because the tooltip is
/// the menu text. Other widgets always stay visible. The overflow button
/// itself uses one slot. Order is preserved, and the actions furthest from
/// the start overflow first.
List<Widget> layoutActions({
  required List<Widget> actions,
  required int capacity,
  required String overflowTooltip,
}) {
  if (actions.length <= capacity) {
    return actions;
  }
  final List<int> collapsible = <int>[
    for (int i = 0; i < actions.length; i++)
      if (_canOverflow(actions[i])) i,
  ];
  if (collapsible.isEmpty) {
    return actions;
  }
  // One slot is taken by the overflow button. Moving a single action into a
  // menu saves no space, so require at least two to move.
  final int needToFree = actions.length - math.max(capacity - 1, 0);
  final int toMove = math.min(math.max(needToFree, 2), collapsible.length);
  if (toMove < 2) {
    return actions;
  }
  final Set<int> moved = collapsible.reversed.take(toMove).toSet();
  final List<StudioAction> overflow = <StudioAction>[
    for (int i = 0; i < actions.length; i++)
      if (moved.contains(i)) actions[i] as StudioAction,
  ];
  return <Widget>[
    for (int i = 0; i < actions.length; i++)
      if (!moved.contains(i)) actions[i],
    ActionOverflowButton(actions: overflow, tooltip: overflowTooltip),
  ];
}

bool _canOverflow(Widget widget) =>
    widget is StudioAction && widget.tooltip != null;

/// The "more" button that shows overflowed [StudioAction]s in a menu.
///
/// A badge dot is shown on the button when any hidden action has a visible
/// badge, so notifications are not hidden by the overflow.
class ActionOverflowButton extends StatelessWidget {
  /// Creates an overflow button.
  const ActionOverflowButton({
    super.key,
    required this.actions,
    required this.tooltip,
  });

  /// The hidden actions.
  final List<StudioAction> actions;

  /// The button tooltip.
  final String tooltip;

  CommonBadge? _badgeFor(StudioAction action) {
    if (action.badge == null && action.badgeCount == null) {
      return null;
    }
    final CommonBadge badge = CommonBadge(
      count: action.badgeCount,
      label: action.badge,
    );
    return badge.effectiveVisible ? badge : null;
  }

  @override
  Widget build(BuildContext context) {
    final bool anyBadge = actions.any(
      (StudioAction action) => _badgeFor(action) != null,
    );
    return PopupMenuButton<VoidCallback>(
      tooltip: tooltip,
      icon: CommonBadge(isVisible: anyBadge, child: Icon(Icons.adaptive.more)),
      onSelected: (VoidCallback callback) => callback(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<VoidCallback>>[
        for (final StudioAction action in actions)
          PopupMenuItem<VoidCallback>(
            value: action.onPressed,
            enabled: action.onPressed != null,
            child: Row(
              children: <Widget>[
                Icon(action.icon, color: action.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action.tooltip ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_badgeFor(action) case final CommonBadge badge) ...<Widget>[
                  const SizedBox(width: 12),
                  badge,
                ],
              ],
            ),
          ),
      ],
    );
  }
}
