// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../studio_app_bar_search.dart';

/// The app bar search field: a compact [SearchBar] with a clear button.
///
/// Owns a [TextEditingController] only when the configuration does not
/// provide one, and disposes it accordingly.
class SearchField extends StatefulWidget {
  /// Creates a search field.
  const SearchField({super.key, required this.config});

  /// The field configuration.
  final StudioAppBarSearch config;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _ownedController;

  TextEditingController get _controller =>
      widget.config.controller ??
      (_ownedController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final TextEditingController? oldController = oldWidget.config.controller;
    final TextEditingController? newController = widget.config.controller;
    if (oldController != newController) {
      (oldController ?? _ownedController)?.removeListener(_handleTextChanged);
      if (newController != null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      _controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _ownedController?.dispose();
    super.dispose();
  }

  // Rebuild only when the clear button needs to appear or disappear.
  bool _hadText = false;

  void _handleTextChanged() {
    final bool hasText = _controller.text.isNotEmpty;
    if (hasText != _hadText) {
      setState(() => _hadText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.config.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final StudioAppBarSearch config = widget.config;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    _hadText = _controller.text.isNotEmpty;
    return SearchBar(
      controller: _controller,
      focusNode: config.focusNode,
      autoFocus: config.autofocus,
      hintText: config.hintText,
      onChanged: config.onChanged,
      onSubmitted: config.onSubmitted,
      elevation: const WidgetStatePropertyAll<double>(0),
      backgroundColor: WidgetStatePropertyAll<Color>(
        scheme.surfaceContainerHighest,
      ),
      constraints: BoxConstraints(
        minHeight: 40,
        maxHeight: 48,
        maxWidth: config.maxWidth,
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.only(start: 12, end: 4),
      ),
      leading: Icon(config.leadingIcon, color: scheme.onSurfaceVariant),
      trailing: <Widget>[
        if (_hadText)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: config.clearTooltip,
            onPressed: _clear,
          ),
        ...config.trailing,
      ],
    );
  }
}
