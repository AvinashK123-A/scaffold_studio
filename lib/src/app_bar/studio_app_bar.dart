// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../responsive/studio_breakpoints.dart';
import '../theme/studio_theme_data.dart';
import 'internal/action_overflow.dart';
import 'internal/app_bar_height_scope.dart';
import 'internal/app_bar_style_spec.dart';
import 'internal/search_field.dart';
import 'studio_action.dart';
import 'studio_app_bar_search.dart';
import 'studio_app_bar_style.dart';

/// A configurable, responsive top app bar.
///
/// `StudioAppBar` is built on Material's [AppBar], so back navigation,
/// drawer buttons, system status bar styling, safe-area handling, scroll
/// elevation and semantics all behave as they do in Flutter. A
/// [StudioAppBarStyle] sets the defaults; every argument overrides them.
///
/// ```dart
/// StudioAppBar(
///   style: StudioAppBarStyle.flexible,
///   leading: const CircleAvatar(child: Icon(Icons.person)),
///   titleText: 'Dashboard',
///   actions: [
///     StudioAction(
///       icon: Icons.notifications_outlined,
///       tooltip: 'Notifications',
///       badge: '3',
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
///
/// ## Slots
///
/// Any widget can be placed in [leading], [title], [subtitle], [logo],
/// [profile] and [actions]. Use [titleText] and [subtitleText] for the common
/// case of plain text.
///
/// ## Responsive behavior
///
/// * **Long titles** are kept to one line and ellipsized. A [subtitle] gets
///   one line below the title.
/// * **Many actions**: when the bar is too narrow, trailing [StudioAction]s
///   that have a tooltip move into an overflow menu so the title keeps at
///   least about 40% of the width. The overflow button shows a badge dot if
///   any hidden action has a visible badge. Set [maxVisibleActions] to
///   control this explicitly. Other widgets in [actions] are never moved.
/// * **Search** (see [search]): with [StudioAppBarStyle.search] the field
///   replaces the title on compact widths and sits next to it on wider ones.
///   With other styles, compact widths show a search button that expands the
///   field in place; wider widths show the field next to the title.
/// * **Text scaling**: inside a `ScaffoldStudio`, the bar height grows with
///   the system text scale (up to 1.5×) when [adaptiveHeight] is `true`.
///   Used directly in a [Scaffold], the height is fixed at [preferredSize]
///   because Flutter asks for it before the widget tree is available; text
///   that does not fit is clipped, never overflowing.
///
/// ## Accessibility
///
/// The title is announced as a heading by [AppBar]. Give every
/// [StudioAction] a tooltip, which is its spoken label; visible badge text
/// is announced with it.
class StudioAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates an app bar.
  const StudioAppBar({
    super.key,
    this.style = StudioAppBarStyle.standard,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.titleSemanticsLabel,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.logo,
    this.profile,
    this.actions = const <Widget>[],
    this.maxVisibleActions,
    this.overflowTooltip = 'More options',
    this.search,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.backgroundImage,
    this.imageScrimColor,
    this.elevation,
    this.scrolledUnderElevation,
    this.shadowColor,
    this.height,
    this.minHeight = kMinInteractiveDimension,
    this.adaptiveHeight = true,
    this.borderRadius,
    this.centerTitle,
    this.titleTextStyle,
    this.titleSpacing,
    this.leadingWidth,
    this.actionSpacing = 0,
    this.actionsPadding,
    this.systemOverlayStyle,
    this.primary = true,
    this.bottom,
  }) : assert(
         title == null || titleText == null,
         'Provide either title or titleText, not both.',
       ),
       assert(
         subtitle == null || subtitleText == null,
         'Provide either subtitle or subtitleText, not both.',
       ),
       assert(height == null || height > 0, 'height must be positive.'),
       assert(minHeight >= 0, 'minHeight must not be negative.'),
       assert(
         maxVisibleActions == null || maxVisibleActions >= 0,
         'maxVisibleActions must not be negative.',
       ),
       assert(actionSpacing >= 0, 'actionSpacing must not be negative.');

  /// The preset that supplies default colors, height, shape and layout.
  final StudioAppBarStyle style;

  /// The title widget. Mutually exclusive with [titleText].
  final Widget? title;

  /// The title as text, kept to one line and ellipsized.
  final String? titleText;

  /// A widget shown below the title. Mutually exclusive with [subtitleText].
  final Widget? subtitle;

  /// A subtitle as text, kept to one line and ellipsized.
  final String? subtitleText;

  /// A label that replaces [titleText] for screen readers.
  final String? titleSemanticsLabel;

  /// The widget before the title.
  ///
  /// When `null`, a back button or drawer button is implied as in [AppBar],
  /// unless [automaticallyImplyLeading] is `false`.
  final Widget? leading;

  /// Whether to imply a back or drawer button when [leading] is `null`.
  final bool automaticallyImplyLeading;

  /// Overrides the back button behavior.
  ///
  /// When set and [leading] is `null`, a back button is always shown and
  /// calls this instead of popping the route. Use it for nested navigation
  /// or to confirm before leaving a page. It does not intercept the system
  /// back gesture or button; use [PopScope] for that.
  final VoidCallback? onBackPressed;

  /// A logo or image shown before the title. Its size is limited to fit the
  /// toolbar.
  final Widget? logo;

  /// A profile avatar.
  ///
  /// [StudioAppBarStyle.profile] places it in the leading slot unless a back
  /// or drawer button is implied (or [leading] or [onBackPressed] is set);
  /// otherwise, and for other styles, it is placed after the actions.
  final Widget? profile;

  /// Widgets after the title, typically [StudioAction]s.
  ///
  /// [StudioAction]s with a tooltip may move into an overflow menu on narrow
  /// widths. Other widgets always stay visible.
  final List<Widget> actions;

  /// The maximum number of action slots, including the overflow button.
  ///
  /// `null` computes it from the available width.
  final int? maxVisibleActions;

  /// The tooltip of the overflow menu button. Override it to localize.
  final String overflowTooltip;

  /// Adds a search field. See the class documentation for its placement.
  final StudioAppBarSearch? search;

  /// The background color. Ignored when a [gradient] or [backgroundImage]
  /// covers the bar.
  final Color? backgroundColor;

  /// The color of the title, icons and actions.
  final Color? foregroundColor;

  /// A background gradient. Applies to any style.
  final Gradient? gradient;

  /// A background image, drawn with `BoxFit.cover` under a scrim. Applies to
  /// any style. With [StudioAppBarStyle.image], a neutral dark color is shown
  /// until the image is provided and while it loads.
  final ImageProvider? backgroundImage;

  /// The scrim over [backgroundImage], which keeps foreground content
  /// legible. Defaults to 40% black. Use [Colors.transparent] to disable.
  final Color? imageScrimColor;

  /// The resting elevation.
  final double? elevation;

  /// The elevation when content scrolls underneath.
  final double? scrolledUnderElevation;

  /// The shadow color.
  final Color? shadowColor;

  /// The toolbar height at the default text scale. Defaults to the style's
  /// height: 56 for [StudioAppBarStyle.minimal], 72 for
  /// [StudioAppBarStyle.profile] and 64 otherwise.
  final double? height;

  /// The minimum toolbar height. Defaults to 48, the minimum touch target.
  final double minHeight;

  /// Whether the toolbar grows with the system text scale when hosted in a
  /// `ScaffoldStudio`.
  final bool adaptiveHeight;

  /// Rounds the bar's corners. Applies to any style;
  /// [StudioAppBarStyle.rounded] defaults to 24-pixel bottom corners.
  final BorderRadiusGeometry? borderRadius;

  /// Whether to center the title. Defaults to the style.
  final bool? centerTitle;

  /// The title text style.
  final TextStyle? titleTextStyle;

  /// Horizontal space around the title.
  final double? titleSpacing;

  /// The width of the leading slot. Defaults to 56, or wider for a profile
  /// avatar.
  final double? leadingWidth;

  /// Extra horizontal space between actions.
  final double actionSpacing;

  /// Padding around the actions.
  final EdgeInsetsGeometry? actionsPadding;

  /// The status bar style. Defaults to one that contrasts with the bar.
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Whether the bar sits at the top of the screen and pads for the status
  /// bar and display cutouts.
  final bool primary;

  /// A widget below the toolbar, such as a [TabBar].
  final PreferredSizeWidget? bottom;

  /// The toolbar height before text scaling.
  double get baseToolbarHeight =>
      math.max(minHeight, height ?? AppBarStyleSpec.defaultHeight(style));

  @override
  Size get preferredSize =>
      Size.fromHeight(baseToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  State<StudioAppBar> createState() => _StudioAppBarState();
}

