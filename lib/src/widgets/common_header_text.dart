// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// @docImport 'package:flutter/material.dart';
library;

import '../typography/studio_typography.dart';
import 'common_text.dart';

/// A heading, styled with the [StudioTextRole.header] role.
///
/// Based on a semibold [TextTheme.titleLarge] and announced to screen readers
/// as a heading.
///
/// ```dart
/// CommonHeaderText(
///   'Hi Alex, how are you?',
///   fontSize: 20,
///   fontWeight: FontWeight.w600,
///   maxLines: 2,
/// )
///
/// CommonHeaderText(
///   'View profile',
///   link: true,
///   onTap: openProfile,
/// )
/// ```
///
/// See [CommonText] for style precedence, link behavior, accessibility and
/// overflow handling.
class CommonHeaderText extends CommonText {
  /// Creates a header-styled text. See [CommonText] for the arguments.
  const CommonHeaderText(
    super.text, {
    super.key,
    super.style,
    super.fontFamily,
    super.fontSize,
    super.fontWeight,
    super.fontStyle,
    super.color,
    super.letterSpacing,
    super.lineHeight,
    super.decoration,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.softWrap,
    super.link,
    super.underline,
    super.underlineColor,
    super.underlineStyle,
    super.underlineThickness,
    super.onTap,
    super.semanticsLabel,
    super.focusNode,
    super.autofocus,
  });

  @override
  StudioTextRole get role => StudioTextRole.header;

  @override
  bool get isHeader => true;
}
