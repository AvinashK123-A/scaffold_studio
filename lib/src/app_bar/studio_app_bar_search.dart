// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Configuration for the search field of a `StudioAppBar`.
///
/// ```dart
/// StudioAppBar(
///   style: StudioAppBarStyle.search,
///   search: StudioAppBarSearch(
///     hintText: 'Search orders',
///     onChanged: filter,
///   ),
/// )
/// ```
///
/// The field is a Material [SearchBar]. When [controller] is `null`, the app
/// bar creates and disposes its own controller. A clear button appears while
/// the field has text.
@immutable
class StudioAppBarSearch {
  /// Creates a search field configuration.
  const StudioAppBarSearch({
    this.hintText = 'Search',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.maxWidth = 720,
    this.leadingIcon = Icons.search,
    this.trailing = const <Widget>[],
    this.clearTooltip = 'Clear',
    this.openTooltip = 'Search',
    this.closeTooltip = 'Close search',
  });

  /// The placeholder text. Override it to localize.
  final String hintText;

  /// The text controller. Owned by you when provided.
  final TextEditingController? controller;

  /// The focus node. Owned by you when provided.
  final FocusNode? focusNode;

  /// Called for every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field requests focus when it appears.
  final bool autofocus;

  /// The maximum field width on wide layouts. The field never stretches
  /// across a whole desktop window.
  final double maxWidth;

  /// The icon at the start of the field.
  final IconData leadingIcon;

  /// Extra widgets at the end of the field, such as a voice input button.
  final List<Widget> trailing;

  /// The tooltip of the clear button. Override it to localize.
  final String clearTooltip;

  /// The tooltip of the button that opens search on compact widths, when
  /// the app bar style is not `StudioAppBarStyle.search`.
  final String openTooltip;

  /// The tooltip of the button that closes search on compact widths.
  final String closeTooltip;
}
