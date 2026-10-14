// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// The visual style of a [CommonCard], matching the Material 3 card types.
enum CommonCardVariant {
  /// A card with a shadow. [Card].
  elevated,

  /// A card with a tonal fill and no shadow. [Card.filled].
  filled,

  /// A card with an outline. [Card.outlined].
  outlined,
}

/// A Material card with built-in padding and optional tap handling.
///
/// When [onTap] or [onLongPress] is set, the whole card becomes interactive
/// with an ink ripple, hover and focus highlights, keyboard activation and
/// button semantics. Shape, color and elevation default to
/// [ThemeData.cardTheme].
///
/// ```dart
/// CommonCard(
///   onTap: openOrder,
///   child: const CommonBodyText('Order #1042'),
/// )
/// ```
class CommonCard extends StatelessWidget {
  /// Creates a card.
  const CommonCard({
    super.key,
    required this.child,
    this.variant = CommonCardVariant.elevated,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
    this.clipBehavior,
  });

  /// The card content.
  final Widget child;

  /// The Material 3 card type.
  final CommonCardVariant variant;

  /// Space between the card edge and [child].
  final EdgeInsetsGeometry padding;

  /// Space around the card. Defaults to [CardThemeData.margin].
  final EdgeInsetsGeometry? margin;

  /// The card color.
  final Color? color;

  /// The card elevation.
  final double? elevation;

  /// The corner radius. Defaults to the card theme shape.
  final BorderRadius? borderRadius;

  /// Called when the card is tapped. Makes the card interactive.
  final VoidCallback? onTap;

  /// Called when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// A label for screen readers that describes the card as a whole.
  final String? semanticsLabel;

  /// How content is clipped. Defaults to [CardThemeData.clipBehavior].
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    final BorderRadius? radius = borderRadius;
    final ShapeBorder? shape = radius == null
        ? null
        : RoundedRectangleBorder(
            borderRadius: radius,
            side: variant == CommonCardVariant.outlined
                ? BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  )
                : BorderSide.none,
          );

    final bool interactive = onTap != null || onLongPress != null;
    Widget content = Padding(padding: padding, child: child);
    if (interactive) {
      // The ripple must follow the card outline even when the card does not
      // clip its content.
      final ShapeBorder rippleShape =
          shape ??
          CardTheme.of(context).shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          );
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: rippleShape,
        child: content,
      );
    }

    final Widget card = switch (variant) {
      CommonCardVariant.elevated => Card(
        margin: margin,
        color: color,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        child: content,
      ),
      CommonCardVariant.filled => Card.filled(
        margin: margin,
        color: color,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        child: content,
      ),
      CommonCardVariant.outlined => Card.outlined(
        margin: margin,
        color: color,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        child: content,
      ),
    };

    if (semanticsLabel == null) {
      return card;
    }
    return Semantics(container: true, label: semanticsLabel, child: card);
  }
}
