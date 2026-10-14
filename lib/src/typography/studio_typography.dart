// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../theme/studio_theme_data.dart';

/// A semantic text role used by the `Common*Text` widgets.
enum StudioTextRole {
  /// Section and screen headings. Based on [TextTheme.titleLarge].
  header,

  /// Running text. Based on [TextTheme.bodyMedium].
  body,

  /// Short labels such as form labels and metadata. Based on
  /// [TextTheme.labelLarge].
  label,

  /// Small supporting text. Based on [TextTheme.bodySmall].
  caption,

  /// Additional styling applied on top of another role when text is
  /// rendered as a link. By default it only sets the link color.
  link,
}

/// Per-role text style overrides layered on top of the Material [TextTheme].
///
/// Every role starts from a [TextTheme] style (see [StudioTextRole]), so the
/// app font, the color scheme and Material defaults all apply. Any non-null
/// field here is merged on top of that base style. Fields left `null` keep
/// the Material default.
///
/// ```dart
/// const typography = StudioTypography(
///   header: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
///   link: TextStyle(fontWeight: FontWeight.w500),
/// );
/// ```
///
/// Provide it to `ScaffoldStudioApp.typography`, or to
/// `StudioTheme.toThemeData`. Widgets read it via [StudioThemeData].
///
/// ## Precedence
///
/// For the `Common*Text` widgets, styles are resolved from lowest to highest
/// priority:
///
/// 1. The role's base style from [ThemeData.textTheme].
/// 2. The role override from this object.
/// 3. The widget's `style` argument.
/// 4. The widget's individual arguments, such as `fontSize` or `color`.
///
/// Explicit [TextStyle] values that you pass to a plain [Text] widget are
/// never changed by this class. The app font is applied through
/// [ThemeData.textTheme] and [DefaultTextStyle], so third-party widgets that
/// hard-code their own `fontFamily` keep that family.
@immutable
class StudioTypography {
  /// Creates typography overrides. All fields are optional.
  const StudioTypography({
    this.header,
    this.body,
    this.label,
    this.caption,
    this.link,
  });

  /// Override for [StudioTextRole.header]. Defaults to a semibold
  /// [TextTheme.titleLarge].
  final TextStyle? header;

  /// Override for [StudioTextRole.body].
  final TextStyle? body;

  /// Override for [StudioTextRole.label].
  final TextStyle? label;

  /// Override for [StudioTextRole.caption].
  final TextStyle? caption;

  /// Extra styling merged onto any role when it is rendered as a link.
  final TextStyle? link;

  /// The override for [role], if any.
  TextStyle? overrideFor(StudioTextRole role) {
    return switch (role) {
      StudioTextRole.header => header,
      StudioTextRole.body => body,
      StudioTextRole.label => label,
      StudioTextRole.caption => caption,
      StudioTextRole.link => link,
    };
  }

  /// Resolves the complete style for [role] from [textTheme].
  ///
  /// [StudioTextRole.link] resolves to the body style with [link] merged on
  /// top; link color and decoration are applied by the widgets themselves.
  TextStyle resolve(StudioTextRole role, TextTheme textTheme) {
    final TextStyle base = switch (role) {
      StudioTextRole.header =>
        (textTheme.titleLarge ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w600,
        ),
      StudioTextRole.body ||
      StudioTextRole.link => textTheme.bodyMedium ?? const TextStyle(),
      StudioTextRole.label => textTheme.labelLarge ?? const TextStyle(),
      StudioTextRole.caption => textTheme.bodySmall ?? const TextStyle(),
    };
    final TextStyle withRole = role == StudioTextRole.link
        ? base.merge(body).merge(link)
        : base.merge(overrideFor(role));
    return withRole;
  }

  /// Resolves the style for [role] using the ambient theme of [context].
  ///
  /// This is the same style the `Common*Text` widgets start from, which is
  /// useful when you need a matching [TextStyle] for another widget.
  static TextStyle styleOf(BuildContext context, StudioTextRole role) {
    final ThemeData theme = Theme.of(context);
    return StudioThemeData.of(
      context,
    ).typography.resolve(role, theme.textTheme);
  }

  /// Returns a copy with the given fields replaced.
  StudioTypography copyWith({
    TextStyle? header,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? link,
  }) {
    return StudioTypography(
      header: header ?? this.header,
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      link: link ?? this.link,
    );
  }

  /// Linearly interpolates between two typographies, for theme animations.
  static StudioTypography lerp(
    StudioTypography? a,
    StudioTypography? b,
    double t,
  ) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return StudioTypography(
      header: TextStyle.lerp(a?.header, b?.header, t),
      body: TextStyle.lerp(a?.body, b?.body, t),
      label: TextStyle.lerp(a?.label, b?.label, t),
      caption: TextStyle.lerp(a?.caption, b?.caption, t),
      link: TextStyle.lerp(a?.link, b?.link, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudioTypography &&
        other.header == header &&
        other.body == body &&
        other.label == label &&
        other.caption == caption &&
        other.link == link;
  }

  @override
  int get hashCode => Object.hash(header, body, label, caption, link);
}
