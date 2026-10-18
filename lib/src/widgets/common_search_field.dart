// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../typography/studio_font.dart';
import 'common_search_field_style.dart';

/// Builds a custom clear button for a [CommonSearchField].
///
/// Call `onClear` to clear the field. It updates the text, notifies the
/// field's callbacks and runs an immediate search with an empty query.
typedef CommonSearchFieldClearButtonBuilder =
    Widget Function(BuildContext context, VoidCallback onClear);

/// Adjusts the final [InputDecoration] of a [CommonSearchField].
///
/// Receives the decoration the field built from its style and returns the
/// one to use. This is an escape hatch for anything the style does not
/// cover, such as helper text.
typedef CommonSearchFieldDecorationBuilder =
    InputDecoration Function(BuildContext context, InputDecoration decoration);

/// A fully customizable search text field.
///
/// `CommonSearchField` is built on Material's [TextField], so text editing,
/// selection, keyboard shortcuts, input methods, autofill and semantics work
/// exactly as in any Flutter text field. On top of that it adds:
///
/// * a search icon, a clear button and optional trailing widgets such as a
///   voice or filter button,
/// * a loading indicator for in-flight searches ([isLoading]),
/// * a debounced [onSearch] callback with an optional [minSearchLength], so
///   you can query a server without firing on every keystroke,
/// * clearing with the Escape key on hardware keyboards ([clearOnEscape]),
/// * four looks ([CommonSearchFieldVariant]) and a [CommonSearchFieldStyle]
///   that controls every visual detail: text and hint style, font, cursor,
///   selection color, fill, border width, color and radius for each
///   interaction state, shadows, icons, sizes and padding.
///
/// ```dart
/// CommonSearchField(
///   hintText: 'Search products',
///   onSearch: (String query) => controller.search(query),
/// )
/// ```
///
/// Customize anything through [style]:
///
/// ```dart
/// CommonSearchField(
///   variant: CommonSearchFieldVariant.outlined,
///   style: const CommonSearchFieldStyle(
///     height: 44,
///     borderRadius: BorderRadius.all(Radius.circular(10)),
///     borderColor: Color(0xFFD0D5DD),
///     focusedBorderColor: Color(0xFF7F56D9),
///     focusedBorderWidth: 1.5,
///     textStyle: TextStyle(fontSize: 15),
///     hintStyle: TextStyle(color: Color(0xFF98A2B3)),
///     prefixIcon: Icons.manage_search,
///   ),
///   onChanged: filter,
/// )
/// ```
///
/// Values not set in [style] come from a [CommonSearchFieldStyle] installed
/// in the ambient [ThemeData] as an extension, and then from [defaultStyle].
///
/// ## Controller and focus
///
/// When [controller] or [focusNode] is `null`, the field creates and disposes
/// its own. When you provide them, you own them and must dispose them.
/// [initialValue] seeds the field's own controller and is ignored when a
/// [controller] is provided.
///
/// ## Layout
///
/// The field fills the available width, limited by
/// [CommonSearchFieldStyle.maxWidth], or uses [CommonSearchFieldStyle.width]
/// when set. In a place with unbounded width, such as directly inside a
/// [Row], it falls back to a width of 360 instead of failing; wrap it in an
/// [Expanded] to make it fill the row.
class CommonSearchField extends StatefulWidget {
  /// Creates a search field.
  const CommonSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.hintText = 'Search',
    this.hint,
    this.variant,
    this.style,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.isLoading = false,
    this.loadingLabel = 'Loading',
    this.onChanged,
    this.onSubmitted,
    this.onSearch,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.minSearchLength = 0,
    this.trimSearchQuery = true,
    this.onCleared,
    this.onTap,
    this.onTapOutside,
    this.onFocusChange,
    this.clearButtonMode = CommonSearchFieldClearButtonMode.whenNotEmpty,
    this.clearOnEscape = true,
    this.clearTooltip = 'Clear',
    this.clearButtonBuilder,
    this.showPrefixIcon = true,
    this.prefix,
    this.trailing = const <Widget>[],
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.autocorrect,
    this.enableSuggestions = true,
    this.inputFormatters,
    this.maxLength,
    this.keyboardAppearance,
    this.autofillHints,
    this.enableInteractiveSelection = true,
    this.contextMenuBuilder,
    this.mouseCursor,
    this.scrollPadding = const EdgeInsets.all(20),
    this.decorationBuilder,
  }) : assert(minSearchLength >= 0, 'minSearchLength must not be negative.'),
       assert(
         maxLength == null || maxLength > 0,
         'maxLength must be null or positive.',
       );

  // Text and state.

  /// The text controller. Owned by you when provided.
  final TextEditingController? controller;

  /// The focus node. Owned by you when provided.
  final FocusNode? focusNode;

  /// The initial text of the field's own controller.
  ///
  /// Ignored when [controller] is provided.
  final String? initialValue;

  /// The placeholder text shown while the field is empty. Override it to
  /// localize. Ignored when [hint] is set.
  final String hintText;

  /// A widget shown instead of [hintText] while the field is empty.
  final Widget? hint;

  /// The look of the field. Overrides [CommonSearchFieldStyle.variant].
  ///
  /// Defaults to [CommonSearchFieldVariant.filled].
  final CommonSearchFieldVariant? variant;

  /// Visual overrides. Unset values come from the theme and then from
  /// [defaultStyle].
  final CommonSearchFieldStyle? style;

  /// Whether the field accepts input. A disabled field is dimmed and hides
  /// the clear button.
  final bool enabled;

  /// Whether the text can be changed. A read-only field can still be
  /// focused, selected and tapped, which suits a field that opens a
  /// separate search page from [onTap].
  final bool readOnly;

  /// Whether the field requests focus when first built.
  final bool autofocus;

  /// Whether to show a progress indicator at the end of the field, for
  /// example while search results load.
  final bool isLoading;

  /// The label announced by screen readers for the loading indicator.
  /// Override it to localize.
  final String loadingLabel;

  // Callbacks.

  /// Called for every edit with the raw text, including when the field is
  /// cleared.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Called with the search query once typing pauses for [searchDebounce].
  ///
  /// It is also called immediately when the user submits the field or
  /// clears it. The query is trimmed when [trimSearchQuery] is `true`. A
  /// non-empty query shorter than [minSearchLength] is skipped, and the same
  /// query is not reported twice in a row unless the user submits it again.
  /// An empty query is always reported, so you can reset results.
  final ValueChanged<String>? onSearch;

  /// How long typing must pause before [onSearch] is called. Use
  /// [Duration.zero] to search on every edit.
  final Duration searchDebounce;

  /// The minimum length of a non-empty query passed to [onSearch].
  final int minSearchLength;

  /// Whether leading and trailing whitespace is removed from the query passed
  /// to [onSearch]. [onChanged] always receives the raw text.
  final bool trimSearchQuery;

  /// Called after the clear button or the Escape key clears the field.
  final VoidCallback? onCleared;

  /// Called when the field is tapped.
  final GestureTapCallback? onTap;

  /// Called for taps outside the field. Defaults to the [TextField]
  /// behavior, which removes focus on touch devices.
  final TapRegionCallback? onTapOutside;

  /// Called when the field gains or loses keyboard focus.
  final ValueChanged<bool>? onFocusChange;

  // Clear button, prefix and trailing widgets.

  /// When the clear button is shown. It is never shown while the field is
  /// disabled or read-only.
  final CommonSearchFieldClearButtonMode clearButtonMode;

  /// Whether pressing Escape on a hardware keyboard clears a non-empty
  /// field. An empty field lets Escape through to its ancestors, for example
  /// to close a dialog.
  final bool clearOnEscape;

  /// The tooltip and screen reader label of the clear button. Override it
  /// to localize.
  final String clearTooltip;

  /// Builds a custom clear button in place of the default icon button.
  final CommonSearchFieldClearButtonBuilder? clearButtonBuilder;

  /// Whether to show the prefix icon. Ignored when [prefix] is set.
  final bool showPrefixIcon;

  /// A widget shown at the start of the field in place of the prefix icon,
  /// such as an avatar or a menu button. It inherits the prefix icon color
  /// and size.
  final Widget? prefix;

  /// Widgets shown at the end of the field after the clear button, such as
  /// a microphone or filter button. They inherit the suffix icon color and
  /// size.
  final List<Widget> trailing;

  // Text input.

  /// The type of keyboard to show.
  final TextInputType keyboardType;

  /// The action button of the on-screen keyboard. Defaults to search.
  final TextInputAction textInputAction;

  /// How the on-screen keyboard capitalizes text.
  final TextCapitalization textCapitalization;

  /// How the text is aligned horizontally.
  final TextAlign textAlign;

  /// The direction of the text. Defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// Whether to enable autocorrection. Defaults to the platform behavior.
  final bool? autocorrect;

  /// Whether to show input suggestions while typing.
  final bool enableSuggestions;

  /// Formatters that validate or reformat the text as it is typed.
  final List<TextInputFormatter>? inputFormatters;

  /// The maximum number of characters. No counter is shown.
  final int? maxLength;

  /// The appearance of the on-screen keyboard on iOS.
  final Brightness? keyboardAppearance;

  /// Autofill hints. By default the field does not take part in autofill.
  final Iterable<String>? autofillHints;

  /// Whether the user can select text and use the context menu.
  final bool enableInteractiveSelection;

  /// Builds the text selection context menu. Defaults to the platform menu.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// The mouse cursor over the field. Defaults to the text cursor.
  final MouseCursor? mouseCursor;

  /// The space kept between the field and the screen edges when it scrolls
  /// into view.
  final EdgeInsets scrollPadding;

  /// Adjusts the final [InputDecoration]. See
  /// [CommonSearchFieldDecorationBuilder].
  final CommonSearchFieldDecorationBuilder? decorationBuilder;

  /// The default style for [variant] under [theme].
  ///
  /// Every value is set, so this is also a convenient starting point for a
  /// custom style:
  ///
  /// ```dart
  /// final CommonSearchFieldStyle brand = CommonSearchField.defaultStyle(
  ///   Theme.of(context),
  ///   CommonSearchFieldVariant.outlined,
  /// ).copyWith(focusedBorderColor: Colors.teal);
  /// ```
  static CommonSearchFieldStyle defaultStyle(
    ThemeData theme, [
    CommonSearchFieldVariant variant = CommonSearchFieldVariant.filled,
  ]) {
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle body =
        theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    final bool emphasizeFocus =
        variant == CommonSearchFieldVariant.outlined ||
        variant == CommonSearchFieldVariant.underlined;
    final CommonSearchFieldStyle common = CommonSearchFieldStyle(
      variant: variant,
      height: 48,
      maxWidth: double.infinity,
      textStyle: body.copyWith(color: scheme.onSurface),
      hintStyle: body.copyWith(color: scheme.onSurfaceVariant),
      cursorWidth: 2,
      shadows: const <BoxShadow>[],
      prefixIcon: Icons.search,
      prefixIconSize: 24,
      prefixIconColor: scheme.onSurfaceVariant,
      focusedPrefixIconColor: emphasizeFocus
          ? scheme.primary
          : scheme.onSurfaceVariant,
      prefixIconConstraints: BoxConstraints(
        minWidth: variant == CommonSearchFieldVariant.underlined ? 40 : 48,
        minHeight: 24,
      ),
      clearIcon: Icons.close,
      clearIconSize: 20,
      clearIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      suffixIconSize: 24,
      loadingIndicatorColor: scheme.primary,
      loadingIndicatorSize: 18,
      loadingIndicatorStrokeWidth: 2,
      animationDuration: const Duration(milliseconds: 150),
      animationCurve: Curves.easeOut,
    );
    return switch (variant) {
      CommonSearchFieldVariant.filled => common.copyWith(
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        backgroundColor: scheme.surfaceContainerHighest,
        disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        borderWidth: 0,
        focusedBorderWidth: 2,
        borderColor: Colors.transparent,
        focusedBorderColor: scheme.primary,
        disabledBorderColor: Colors.transparent,
      ),
      CommonSearchFieldVariant.outlined => common.copyWith(
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderWidth: 1,
        focusedBorderWidth: 2,
        borderColor: scheme.outline,
        hoverBorderColor: scheme.onSurface,
        focusedBorderColor: scheme.primary,
        disabledBorderColor: scheme.onSurface.withValues(alpha: 0.12),
      ),
      CommonSearchFieldVariant.underlined => common.copyWith(
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        borderRadius: BorderRadius.zero,
        borderWidth: 1,
        focusedBorderWidth: 2,
        borderColor: scheme.onSurfaceVariant,
        hoverBorderColor: scheme.onSurface,
        focusedBorderColor: scheme.primary,
        disabledBorderColor: scheme.onSurface.withValues(alpha: 0.38),
      ),
      CommonSearchFieldVariant.plain => common.copyWith(
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        borderRadius: BorderRadius.zero,
        borderWidth: 0,
        borderColor: Colors.transparent,
      ),
    };
  }

  /// The fully resolved style for this field in [context]: [defaultStyle],
  /// then the theme extension, then [style].
  CommonSearchFieldStyle resolveStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommonSearchFieldStyle? themeStyle = theme
        .extension<CommonSearchFieldStyle>();
    final CommonSearchFieldVariant effectiveVariant =
        variant ??
        style?.variant ??
        themeStyle?.variant ??
        CommonSearchFieldVariant.filled;
    return defaultStyle(
      theme,
      effectiveVariant,
    ).merge(themeStyle).merge(style).copyWith(variant: effectiveVariant);
  }

  @override
  State<CommonSearchField> createState() => _CommonSearchFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('hintText', hintText))
      ..add(EnumProperty<CommonSearchFieldVariant>('variant', variant))
      ..add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'))
      ..add(FlagProperty('readOnly', value: readOnly, ifTrue: 'read-only'))
      ..add(FlagProperty('isLoading', value: isLoading, ifTrue: 'loading'))
      ..add(
        EnumProperty<CommonSearchFieldClearButtonMode>(
          'clearButtonMode',
          clearButtonMode,
        ),
      )
      ..add(DiagnosticsProperty<Duration>('searchDebounce', searchDebounce))
      ..add(IntProperty('minSearchLength', minSearchLength));
  }
}

