// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// The visual emphasis of a [CommonButton].
enum CommonButtonVariant {
  /// High emphasis. A [FilledButton].
  filled,

  /// Medium-high emphasis with a tonal container. [FilledButton.tonal].
  tonal,

  /// Medium emphasis with a shadow. An [ElevatedButton].
  elevated,

  /// Medium emphasis with an outline. An [OutlinedButton].
  outlined,

  /// Low emphasis. A [TextButton].
  text,
}

/// The height class of a [CommonButton].
enum CommonButtonSize {
  /// 40 logical pixels tall (the Material default). On mobile the touch
  /// target is still padded to 48 by [ThemeData.materialTapTargetSize].
  small(40, 12),

  /// 48 logical pixels tall.
  medium(48, 20),

  /// 56 logical pixels tall, for prominent calls to action.
  large(56, 28);

  const CommonButtonSize(this.height, this.horizontalPadding);

  /// The minimum height in logical pixels.
  final double height;

  /// The horizontal padding in logical pixels.
  final double horizontalPadding;
}

/// A button with a text label, an optional icon and a loading state.
///
/// `CommonButton` is a thin layer over Material's [FilledButton],
/// [ElevatedButton], [OutlinedButton] and [TextButton]. Focus, hover,
/// pressed and disabled states, keyboard activation, semantics and theming
/// all come from those widgets and from [ThemeData]. Pass [style] to adjust
/// anything else; it is merged over the size defaults.
///
/// ```dart
/// CommonButton(
///   label: 'Save',
///   icon: Icons.check,
///   onPressed: save,
/// )
/// ```
///
/// The button is disabled when [onPressed] is `null` or [isLoading] is
/// `true`. While loading, a progress indicator replaces the icon and the
/// button is announced as busy.
///
/// Long labels wrap onto at most two lines and then ellipsize instead of
/// overflowing; use [expand] to make the button fill the available width.
class CommonButton extends StatelessWidget {
  /// Creates a button.
  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = CommonButtonVariant.filled,
    this.size = CommonButtonSize.medium,
    this.isLoading = false,
    this.expand = false,
    this.trailingIcon = false,
    this.style,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.semanticsLabel,
    this.tooltip,
    this.loadingLabel = 'Loading',
  });

  /// The button text.
  final String label;

  /// Called when the button is activated. `null` disables the button.
  final VoidCallback? onPressed;

  /// Called on long press.
  final VoidCallback? onLongPress;

  /// An optional icon shown next to [label].
  final IconData? icon;

  /// Whether [icon] is placed after the label instead of before it.
  final bool trailingIcon;

  /// The visual emphasis.
  final CommonButtonVariant variant;

  /// The height class.
  final CommonButtonSize size;

  /// Whether to show a progress indicator and ignore presses.
  final bool isLoading;

  /// Whether the button fills the available width.
  ///
  /// Requires bounded width constraints; in an unbounded row it falls back to
  /// its intrinsic width.
  final bool expand;

  /// A style merged over the size defaults.
  final ButtonStyle? style;

  /// An optional focus node.
  final FocusNode? focusNode;

  /// Whether to request focus when first built.
  final bool autofocus;

  /// A label for screen readers that replaces [label].
  final String? semanticsLabel;

  /// An optional tooltip.
  final String? tooltip;

  /// The value announced by screen readers while [isLoading] is `true`.
  ///
  /// Override it to localize the announcement.
  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final VoidCallback? pressed = enabled ? onPressed : null;
    final VoidCallback? longPressed = enabled ? onLongPress : null;

    final ButtonStyle sizeStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(Size(64, size.height)),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: size.horizontalPadding, vertical: 8),
      ),
    );
    // Explicit style values win; the size only fills in what is unset.
    final ButtonStyle effectiveStyle = style?.merge(sizeStyle) ?? sizeStyle;

    final Widget? leading = _buildIcon();
    final Widget text = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      semanticsLabel: semanticsLabel,
    );
    Widget content = leading == null
        ? text
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!trailingIcon) ...<Widget>[leading, const SizedBox(width: 8)],
              Flexible(child: text),
              if (trailingIcon) ...<Widget>[const SizedBox(width: 8), leading],
            ],
          );

    if (isLoading) {
      // Inside the button, so it merges into the button's semantics node:
      // screen readers announce the label followed by the loading value.
      content = Semantics(
        liveRegion: true,
        value: loadingLabel,
        child: content,
      );
    }

    Widget button = switch (variant) {
      CommonButtonVariant.filled => FilledButton(
        onPressed: pressed,
        onLongPress: longPressed,
        style: effectiveStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        child: content,
      ),
      CommonButtonVariant.tonal => FilledButton.tonal(
        onPressed: pressed,
        onLongPress: longPressed,
        style: effectiveStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        child: content,
      ),
      CommonButtonVariant.elevated => ElevatedButton(
        onPressed: pressed,
        onLongPress: longPressed,
        style: effectiveStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        child: content,
      ),
      CommonButtonVariant.outlined => OutlinedButton(
        onPressed: pressed,
        onLongPress: longPressed,
        style: effectiveStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        child: content,
      ),
      CommonButtonVariant.text => TextButton(
        onPressed: pressed,
        onLongPress: longPressed,
        style: effectiveStyle,
        focusNode: focusNode,
        autofocus: autofocus,
        child: content,
      ),
    };

    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }
    if (expand) {
      // Capture the finished button; `button` itself is reassigned below.
      final Widget content = button;
      button = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (!constraints.hasBoundedWidth) {
            return content;
          }
          return SizedBox(width: constraints.maxWidth, child: content);
        },
      );
    }
    return button;
  }

  Widget? _buildIcon() {
    if (isLoading) {
      // Built lazily inside the button so that it picks up the button's
      // foreground color from the icon theme the button provides.
      return Builder(
        builder: (BuildContext context) => SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: IconTheme.of(context).color,
          ),
        ),
      );
    }
    final IconData? data = icon;
    return data == null ? null : Icon(data, size: 18);
  }
}