class _StudioAppBarState extends State<StudioAppBar> {
  bool _searchOpen = false;

  void _openSearch() => setState(() => _searchOpen = true);

  void _closeSearch() => setState(() => _searchOpen = false);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return _buildBar(context, width);
      },
    );
  }

  Widget _buildBar(BuildContext context, double width) {
    final ThemeData theme = Theme.of(context);
    final StudioThemeData tokens = StudioThemeData.of(context);
    final StudioWindowSize windowSize = tokens.breakpoints.sizeFor(width);
    final StudioAppBarStyle style = widget.style;
    final AppBarStyleSpec spec = AppBarStyleSpec.resolve(
      style,
      theme.colorScheme,
    );

    final double toolbarHeight =
        AppBarHeightScope.maybeOf(context) ?? widget.baseToolbarHeight;

    final ImageProvider? image = widget.backgroundImage;
    final Gradient? gradient = widget.gradient ?? spec.gradient;
    final bool hasImage = image != null;
    final Color? foreground =
        widget.foregroundColor ??
        (hasImage ? Colors.white : null) ??
        spec.foregroundColor;
    final Color? background = (hasImage || gradient != null)
        ? Colors.transparent
        : widget.backgroundColor ?? spec.backgroundColor;

    // Search placement.
    final StudioAppBarSearch? search = widget.search;
    final bool isSearchStyle = style == StudioAppBarStyle.search;
    final bool collapsibleSearch =
        search != null && !isSearchStyle && windowSize.isCompact;
    final bool searchOpen = collapsibleSearch && _searchOpen;

    // Leading. A back or drawer button that AppBar would imply takes
    // precedence over a leading profile avatar, so pushed routes stay
    // dismissible; the avatar then moves to the actions.
    final bool impliedButton =
        widget.automaticallyImplyLeading &&
        ((ModalRoute.of(context)?.impliesAppBarDismissal ?? false) ||
            (Scaffold.maybeOf(context)?.hasDrawer ?? false));
    final bool profileLeads =
        spec.profileLeads &&
        widget.profile != null &&
        widget.leading == null &&
        widget.onBackPressed == null &&
        !impliedButton;
    Widget? leading = widget.leading;
    bool implyLeading = widget.automaticallyImplyLeading;
    Widget? inlineLeading;
    double? leadingWidth = widget.leadingWidth;
    if (searchOpen) {
      leading = IconButton(
        icon: const BackButtonIcon(),
        tooltip: search.closeTooltip,
        onPressed: _closeSearch,
      );
    } else if (spec.inlineLeading && leading != null) {
      inlineLeading = leading;
      leading = null;
      implyLeading = false;
    } else if (profileLeads) {
      leading = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: Center(child: widget.profile),
      );
      leadingWidth ??= 64;
    } else if (leading == null && widget.onBackPressed != null) {
      leading = BackButton(onPressed: widget.onBackPressed);
    }

    // Title.
    final Widget? title = searchOpen
        ? SearchField(config: search)
        : _buildTitle(
            context,
            spec: spec,
            windowSize: windowSize,
            inlineLeading: inlineLeading,
          );

    // Actions.
    final List<Widget> actions = <Widget>[
      if (collapsibleSearch && !searchOpen)
        IconButton(
          icon: Icon(search.leadingIcon),
          tooltip: search.openTooltip,
          onPressed: _openSearch,
        ),
      if (!searchOpen) ...widget.actions,
      if (!searchOpen && widget.profile != null && !profileLeads)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, end: 8),
          child: Center(child: widget.profile),
        ),
    ];
    final bool hasLeading =
        leading != null ||
        inlineLeading != null ||
        (implyLeading && impliedButton);
    final int capacity =
        widget.maxVisibleActions ??
        _actionCapacity(
          width: width,
          hasLeading: hasLeading,
          // An inline leading widget has no fixed width; budget up to a third
          // of the bar for it.
          leadingWidth:
              leadingWidth ??
              (inlineLeading != null ? width / 3 : kToolbarHeight),
          hasSearchInTitle: search != null && !collapsibleSearch,
        );
    List<Widget> visibleActions = layoutActions(
      actions: actions,
      capacity: capacity,
      overflowTooltip: widget.overflowTooltip,
    );
    if (widget.actionSpacing > 0) {
      visibleActions = <Widget>[
        for (final Widget action in visibleActions)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.actionSpacing / 2),
            child: action,
          ),
      ];
    }

    // Background and shape.
    final BorderRadiusGeometry? radius =
        widget.borderRadius ??
        (spec.bottomRadius > 0
            ? BorderRadius.vertical(bottom: Radius.circular(spec.bottomRadius))
            : null);
    final ShapeBorder? shape = radius == null
        ? null
        : RoundedRectangleBorder(borderRadius: radius);
    final Widget? flexibleSpace = _buildBackground(
      gradient: gradient,
      image: image,
      scrim: widget.imageScrimColor ?? spec.imageScrim ?? Colors.black45,
      fallbackColor: widget.backgroundColor ?? spec.backgroundColor,
    );

    final TextStyle? titleStyle =
        widget.titleTextStyle ??
        (spec.compactTitle ? theme.textTheme.titleMedium : null)?.copyWith(
          color: foreground,
        );

    return AppBar(
      leading: leading,
      automaticallyImplyLeading: implyLeading,
      leadingWidth: leadingWidth,
      title: title,
      actions: visibleActions,
      actionsPadding: widget.actionsPadding,
      flexibleSpace: flexibleSpace,
      bottom: widget.bottom,
      elevation: widget.elevation ?? spec.elevation,
      scrolledUnderElevation:
          widget.scrolledUnderElevation ?? spec.scrolledUnderElevation,
      shadowColor: widget.shadowColor,
      surfaceTintColor: Colors.transparent,
      backgroundColor: background,
      foregroundColor: foreground,
      centerTitle: searchOpen ? false : widget.centerTitle ?? spec.centerTitle,
      titleSpacing:
          widget.titleSpacing ??
          (inlineLeading != null || searchOpen ? 16 : null),
      toolbarHeight: toolbarHeight,
      titleTextStyle: titleStyle,
      systemOverlayStyle:
          widget.systemOverlayStyle ??
          _overlayStyleFor(
            foreground: foreground,
            background: background,
            theme: theme,
          ),
      primary: widget.primary,
      shape: shape,
      clipBehavior: shape != null && flexibleSpace != null
          ? Clip.antiAlias
          : null,
    );
  }

  Widget? _buildTitle(
    BuildContext context, {
    required AppBarStyleSpec spec,
    required StudioWindowSize windowSize,
    required Widget? inlineLeading,
  }) {
    final StudioAppBarSearch? search = widget.search;
    final bool centered = widget.centerTitle ?? spec.centerTitle;
    final Widget? titleBlock = _buildTitleBlock(centered: centered);

    Widget? content = titleBlock;
    final Widget? logo = widget.logo;
    if (logo != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, maxWidth: 160),
            child: logo,
          ),
          if (titleBlock != null) ...<Widget>[
            const SizedBox(width: 12),
            Flexible(child: titleBlock),
          ],
        ],
      );
    }

    if (search != null) {
      final bool showTitle =
          content != null &&
          (widget.style != StudioAppBarStyle.search ||
              windowSize.isMediumOrLarger);
      // Compact non-search styles show a search button instead (see build).
      final bool showField =
          widget.style == StudioAppBarStyle.search ||
          windowSize.isMediumOrLarger;
      if (showField) {
        content = Row(
          children: <Widget>[
            if (showTitle) ...<Widget>[
              Flexible(child: content),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SearchField(config: search),
              ),
            ),
          ],
        );
      }
    }

    if (inlineLeading != null) {
      content = Row(
        mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
        children: <Widget>[
          // Flexible so that a wide leading widget shares the space with
          // the title instead of overflowing. Text inside it should be
          // Flexible or ellipsized to shrink gracefully.
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 48),
              child: inlineLeading,
            ),
          ),
          if (content != null) ...<Widget>[
            const SizedBox(width: 12),
            Flexible(child: content),
          ],
        ],
      );
    }
    return content;
  }

  Widget? _buildTitleBlock({required bool centered}) {
    final String? titleText = widget.titleText;
    final String? subtitleText = widget.subtitleText;
    final Widget? title =
        widget.title ??
        (titleText == null
            ? null
            : Text(
                titleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                semanticsLabel: widget.titleSemanticsLabel,
              ));
    final Widget? subtitle =
        widget.subtitle ??
        (subtitleText == null
            ? null
            : Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis));
    if (subtitle == null) {
      return title;
    }
    // Both lines are Flexible so that at very large text scales they are
    // clipped inside the toolbar instead of overflowing it.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null) Flexible(flex: 2, child: title),
        Flexible(child: _SubtitleStyle(child: subtitle)),
      ],
    );
  }

  Widget? _buildBackground({
    required Gradient? gradient,
    required ImageProvider? image,
    required Color scrim,
    required Color? fallbackColor,
  }) {
    if (image == null && gradient == null) {
      return null;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: image != null ? fallbackColor : null,
        gradient: gradient,
        image: image == null
            ? null
            : DecorationImage(
                image: image,
                fit: BoxFit.cover,
                colorFilter: scrim.a == 0
                    ? null
                    : ColorFilter.mode(scrim, BlendMode.srcATop),
              ),
      ),
    );
  }

  /// Estimates how many action slots fit while leaving the title usable.
  int _actionCapacity({
    required double width,
    required bool hasLeading,
    required double leadingWidth,
    required bool hasSearchInTitle,
  }) {
    if (!width.isFinite) {
      return widget.actions.length + 2;
    }
    final double reservedForTitle = hasSearchInTitle
        ? math.max(220, width * 0.45)
        : math.max(120, width * 0.4);
    final double available =
        width - (hasLeading ? leadingWidth : 16) - reservedForTitle - 16;
    final double slot = kActionExtent + widget.actionSpacing;
    return math.max(1, (available / slot).floor());
  }

  SystemUiOverlayStyle? _overlayStyleFor({
    required Color? foreground,
    required Color? background,
    required ThemeData theme,
  }) {
    // AppBar derives a good default from an opaque background. Only step in
    // when the background is transparent, a gradient or an image, where the
    // foreground color is the reliable signal.
    if (background != null && background.a == 1) {
      return null;
    }
    final Color reference = foreground ?? theme.colorScheme.onSurface;
    final bool lightForeground =
        ThemeData.estimateBrightnessForColor(reference) == Brightness.light;
    final SystemUiOverlayStyle base = lightForeground
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return base.copyWith(statusBarColor: Colors.transparent);
  }
}

/// Applies the subtitle style. Built inside the [AppBar] so that it can
/// inherit the app bar's foreground color from the title text style.
class _SubtitleStyle extends StatelessWidget {
  const _SubtitleStyle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextStyle inherited = DefaultTextStyle.of(context).style;
    final TextStyle style =
        (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
          color: inherited.color?.withValues(alpha: 0.8),
        );
    return DefaultTextStyle.merge(
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: child,
    );
  }
}