class _CommonSearchFieldState extends State<CommonSearchField> {
  // Fallback width when the parent does not bound the width.
  static const double _unboundedWidth = 360;

  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  Timer? _debounce;
  String? _lastQuery;
  bool _hasText = false;
  bool _focused = false;
  bool _hovered = false;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialValue));

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownedFocusNode ??= FocusNode(debugLabel: 'CommonSearchField'));

  bool get _editable => widget.enabled && !widget.readOnly;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
    _hasText = _controller.text.isNotEmpty;
    _focused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(CommonSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Owned objects are kept until dispose, because the inner TextField may
    // still reference them during this frame. They are reused if the
    // parent switches back to letting the field own them.
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(
        _handleTextChanged,
      );
      _controller.addListener(_handleTextChanged);
      _hasText = _controller.text.isNotEmpty;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(
        _handleFocusChanged,
      );
      _focusNode.addListener(_handleFocusChanged);
      _focused = _focusNode.hasFocus;
    }
    if (oldWidget.onSearch != null && widget.onSearch == null) {
      _debounce?.cancel();
      _debounce = null;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_handleTextChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final bool hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleFocusChanged() {
    final bool focused = _focusNode.hasFocus;
    if (focused == _focused) {
      return;
    }
    setState(() => _focused = focused);
    widget.onFocusChange?.call(focused);
  }

  void _setHovered(bool hovered) {
    if (hovered != _hovered) {
      setState(() => _hovered = hovered);
    }
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    _scheduleSearch(value);
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    _search(value, force: true);
  }

  void _scheduleSearch(String value) {
    if (widget.onSearch == null) {
      return;
    }
    _debounce?.cancel();
    if (widget.searchDebounce <= Duration.zero) {
      _search(value);
      return;
    }
    _debounce = Timer(widget.searchDebounce, () => _search(value));
  }

  void _search(String value, {bool force = false}) {
    _debounce?.cancel();
    _debounce = null;
    final ValueChanged<String>? onSearch = widget.onSearch;
    if (onSearch == null || !mounted) {
      return;
    }
    final String query = widget.trimSearchQuery ? value.trim() : value;
    if (query.isNotEmpty && query.length < widget.minSearchLength) {
      return;
    }
    if (!force && query == _lastQuery) {
      return;
    }
    _lastQuery = query;
    onSearch(query);
  }

  void _clear() {
    if (!_editable) {
      return;
    }
    _controller.clear();
    widget.onChanged?.call('');
    widget.onCleared?.call();
    _search('');
  }

  bool get _clearButtonWanted {
    switch (widget.clearButtonMode) {
      case CommonSearchFieldClearButtonMode.never:
        return false;
      case CommonSearchFieldClearButtonMode.whenNotEmpty:
        return _hasText;
      case CommonSearchFieldClearButtonMode.whenFocusedAndNotEmpty:
        return _hasText && _focused;
      case CommonSearchFieldClearButtonMode.always:
        return true;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!widget.clearOnEscape ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        !_editable ||
        _controller.text.isEmpty) {
      return KeyEventResult.ignored;
    }
    _clear();
    return KeyEventResult.handled;
  }

  static Widget? _hideCounter(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  }) {
    return null;
  }

  // Mirrors the default of TextField.contextMenuBuilder.
  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    if (SystemContextMenu.isSupportedByField(editableTextState)) {
      return SystemContextMenu.editableText(
        editableTextState: editableTextState,
      );
    }
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  static Color _dim(Color color) => color.withValues(alpha: color.a * 0.38);

  // OutlineInputBorder only supports circular corners.
  static BorderRadius _circular(BorderRadius radius) {
    Radius corner(Radius r) =>
        r.x == r.y ? r : Radius.circular(math.min(r.x, r.y));
    return BorderRadius.only(
      topLeft: corner(radius.topLeft),
      topRight: corner(radius.topRight),
      bottomLeft: corner(radius.bottomLeft),
      bottomRight: corner(radius.bottomRight),
    );
  }

  static InputBorder _border(
    CommonSearchFieldStyle style, {
    bool focused = false,
    bool hovered = false,
    bool disabled = false,
  }) {
    final Color base = style.borderColor ?? Colors.transparent;
    final Color color;
    if (disabled) {
      color = style.disabledBorderColor ?? base;
    } else if (focused) {
      color = style.focusedBorderColor ?? base;
    } else if (hovered) {
      color = style.hoverBorderColor ?? base;
    } else {
      color = base;
    }
    final double baseWidth = style.borderWidth ?? 0;
    final double width = focused && !disabled
        ? style.focusedBorderWidth ?? baseWidth
        : baseWidth;
    final BorderSide side = width <= 0 || color.a == 0
        ? BorderSide.none
        : BorderSide(color: color, width: width);
    final BorderRadius radius = _circular(
      style.borderRadius ?? BorderRadius.zero,
    );
    if (style.variant == CommonSearchFieldVariant.underlined) {
      return UnderlineInputBorder(borderSide: side, borderRadius: radius);
    }
    return OutlineInputBorder(
      borderSide: side,
      borderRadius: radius,
      gapPadding: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CommonSearchFieldStyle style = widget.resolveStyle(context);
    final bool disabled = !widget.enabled;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // Text.
    final StudioFont? font = style.font;
    TextStyle textStyle = style.textStyle ?? const TextStyle();
    TextStyle hintStyle = style.hintStyle ?? const TextStyle();
    if (font != null) {
      textStyle = font.applyTo(textStyle, platform: theme.platform);
      hintStyle = font.applyTo(hintStyle, platform: theme.platform);
    }
    if (disabled) {
      final Color? textColor = textStyle.color;
      final Color? hintColor = hintStyle.color;
      textStyle = textStyle.copyWith(
        color: textColor == null ? null : _dim(textColor),
      );
      hintStyle = hintStyle.copyWith(
        color: hintColor == null ? null : _dim(hintColor),
      );
    }

    // Icons.
    final Color basePrefixColor =
        style.prefixIconColor ?? theme.colorScheme.onSurfaceVariant;
    final Color prefixColor;
    if (disabled) {
      prefixColor = _dim(basePrefixColor);
    } else if (_focused) {
      prefixColor = style.focusedPrefixIconColor ?? basePrefixColor;
    } else {
      prefixColor = basePrefixColor;
    }
    final Color baseSuffixColor =
        style.suffixIconColor ?? theme.colorScheme.onSurfaceVariant;
    final Color suffixColor;
    if (disabled) {
      suffixColor = _dim(baseSuffixColor);
    } else {
      suffixColor = baseSuffixColor;
    }

    Widget? prefix;
    final Widget? customPrefix = widget.prefix;
    if (customPrefix != null) {
      prefix = IconTheme.merge(
        data: IconThemeData(color: prefixColor, size: style.prefixIconSize),
        child: customPrefix,
      );
    } else if (widget.showPrefixIcon) {
      prefix = Icon(
        style.prefixIcon ?? Icons.search,
        size: style.prefixIconSize,
        color: prefixColor,
      );
    }

    final bool showClear = _editable && _clearButtonWanted;
    final List<Widget> suffixChildren = <Widget>[
      if (widget.isLoading) _buildLoadingIndicator(style, theme),
      if (showClear) _buildClearButton(context, style),
      ...widget.trailing,
    ];
    Widget? suffix;
    if (suffixChildren.isNotEmpty) {
      suffix = Padding(
        padding: const EdgeInsetsDirectional.only(end: 4),
        child: IconTheme.merge(
          data: IconThemeData(color: suffixColor, size: style.suffixIconSize),
          child: Row(mainAxisSize: MainAxisSize.min, children: suffixChildren),
        ),
      );
    }

    // Background.
    final Color? background = style.backgroundColor;
    final Color? hoverBackground = style.hoverBackgroundColor;
    final Color? focusedBackground = style.focusedBackgroundColor;
    final Color? disabledBackground = style.disabledBackgroundColor;
    bool visible(Color? color) => color != null && color.a > 0;
    final bool filled =
        visible(background) ||
        visible(hoverBackground) ||
        visible(focusedBackground) ||
        visible(disabledBackground);
    final Color fillBase = background ?? Colors.transparent;
    Color resolveFill(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return disabledBackground ?? fillBase;
      }
      if (states.contains(WidgetState.focused)) {
        return focusedBackground ?? fillBase;
      }
      if (states.contains(WidgetState.hovered)) {
        return hoverBackground ?? fillBase;
      }
      return fillBase;
    }

    // Without an explicit hover fill, the theme's hover overlay is blended
    // over the fill. Unfilled fields get no hover overlay.
    Color? hoverOverlay;
    if (!filled || hoverBackground != null) {
      hoverOverlay = Colors.transparent;
    }

    // Borders. Every slot is set so that an app-wide InputDecorationTheme
    // cannot leak into the field.
    final InputBorder enabledBorder = _border(style, hovered: _hovered);
    final InputBorder focusedBorder = _border(
      style,
      focused: true,
      hovered: _hovered,
    );

    InputDecoration decoration = InputDecoration(
      hint: widget.hint,
      hintText: widget.hint == null ? widget.hintText : null,
      hintStyle: hintStyle,
      hintMaxLines: 1,
      isDense: true,
      contentPadding: style.contentPadding,
      constraints: BoxConstraints(minHeight: style.height ?? 48),
      prefixIcon: prefix,
      prefixIconColor: prefixColor,
      prefixIconConstraints: style.prefixIconConstraints,
      suffixIcon: suffix,
      suffixIconColor: suffixColor,
      suffixIconConstraints: const BoxConstraints(minHeight: 24),
      filled: filled,
      fillColor: filled ? WidgetStateColor.resolveWith(resolveFill) : null,
      hoverColor: hoverOverlay,
      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      disabledBorder: _border(style, disabled: true),
      errorBorder: enabledBorder,
      focusedErrorBorder: focusedBorder,
    );
    final CommonSearchFieldDecorationBuilder? decorationBuilder =
        widget.decorationBuilder;
    if (decorationBuilder != null) {
      decoration = decorationBuilder(context, decoration);
    }

    Widget field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: textStyle,
      textAlign: widget.textAlign,
      textAlignVertical: TextAlignVertical.center,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLength: widget.maxLength,
      onChanged: _handleChanged,
      onSubmitted: _handleSubmitted,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: style.cursorWidth ?? 2,
      cursorHeight: style.cursorHeight,
      cursorRadius: style.cursorRadius,
      cursorColor: style.cursorColor,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: _hideCounter,
      autofillHints: widget.autofillHints,
      contextMenuBuilder:
          widget.contextMenuBuilder ?? _defaultContextMenuBuilder,
    );

    if (style.selectionColor != null || style.selectionHandleColor != null) {
      field = TextSelectionTheme(
        data: TextSelectionTheme.of(context).copyWith(
          selectionColor: style.selectionColor,
          selectionHandleColor: style.selectionHandleColor,
        ),
        child: field,
      );
    }

    final List<BoxShadow> shadows = style.shadows ?? const <BoxShadow>[];
    final List<BoxShadow> focusedShadows = style.focusedShadows ?? shadows;
    if (shadows.isNotEmpty || focusedShadows.isNotEmpty) {
      field = AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : style.animationDuration ?? const Duration(milliseconds: 150),
        curve: style.animationCurve ?? Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: style.borderRadius,
          boxShadow: _focused ? focusedShadows : shadows,
        ),
        child: field,
      );
    }

    field = MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: field,
    );

    final double maxWidth = style.maxWidth ?? double.infinity;
    final double? width = style.width;
    if (width != null) {
      field = SizedBox(width: width, child: field);
    } else {
      // Only applies when the parent leaves the width unbounded.
      field = LimitedBox(
        maxWidth: math.min(maxWidth, _unboundedWidth),
        child: field,
      );
    }
    if (maxWidth.isFinite) {
      field = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: field,
      );
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: _handleKey,
      child: field,
    );
  }

  Widget _buildLoadingIndicator(CommonSearchFieldStyle style, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox.square(
        dimension: style.loadingIndicatorSize ?? 18,
        child: CircularProgressIndicator(
          strokeWidth: style.loadingIndicatorStrokeWidth ?? 2,
          color: style.loadingIndicatorColor ?? theme.colorScheme.primary,
          semanticsLabel: widget.loadingLabel,
        ),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context, CommonSearchFieldStyle style) {
    final CommonSearchFieldClearButtonBuilder? builder =
        widget.clearButtonBuilder;
    if (builder != null) {
      return builder(context, _clear);
    }
    final ButtonStyle defaults = IconButton.styleFrom(
      minimumSize: const Size.square(40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return IconButton(
      onPressed: _clear,
      tooltip: widget.clearTooltip,
      color: style.clearIconColor,
      iconSize: style.clearIconSize ?? 20,
      style: style.clearButtonStyle?.merge(defaults) ?? defaults,
      icon: Icon(style.clearIcon ?? Icons.close),
    );
  }
}
