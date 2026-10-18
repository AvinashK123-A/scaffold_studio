// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../typography/studio_font.dart';

/// The overall look of a `CommonSearchField`.
///
/// The variant only picks default values. Every value can still be
/// overridden individually through [CommonSearchFieldStyle].
enum CommonSearchFieldVariant {
  /// A tonal fill with fully rounded corners and no outline, like the
  /// Material 3 search bar. A primary-colored outline appears on focus.
  filled,

  /// A transparent field with a rounded outline that turns primary-colored
  /// on focus.
  outlined,

  /// A transparent field with a single line underneath.
  underlined,

  /// No fill and no border, for embedding in your own container.
  plain,
}

/// When the clear button of a `CommonSearchField` is shown.
enum CommonSearchFieldClearButtonMode {
  /// Never show the clear button.
  never,

  /// Show it whenever the field has text.
  whenNotEmpty,

  /// Show it only while the field has text and keyboard focus.
  whenFocusedAndNotEmpty,

  /// Always show it, even when the field is empty.
  always,
}

/// Visual properties of a `CommonSearchField`.
///
/// Every property is optional. A `null` value means "use the next level":
///
/// 1. the `style` passed to the widget,
/// 2. a [CommonSearchFieldStyle] installed in the ambient [ThemeData] as a
///    [ThemeExtension], then
/// 3. defaults derived from the [CommonSearchFieldVariant] and the
///    [ColorScheme].
///
/// Set app-wide defaults once:
///
/// ```dart
/// ThemeData(
///   extensions: const [
///     CommonSearchFieldStyle(
///       variant: CommonSearchFieldVariant.outlined,
///       borderRadius: BorderRadius.all(Radius.circular(8)),
///     ),
///   ],
/// )
/// ```
///
/// and override single values per field:
///
/// ```dart
/// CommonSearchField(
///   style: CommonSearchFieldStyle(
///     backgroundColor: Colors.white,
///     borderColor: Colors.black12,
///     focusedBorderColor: Colors.teal,
///     textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
///   ),
/// )
/// ```
///
/// Colors that depend on the interaction state come in groups. For example
/// the border uses [borderColor] normally, [hoverBorderColor] under a mouse
/// pointer, [focusedBorderColor] while focused and [disabledBorderColor]
/// when disabled. An unset state color falls back to the normal one.
@immutable
class CommonSearchFieldStyle extends ThemeExtension<CommonSearchFieldStyle>
    with Diagnosticable {
  /// Creates a search field style. Every value is optional.
  const CommonSearchFieldStyle({
    this.variant,
    this.height,
    this.width,
    this.maxWidth,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.font,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.selectionColor,
    this.selectionHandleColor,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.focusedBackgroundColor,
    this.disabledBackgroundColor,
    this.borderRadius,
    this.borderWidth,
    this.focusedBorderWidth,
    this.borderColor,
    this.hoverBorderColor,
    this.focusedBorderColor,
    this.disabledBorderColor,
    this.shadows,
    this.focusedShadows,
    this.prefixIcon,
    this.prefixIconSize,
    this.prefixIconColor,
    this.focusedPrefixIconColor,
    this.prefixIconConstraints,
    this.clearIcon,
    this.clearIconSize,
    this.clearIconColor,
    this.clearButtonStyle,
    this.suffixIconColor,
    this.suffixIconSize,
    this.loadingIndicatorColor,
    this.loadingIndicatorSize,
    this.loadingIndicatorStrokeWidth,
    this.animationDuration,
    this.animationCurve,
  });

  // Layout.

  /// The look that supplies the default values.
  final CommonSearchFieldVariant? variant;

  /// The minimum height of the field. Defaults to 48.
  ///
  /// The field grows beyond this when the text scale requires it, so large
  /// accessibility font sizes never clip the text.
  final double? height;

  /// A fixed width. By default the field fills the available width.
  final double? width;

  /// The maximum width. Defaults to no limit.
  final double? maxWidth;

  /// The space around the text inside the field.
  ///
  /// The start padding is replaced by the prefix icon area while a prefix
  /// icon is shown, and the end padding by the suffix area while a clear
  /// button, loading indicator or trailing widget is shown.
  final EdgeInsetsGeometry? contentPadding;

  // Text.

  /// The style of the typed text, merged over the theme's
  /// [TextTheme.bodyLarge] in [ColorScheme.onSurface].
  final TextStyle? textStyle;

  /// The style of the hint, merged over the theme's [TextTheme.bodyLarge] in
  /// [ColorScheme.onSurfaceVariant].
  final TextStyle? hintStyle;

  /// A font family applied to both the text and the hint, such as
  /// [StudioFont.roboto] or a `StudioFont.custom` font.
  final StudioFont? font;

  /// The color of the cursor. Defaults to the theme's cursor color.
  final Color? cursorColor;

  /// The width of the cursor. Defaults to 2.
  final double? cursorWidth;

  /// The height of the cursor. Defaults to the line height.
  final double? cursorHeight;

  /// The corner radius of the cursor.
  final Radius? cursorRadius;

  /// The background color of selected text.
  final Color? selectionColor;

  /// The color of the selection handles on touch devices.
  final Color? selectionHandleColor;

  // Background.

  /// The fill color. `null` (after defaults) or transparent means no fill.
  final Color? backgroundColor;

  /// The fill color under a mouse pointer.
  ///
  /// When unset, the theme's hover overlay is blended over
  /// [backgroundColor].
  final Color? hoverBackgroundColor;

  /// The fill color while the field has focus.
  final Color? focusedBackgroundColor;

  /// The fill color while the field is disabled.
  final Color? disabledBackgroundColor;

  // Border.

  /// The corner radius of the border, the fill and the shadows.
  ///
  /// For [CommonSearchFieldVariant.underlined] only the top corners are
  /// rounded.
  final BorderRadius? borderRadius;

  /// The border width. Zero hides the border.
  final double? borderWidth;

  /// The border width while focused. Defaults to [borderWidth].
  final double? focusedBorderWidth;

  /// The border color.
  final Color? borderColor;

  /// The border color under a mouse pointer.
  final Color? hoverBorderColor;

  /// The border color while focused.
  final Color? focusedBorderColor;

  /// The border color while disabled.
  final Color? disabledBorderColor;

  // Shadows.

  /// Shadows drawn behind the field, following [borderRadius].
  final List<BoxShadow>? shadows;

  /// Shadows drawn while the field has focus. Defaults to [shadows].
  final List<BoxShadow>? focusedShadows;

  // Icons.

  /// The icon at the start of the field. Defaults to [Icons.search].
  final IconData? prefixIcon;

  /// The size of [prefixIcon]. Defaults to 24.
  final double? prefixIconSize;

  /// The color of [prefixIcon].
  final Color? prefixIconColor;

  /// The color of [prefixIcon] while focused.
  final Color? focusedPrefixIconColor;

  /// The size constraints of the prefix icon area. Defaults to 48 logical
  /// pixels wide, with the icon centered.
  final BoxConstraints? prefixIconConstraints;

  /// The icon of the clear button. Defaults to [Icons.close].
  final IconData? clearIcon;

  /// The size of [clearIcon]. Defaults to 20.
  final double? clearIconSize;

  /// The color of [clearIcon].
  final Color? clearIconColor;

  /// A button style merged over the clear button's defaults, for its size,
  /// shape, padding, overlay colors and so on.
  final ButtonStyle? clearButtonStyle;

  /// The default icon color for the `trailing` widgets.
  final Color? suffixIconColor;

  /// The default icon size for the `trailing` widgets. Defaults to 24.
  final double? suffixIconSize;

  /// The color of the loading indicator.
  final Color? loadingIndicatorColor;

  /// The diameter of the loading indicator. Defaults to 18.
  final double? loadingIndicatorSize;

  /// The stroke width of the loading indicator. Defaults to 2.
  final double? loadingIndicatorStrokeWidth;

  // Motion.

  /// The duration of shadow and size changes. Border and fill changes use
  /// the Material input decorator animation. Defaults to 150 milliseconds.
  ///
  /// Skipped when the platform requests reduced motion.
  final Duration? animationDuration;

  /// The curve of shadow and size changes.
  final Curve? animationCurve;

  /// Returns the style installed in the ambient theme, or `null`.
  static CommonSearchFieldStyle? maybeOf(BuildContext context) {
    return Theme.of(context).extension<CommonSearchFieldStyle>();
  }

  /// Returns a copy with [other]'s non-null values taking precedence.
  ///
  /// Text styles are merged rather than replaced.
  CommonSearchFieldStyle merge(CommonSearchFieldStyle? other) {
    if (other == null) {
      return this;
    }
    return CommonSearchFieldStyle(
      variant: other.variant ?? variant,
      height: other.height ?? height,
      width: other.width ?? width,
      maxWidth: other.maxWidth ?? maxWidth,
      contentPadding: other.contentPadding ?? contentPadding,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      hintStyle: hintStyle?.merge(other.hintStyle) ?? other.hintStyle,
      font: other.font ?? font,
      cursorColor: other.cursorColor ?? cursorColor,
      cursorWidth: other.cursorWidth ?? cursorWidth,
      cursorHeight: other.cursorHeight ?? cursorHeight,
      cursorRadius: other.cursorRadius ?? cursorRadius,
      selectionColor: other.selectionColor ?? selectionColor,
      selectionHandleColor: other.selectionHandleColor ?? selectionHandleColor,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      hoverBackgroundColor: other.hoverBackgroundColor ?? hoverBackgroundColor,
      focusedBackgroundColor:
          other.focusedBackgroundColor ?? focusedBackgroundColor,
      disabledBackgroundColor:
          other.disabledBackgroundColor ?? disabledBackgroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
      borderWidth: other.borderWidth ?? borderWidth,
      focusedBorderWidth: other.focusedBorderWidth ?? focusedBorderWidth,
      borderColor: other.borderColor ?? borderColor,
      hoverBorderColor: other.hoverBorderColor ?? hoverBorderColor,
      focusedBorderColor: other.focusedBorderColor ?? focusedBorderColor,
      disabledBorderColor: other.disabledBorderColor ?? disabledBorderColor,
      shadows: other.shadows ?? shadows,
      focusedShadows: other.focusedShadows ?? focusedShadows,
      prefixIcon: other.prefixIcon ?? prefixIcon,
      prefixIconSize: other.prefixIconSize ?? prefixIconSize,
      prefixIconColor: other.prefixIconColor ?? prefixIconColor,
      focusedPrefixIconColor:
          other.focusedPrefixIconColor ?? focusedPrefixIconColor,
      prefixIconConstraints:
          other.prefixIconConstraints ?? prefixIconConstraints,
      clearIcon: other.clearIcon ?? clearIcon,
      clearIconSize: other.clearIconSize ?? clearIconSize,
      clearIconColor: other.clearIconColor ?? clearIconColor,
      clearButtonStyle:
          other.clearButtonStyle?.merge(clearButtonStyle) ?? clearButtonStyle,
      suffixIconColor: other.suffixIconColor ?? suffixIconColor,
      suffixIconSize: other.suffixIconSize ?? suffixIconSize,
      loadingIndicatorColor:
          other.loadingIndicatorColor ?? loadingIndicatorColor,
      loadingIndicatorSize: other.loadingIndicatorSize ?? loadingIndicatorSize,
      loadingIndicatorStrokeWidth:
          other.loadingIndicatorStrokeWidth ?? loadingIndicatorStrokeWidth,
      animationDuration: other.animationDuration ?? animationDuration,
      animationCurve: other.animationCurve ?? animationCurve,
    );
  }

  @override
  CommonSearchFieldStyle copyWith({
    CommonSearchFieldVariant? variant,
    double? height,
    double? width,
    double? maxWidth,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    StudioFont? font,
    Color? cursorColor,
    double? cursorWidth,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? selectionColor,
    Color? selectionHandleColor,
    Color? backgroundColor,
    Color? hoverBackgroundColor,
    Color? focusedBackgroundColor,
    Color? disabledBackgroundColor,
    BorderRadius? borderRadius,
    double? borderWidth,
    double? focusedBorderWidth,
    Color? borderColor,
    Color? hoverBorderColor,
    Color? focusedBorderColor,
    Color? disabledBorderColor,
    List<BoxShadow>? shadows,
    List<BoxShadow>? focusedShadows,
    IconData? prefixIcon,
    double? prefixIconSize,
    Color? prefixIconColor,
    Color? focusedPrefixIconColor,
    BoxConstraints? prefixIconConstraints,
    IconData? clearIcon,
    double? clearIconSize,
    Color? clearIconColor,
    ButtonStyle? clearButtonStyle,
    Color? suffixIconColor,
    double? suffixIconSize,
    Color? loadingIndicatorColor,
    double? loadingIndicatorSize,
    double? loadingIndicatorStrokeWidth,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return CommonSearchFieldStyle(
      variant: variant ?? this.variant,
      height: height ?? this.height,
      width: width ?? this.width,
      maxWidth: maxWidth ?? this.maxWidth,
      contentPadding: contentPadding ?? this.contentPadding,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      font: font ?? this.font,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      selectionColor: selectionColor ?? this.selectionColor,
      selectionHandleColor: selectionHandleColor ?? this.selectionHandleColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
      focusedBackgroundColor:
          focusedBackgroundColor ?? this.focusedBackgroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      borderColor: borderColor ?? this.borderColor,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      shadows: shadows ?? this.shadows,
      focusedShadows: focusedShadows ?? this.focusedShadows,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      prefixIconSize: prefixIconSize ?? this.prefixIconSize,
      prefixIconColor: prefixIconColor ?? this.prefixIconColor,
      focusedPrefixIconColor:
          focusedPrefixIconColor ?? this.focusedPrefixIconColor,
      prefixIconConstraints:
          prefixIconConstraints ?? this.prefixIconConstraints,
      clearIcon: clearIcon ?? this.clearIcon,
      clearIconSize: clearIconSize ?? this.clearIconSize,
      clearIconColor: clearIconColor ?? this.clearIconColor,
      clearButtonStyle: clearButtonStyle ?? this.clearButtonStyle,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      suffixIconSize: suffixIconSize ?? this.suffixIconSize,
      loadingIndicatorColor:
          loadingIndicatorColor ?? this.loadingIndicatorColor,
      loadingIndicatorSize: loadingIndicatorSize ?? this.loadingIndicatorSize,
      loadingIndicatorStrokeWidth:
          loadingIndicatorStrokeWidth ?? this.loadingIndicatorStrokeWidth,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  CommonSearchFieldStyle lerp(
    covariant CommonSearchFieldStyle? other,
    double t,
  ) {
    if (other == null || identical(this, other)) {
      return this;
    }
    // Values that cannot be interpolated switch at the midpoint.
    final bool useOther = t >= 0.5;
    T pick<T>(T a, T b) => useOther ? b : a;
    return CommonSearchFieldStyle(
      variant: pick(variant, other.variant),
      height: lerpDouble(height, other.height, t),
      width: lerpDouble(width, other.width, t),
      maxWidth: _lerpExtent(maxWidth, other.maxWidth, t),
      contentPadding: EdgeInsetsGeometry.lerp(
        contentPadding,
        other.contentPadding,
        t,
      ),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t),
      font: pick(font, other.font),
      cursorColor: Color.lerp(cursorColor, other.cursorColor, t),
      cursorWidth: lerpDouble(cursorWidth, other.cursorWidth, t),
      cursorHeight: lerpDouble(cursorHeight, other.cursorHeight, t),
      cursorRadius: Radius.lerp(cursorRadius, other.cursorRadius, t),
      selectionColor: Color.lerp(selectionColor, other.selectionColor, t),
      selectionHandleColor: Color.lerp(
        selectionHandleColor,
        other.selectionHandleColor,
        t,
      ),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      hoverBackgroundColor: Color.lerp(
        hoverBackgroundColor,
        other.hoverBackgroundColor,
        t,
      ),
      focusedBackgroundColor: Color.lerp(
        focusedBackgroundColor,
        other.focusedBackgroundColor,
        t,
      ),
      disabledBackgroundColor: Color.lerp(
        disabledBackgroundColor,
        other.disabledBackgroundColor,
        t,
      ),
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t),
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t),
      focusedBorderWidth: lerpDouble(
        focusedBorderWidth,
        other.focusedBorderWidth,
        t,
      ),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      hoverBorderColor: Color.lerp(hoverBorderColor, other.hoverBorderColor, t),
      focusedBorderColor: Color.lerp(
        focusedBorderColor,
        other.focusedBorderColor,
        t,
      ),
      disabledBorderColor: Color.lerp(
        disabledBorderColor,
        other.disabledBorderColor,
        t,
      ),
      shadows: BoxShadow.lerpList(shadows, other.shadows, t),
      focusedShadows: BoxShadow.lerpList(
        focusedShadows,
        other.focusedShadows,
        t,
      ),
      prefixIcon: pick(prefixIcon, other.prefixIcon),
      prefixIconSize: lerpDouble(prefixIconSize, other.prefixIconSize, t),
      prefixIconColor: Color.lerp(prefixIconColor, other.prefixIconColor, t),
      focusedPrefixIconColor: Color.lerp(
        focusedPrefixIconColor,
        other.focusedPrefixIconColor,
        t,
      ),
      prefixIconConstraints: BoxConstraints.lerp(
        prefixIconConstraints,
        other.prefixIconConstraints,
        t,
      ),
      clearIcon: pick(clearIcon, other.clearIcon),
      clearIconSize: lerpDouble(clearIconSize, other.clearIconSize, t),
      clearIconColor: Color.lerp(clearIconColor, other.clearIconColor, t),
      clearButtonStyle: ButtonStyle.lerp(
        clearButtonStyle,
        other.clearButtonStyle,
        t,
      ),
      suffixIconColor: Color.lerp(suffixIconColor, other.suffixIconColor, t),
      suffixIconSize: lerpDouble(suffixIconSize, other.suffixIconSize, t),
      loadingIndicatorColor: Color.lerp(
        loadingIndicatorColor,
        other.loadingIndicatorColor,
        t,
      ),
      loadingIndicatorSize: lerpDouble(
        loadingIndicatorSize,
        other.loadingIndicatorSize,
        t,
      ),
      loadingIndicatorStrokeWidth: lerpDouble(
        loadingIndicatorStrokeWidth,
        other.loadingIndicatorStrokeWidth,
        t,
      ),
      animationDuration: pick(animationDuration, other.animationDuration),
      animationCurve: pick(animationCurve, other.animationCurve),
    );
  }

  // Interpolates extents that may be infinite ("no limit").
  static double? _lerpExtent(double? a, double? b, double t) {
    if (a != null && b != null && a.isFinite && b.isFinite) {
      return lerpDouble(a, b, t);
    }
    return t < 0.5 ? a : b;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CommonSearchFieldStyle &&
        other.variant == variant &&
        other.height == height &&
        other.width == width &&
        other.maxWidth == maxWidth &&
        other.contentPadding == contentPadding &&
        other.textStyle == textStyle &&
        other.hintStyle == hintStyle &&
        other.font == font &&
        other.cursorColor == cursorColor &&
        other.cursorWidth == cursorWidth &&
        other.cursorHeight == cursorHeight &&
        other.cursorRadius == cursorRadius &&
        other.selectionColor == selectionColor &&
        other.selectionHandleColor == selectionHandleColor &&
        other.backgroundColor == backgroundColor &&
        other.hoverBackgroundColor == hoverBackgroundColor &&
        other.focusedBackgroundColor == focusedBackgroundColor &&
        other.disabledBackgroundColor == disabledBackgroundColor &&
        other.borderRadius == borderRadius &&
        other.borderWidth == borderWidth &&
        other.focusedBorderWidth == focusedBorderWidth &&
        other.borderColor == borderColor &&
        other.hoverBorderColor == hoverBorderColor &&
        other.focusedBorderColor == focusedBorderColor &&
        other.disabledBorderColor == disabledBorderColor &&
        listEquals(other.shadows, shadows) &&
        listEquals(other.focusedShadows, focusedShadows) &&
        other.prefixIcon == prefixIcon &&
        other.prefixIconSize == prefixIconSize &&
        other.prefixIconColor == prefixIconColor &&
        other.focusedPrefixIconColor == focusedPrefixIconColor &&
        other.prefixIconConstraints == prefixIconConstraints &&
        other.clearIcon == clearIcon &&
        other.clearIconSize == clearIconSize &&
        other.clearIconColor == clearIconColor &&
        other.clearButtonStyle == clearButtonStyle &&
        other.suffixIconColor == suffixIconColor &&
        other.suffixIconSize == suffixIconSize &&
        other.loadingIndicatorColor == loadingIndicatorColor &&
        other.loadingIndicatorSize == loadingIndicatorSize &&
        other.loadingIndicatorStrokeWidth == loadingIndicatorStrokeWidth &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    variant,
    height,
    width,
    maxWidth,
    contentPadding,
    textStyle,
    hintStyle,
    font,
    cursorColor,
    cursorWidth,
    cursorHeight,
    cursorRadius,
    selectionColor,
    selectionHandleColor,
    backgroundColor,
    hoverBackgroundColor,
    focusedBackgroundColor,
    disabledBackgroundColor,
    borderRadius,
    borderWidth,
    focusedBorderWidth,
    borderColor,
    hoverBorderColor,
    focusedBorderColor,
    disabledBorderColor,
    shadows == null ? null : Object.hashAll(shadows!),
    focusedShadows == null ? null : Object.hashAll(focusedShadows!),
    prefixIcon,
    prefixIconSize,
    prefixIconColor,
    focusedPrefixIconColor,
    prefixIconConstraints,
    clearIcon,
    clearIconSize,
    clearIconColor,
    clearButtonStyle,
    suffixIconColor,
    suffixIconSize,
    loadingIndicatorColor,
    loadingIndicatorSize,
    loadingIndicatorStrokeWidth,
    animationDuration,
    animationCurve,
  ]);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<CommonSearchFieldVariant>('variant', variant))
      ..add(DoubleProperty('height', height, defaultValue: null))
      ..add(DoubleProperty('width', width, defaultValue: null))
      ..add(DoubleProperty('maxWidth', maxWidth, defaultValue: null))
      ..add(
        DiagnosticsProperty<TextStyle>(
          'textStyle',
          textStyle,
          defaultValue: null,
        ),
      )
      ..add(DiagnosticsProperty<StudioFont>('font', font, defaultValue: null))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('focusedBackgroundColor', focusedBackgroundColor))
      ..add(
        DiagnosticsProperty<BorderRadius>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      )
      ..add(DoubleProperty('borderWidth', borderWidth, defaultValue: null))
      ..add(ColorProperty('borderColor', borderColor))
      ..add(ColorProperty('focusedBorderColor', focusedBorderColor))
      ..add(DiagnosticsProperty<IconData>('prefixIcon', prefixIcon));
  }
}
