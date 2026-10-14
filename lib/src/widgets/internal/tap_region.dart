// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Makes a non-button widget, such as a text link, behave like a native
/// interactive control.
///
/// Provides, in one place:
///
/// * tap handling without requiring a [Material] ancestor,
/// * keyboard focus and activation with Enter and Space through the
///   [ActivateIntent] shortcuts that `WidgetsApp` installs,
/// * a visible focus indicator when focus is driven by the keyboard,
/// * a click cursor on hover,
/// * link or button semantics,
/// * a minimum touch target height when the theme's
///   [ThemeData.materialTapTargetSize] is [MaterialTapTargetSize.padded].
///
/// This is internal. It is only created when a callback exists, so plain
/// text never pays for gesture detection or focus handling.
class StudioTapRegion extends StatefulWidget {
  /// Creates an interactive region around [child].
  const StudioTapRegion({
    super.key,
    required this.onTap,
    required this.isLink,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.focusColor,
  });

  /// Called when the region is tapped or activated from the keyboard.
  final VoidCallback onTap;

  /// Whether to expose link semantics (`true`) or button semantics.
  final bool isLink;

  /// An optional focus node.
  final FocusNode? focusNode;

  /// Whether to request focus when first built.
  final bool autofocus;

  /// The color of the keyboard focus indicator. Defaults to
  /// [ColorScheme.primary].
  final Color? focusColor;

  /// The interactive content.
  final Widget child;

  @override
  State<StudioTapRegion> createState() => _StudioTapRegionState();
}

class _StudioTapRegionState extends State<StudioTapRegion> {
  bool _showFocus = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _activate),
  };

  Object? _activate(ActivateIntent intent) {
    widget.onTap();
    return null;
  }

  void _handleFocusHighlight(bool value) {
    if (value != _showFocus) {
      setState(() => _showFocus = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color focusColor = widget.focusColor ?? theme.colorScheme.primary;

    Widget result = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: _showFocus ? focusColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: widget.child,
    );

    if (theme.materialTapTargetSize == MaterialTapTargetSize.padded) {
      result = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 1,
          heightFactor: 1,
          child: result,
        ),
      );
    }

    return Semantics(
      container: true,
      link: widget.isLink,
      button: !widget.isLink,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        actions: _actions,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: _handleFocusHighlight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          // Gesture semantics are provided by the enclosing Semantics node.
          excludeFromSemantics: true,
          child: result,
        ),
      ),
    );
  }
}
