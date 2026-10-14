// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A horizontal or vertical divider with an optional centered label.
///
/// Without a [label], this is a [Divider] or [VerticalDivider] and uses
/// [ThemeData.dividerTheme]. With a [label] (horizontal only), the text sits
/// between two lines, as in a "or continue with" separator. The label wraps
/// rather than overflowing on narrow widths.
///
/// ```dart
/// const CommonDivider(label: 'OR', spacing: 24)
/// ```
class CommonDivider extends StatelessWidget {
  /// Creates a divider.
  const CommonDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.label,
    this.spacing,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.labelStyle,
  });

  /// Whether the divider is a horizontal or vertical line.
  final Axis axis;

  /// Text shown in the middle of a horizontal divider.
  ///
  /// Ignored for vertical dividers.
  final String? label;

  /// The total space the divider occupies across its line.
  final double? spacing;

  /// The line thickness.
  final double? thickness;

  /// Empty space before the line.
  final double? indent;

  /// Empty space after the line.
  final double? endIndent;

  /// The line color.
  final Color? color;

  /// The style of [label]. Defaults to [TextTheme.labelMedium] in
  /// [ColorScheme.onSurfaceVariant].
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.vertical) {
      return VerticalDivider(
        width: spacing,
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: color,
      );
    }
    final String? text = label;
    if (text == null || text.isEmpty) {
      return Divider(
        height: spacing,
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: color,
      );
    }

    final ThemeData theme = Theme.of(context);
    final Widget line = Expanded(
      child: Divider(height: 1, thickness: thickness, color: color),
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: indent ?? 0,
        end: endIndent ?? 0,
        top: (spacing ?? 16) / 2,
        bottom: (spacing ?? 16) / 2,
      ),
      child: Row(
        children: <Widget>[
          line,
          // The label may take up to 60% of the width and wraps beyond
          // that, so the lines never disappear and nothing overflows.
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style:
                    labelStyle ??
                    theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}
