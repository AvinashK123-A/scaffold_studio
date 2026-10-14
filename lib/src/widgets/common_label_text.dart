// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// @docImport 'package:flutter/material.dart';
library;

import '../typography/studio_typography.dart';
import 'common_text.dart';

/// A short label, styled with the [StudioTextRole.label] role.
///
/// Based on [TextTheme.labelLarge]. Use it for form labels, metadata and
/// compact links such as "See all".
///
/// ```dart
/// CommonLabelText('Updated 2 min ago')
///
/// CommonLabelText('See all', link: true, onTap: showAll)
/// ```
///
/// See [CommonText] for style precedence, link behavior, accessibility and
/// overflow handling.
class CommonLabelText extends CommonText {
  /// Creates a label-styled text. See [CommonText] for the arguments.
  const CommonLabelText(
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
  StudioTextRole get role => StudioTextRole.label;
}
