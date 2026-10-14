// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../theme/studio_theme_data.dart';
import '../typography/studio_font.dart';
import '../typography/studio_typography.dart';
import 'internal/tap_region.dart';

/// The shared implementation of the `Common*Text` widgets.
///
/// Use one of the concrete widgets: `CommonHeaderText`, `CommonBodyText` or
/// `CommonLabelText`. They differ only in their [role], which selects the base
/// style (see [StudioTextRole]).
///
/// ## Style precedence
///
/// From lowest to highest priority:
///
/// 1. The [role]'s base style from the ambient [ThemeData.textTheme], which
///    already uses the app font.
/// 2. The role override from [StudioTypography].
/// 3. Link color and underline, when [link] is `true`.
/// 4. [style].
/// 5. The individual arguments: [fontFamily], [fontSize], [fontWeight],
///    [fontStyle], [color], [letterSpacing], [lineHeight] and [decoration].
///
/// ## Links
///
/// When [link] is `true`, the text uses [StudioThemeData.linkColor] (a
/// theme-derived blue by default) and is underlined unless [underline] is
/// `false`. [onTap] is required for links; omitting it fails an assertion in
/// debug builds. In release builds such a link renders with link styling but
/// is not interactive and is not announced as a link.
///
/// An interactive text (any text with [onTap]) gets keyboard focus,
/// activation with Enter and Space, a focus indicator, a click cursor on
/// hover, and link or button semantics. When the theme's
/// [ThemeData.materialTapTargetSize] is [MaterialTapTargetSize.padded] (the
/// default on mobile), its hit area is at least 48 logical pixels tall.
///
/// Text without [onTap] is a plain [Text] with no gesture detector, so it
/// remains selectable inside a [SelectionArea].
///
/// ## Overflow
///
/// Text wraps by default and never overflows horizontally. When [maxLines]
/// is set and [overflow] is not, overflowing text is ellipsized.
abstract class CommonText extends StatelessWidget {
  /// Creates a themed text. See the concrete subclasses.
  const CommonText(
    this.text, {
    super.key,
    this.style,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.color,
    this.letterSpacing,
    this.lineHeight,
    this.decoration,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.link = false,
    this.underline = true,
    this.underlineColor,
    this.underlineStyle,
    this.underlineThickness,
    this.onTap,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
         !link || onTap != null,
         'A link must have an onTap callback. Pass `onTap`, or set '
         '`link: false` to render plain text.',
       ),
       assert(
         fontSize == null || fontSize > 0,
         'fontSize must be greater than zero.',
       ),
       assert(maxLines == null || maxLines > 0, 'maxLines must be positive.');

  /// The text to display.
  final String text;

  /// A style merged on top of the themed role style.
  ///
  /// Individual arguments such as [fontSize] take precedence over this.
  final TextStyle? style;

  /// Overrides the font family for this widget only.
  ///
  /// [StudioFont.system] restores the platform default even when the app
  /// uses another font.
  final StudioFont? fontFamily;

  /// The font size in logical pixels, before text scaling.
  ///
  /// The system text scale factor is still applied. Non-positive values fail
  /// an assertion in debug builds and are ignored in release builds.
  final double? fontSize;

  /// The font weight. See [StudioFont.availableWeights] for weights that
  /// have a dedicated face in a bundled font.
  final FontWeight? fontWeight;

  /// Whether to use italics.
  final FontStyle? fontStyle;

  /// The text color. For links, this replaces the link color.
  final Color? color;

  /// The space between letters, in logical pixels.
  final double? letterSpacing;

  /// The line height as a multiple of [fontSize] (see [TextStyle.height]).
  final double? lineHeight;

  /// A decoration such as [TextDecoration.lineThrough].
  ///
  /// For links, the underline from [underline] is combined with this.
  final TextDecoration? decoration;

  /// How to align the text horizontally.
  final TextAlign? textAlign;

  /// The maximum number of lines. `null` means unlimited.
  ///
  /// Non-positive values fail an assertion in debug builds and are treated
  /// as unlimited in release builds.
  final int? maxLines;

  /// How to handle visual overflow. Defaults to [TextOverflow.ellipsis] when
  /// [maxLines] is set.
  final TextOverflow? overflow;

  /// Whether the text may break at soft line breaks.
  final bool? softWrap;

  /// Whether to render the text as a link.
  final bool link;

  /// Whether a link is underlined. Ignored when [link] is `false`.
  ///
  /// `underline: false` removes the underline but keeps the link color,
  /// interaction and semantics.
  final bool underline;

  /// The color of a link underline. Defaults to the text color.
  final Color? underlineColor;

  /// The style of a link underline, such as dotted or dashed.
  final TextDecorationStyle? underlineStyle;

  /// The thickness multiplier of a link underline.
  final double? underlineThickness;

  /// Called when the text is tapped or activated with the keyboard.
  ///
  /// Required when [link] is `true`. On non-link text it makes the text
  /// behave like a button.
  final VoidCallback? onTap;

  /// An alternative label for screen readers.
  final String? semanticsLabel;

  /// An optional focus node for interactive text.
  final FocusNode? focusNode;

  /// Whether interactive text requests focus when first built.
  final bool autofocus;

  /// The semantic role that selects the base style.
  @protected
  StudioTextRole get role;

  /// Whether this text is announced as a heading.
  @protected
  bool get isHeader => false;

  /// Resolves the final text style, applying the precedence documented on
  /// [CommonText].
  @protected
  TextStyle resolveStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final StudioThemeData tokens = StudioThemeData.of(context);
    TextStyle resolved = tokens.typography.resolve(role, theme.textTheme);

    if (link) {
      resolved = resolved
          .copyWith(color: tokens.linkColor)
          .merge(tokens.typography.link);
    }
    resolved = resolved.merge(style);

    final StudioFont? font = fontFamily;
    if (font != null) {
      resolved = font.applyTo(resolved, platform: theme.platform);
    }

    final double? size = fontSize;
    resolved = resolved.copyWith(
      fontSize: size != null && size > 0 && size.isFinite ? size : null,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

    if (link) {
      final TextDecoration? extra = decoration;
      final List<TextDecoration> decorations = <TextDecoration>[
        if (extra != null && extra != TextDecoration.none) extra,
        if (underline) TextDecoration.underline,
      ];
      resolved = resolved.copyWith(
        decoration: decorations.isEmpty
            ? TextDecoration.none
            : TextDecoration.combine(decorations),
        decorationColor: underlineColor,
        decorationStyle: underlineStyle,
        decorationThickness: underlineThickness,
      );
    } else if (decoration != null) {
      resolved = resolved.copyWith(decoration: decoration);
    }
    return resolved;
  }

  @override
  Widget build(BuildContext context) {
    final int? requestedLines = maxLines;
    final int? lines = requestedLines != null && requestedLines > 0
        ? requestedLines
        : null;
    Widget result = Text(
      text,
      style: resolveStyle(context),
      textAlign: textAlign,
      maxLines: lines,
      overflow: overflow ?? (lines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
    );

    final VoidCallback? callback = onTap;
    if (callback != null) {
      result = StudioTapRegion(
        onTap: callback,
        isLink: link,
        focusNode: focusNode,
        autofocus: autofocus,
        focusColor: link ? StudioThemeData.of(context).linkColor : null,
        child: result,
      );
    }

    if (isHeader) {
      result = Semantics(header: true, child: result);
    }
    return result;
  }
}
