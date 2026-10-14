// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// @docImport 'package:flutter/material.dart';
library;

import '../typography/studio_typography.dart';
import 'common_text.dart';

/// Running text, styled with the [StudioTextRole.body] role.
///
/// Based on [TextTheme.bodyMedium].
///
/// ```dart
/// CommonBodyText(
///   'Your order ships tomorrow.',
///   maxLines: 3,
/// )
///
/// CommonBodyText(
///   'Read the terms',
///   link: true,
///   underline: false,
///   onTap: openTerms,
/// )
/// ```
///
/// See [CommonText] for style precedence, link behavior, accessibility and
/// overflow handling.
class CommonBodyText extends CommonText {
  /// Creates a body-styled text. See [CommonText] for the arguments.
  const CommonBodyText(
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
  StudioTextRole get role => StudioTextRole.body;
}
