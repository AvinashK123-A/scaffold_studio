// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// @docImport '../responsive/studio_responsive_builder.dart';
library;

import 'package:flutter/material.dart';

import '../app_bar/internal/app_bar_height_scope.dart';
import '../app_bar/studio_app_bar.dart';
import '../navigation/internal/nav_utils.dart';
import '../navigation/studio_bottom_bar.dart';
import '../navigation/studio_bottom_bar_style.dart';
import '../navigation/studio_nav_item.dart';
import '../navigation/studio_navigation.dart';
import '../navigation/studio_navigation_rail.dart';
import '../navigation/studio_sidebar.dart';
import '../responsive/studio_breakpoints.dart';
import '../theme/studio_theme_data.dart';

/// Builds the body for the selected destination.
///
/// [selectedIndex] is `-1` when no valid destination is selected.
typedef StudioBodyBuilder =
    Widget Function(BuildContext context, int selectedIndex);

/// A responsive application shell built on [Scaffold].
///
/// Combines an app bar, body, adaptive navigation, drawers and a floating
/// action button. Every part is optional.
///
/// ```dart
/// ScaffoldStudio(
///   appBar: const StudioAppBar(titleText: 'Inbox'),
///   navigation: StudioNavigation(
///     items: destinations,
///     selectedIndex: index,
///     onSelected: (i) => setState(() => index = i),
///   ),
///   body: pages[index],
/// )
/// ```
///
/// ## What the shell controls
///
/// * **Navigation layout.** The available width (from the parent's
///   constraints, so split screen and resizable windows work) is mapped to a
///   [StudioWindowSize]; [StudioNavigation.modeFor] picks a bottom bar, rail,
///   sidebar or drawer. The selection is preserved across switches.
/// * **Content width.** On wide layouts the body is limited to
///   [contentMaxWidth] and aligned by [contentAlignment] instead of being
///   stretched edge to edge.
/// * **Safe areas.** With [useSafeArea], the body avoids system bars,
///   display cutouts and the floating bottom bar. The app bar and bottom bar
///   handle their own insets.
/// * **Keyboard.** The body resizes for the on-screen keyboard (see
///   [resizeToAvoidBottomInset]), and the bottom bar hides while the keyboard
///   is visible unless [StudioNavigation.hideBottomBarOnKeyboard] is `false`.
/// * **App bar height.** A [StudioAppBar] grows with the system text scale.
///
/// ## What your body controls
///
/// The shell does not make the body itself responsive. Your body should
/// scroll when its content can be taller than the screen, avoid fixed
/// widths, and use [StudioResponsiveBuilder] or [LayoutBuilder] to change its
/// own structure (for example, the number of grid columns). It also does not
/// preserve page state between destinations; see [StudioNavigation].
class ScaffoldStudio extends StatelessWidget {
  /// Creates an application shell.
  const ScaffoldStudio({
    super.key,
    this.appBar,
    this.body,
    this.bodyBuilder,
    this.navigation,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.backgroundDecoration,
    this.bodyPadding,
    this.contentMaxWidth,
    this.contentAlignment = Alignment.topCenter,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.extendBody,
    this.extendBodyBehindAppBar = false,
    this.breakpoints,
    this.scaffoldKey,
    this.bottomSheet,
    this.persistentFooterButtons,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.drawerEnableOpenDragGesture = true,
    this.restorationId,
  }) : assert(
         body == null || bodyBuilder == null,
         'Provide either body or bodyBuilder, not both.',
       );

  /// The top app bar. A [StudioAppBar] gets text-scale-aware height; any
  /// other [PreferredSizeWidget] is used as is.
  final PreferredSizeWidget? appBar;

  /// The primary content.
  final Widget? body;

  /// Builds the body from the selected destination. Useful together with a
  /// [StudioNavigation.controller]. Mutually exclusive with [body].
  final StudioBodyBuilder? bodyBuilder;

  /// Adaptive navigation. `null` shows no navigation.
  final StudioNavigation? navigation;

  /// The floating action button. When the rail is shown it moves to the top
  /// of the rail (see [StudioNavigation.floatingActionButtonInRail]).
  final Widget? floatingActionButton;

  /// Where the floating action button sits. Defaults to center-docked with a
  /// [StudioBottomBarStyle.notched] bar, and to the [Scaffold] default
  /// otherwise.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// A drawer on the start side.
  ///
  /// When provided, it takes the place of the navigation drawer that
  /// [StudioNavigationMode.drawer] would otherwise create, so include your
  /// own destinations.
  final Widget? drawer;

  /// A drawer on the end side.
  final Widget? endDrawer;

  /// The scaffold color. Defaults to [ThemeData.scaffoldBackgroundColor].
  final Color? backgroundColor;

  /// A decoration painted behind the body, such as a gradient or image.
  final Decoration? backgroundDecoration;

  /// Padding around the body, inside the safe area and width constraint.
  final EdgeInsetsGeometry? bodyPadding;

  /// The maximum body width. Defaults to [StudioThemeData.contentMaxWidth].
  /// Use [double.infinity] to stretch edge to edge.
  final double? contentMaxWidth;

  /// Where the body sits when narrower than the available width.
  final AlignmentGeometry contentAlignment;

  /// Whether the body avoids system UI and cutouts.
  final bool useSafeArea;

  /// Whether the body shrinks when the on-screen keyboard appears.
  final bool resizeToAvoidBottomInset;

  /// Whether the body extends behind the bottom bar. Defaults to `true` for
  /// [StudioBottomBarStyle.floating] and `false` otherwise.
  final bool? extendBody;

  /// Whether the body extends behind the app bar, for example with a
  /// transparent or image app bar.
  final bool extendBodyBehindAppBar;

  /// Overrides [StudioThemeData.breakpoints] for this shell.
  final StudioBreakpoints? breakpoints;

  /// A key for the underlying [Scaffold], to open drawers programmatically.
  final GlobalKey<ScaffoldState>? scaffoldKey;

  /// A persistent bottom sheet.
  final Widget? bottomSheet;

  /// Buttons shown at the bottom of the scaffold.
  final List<Widget>? persistentFooterButtons;

  /// Called when the start drawer opens or closes.
  final DrawerCallback? onDrawerChanged;

  /// Called when the end drawer opens or closes.
  final DrawerCallback? onEndDrawerChanged;

  /// Whether the start drawer can be opened with a drag gesture.
  final bool drawerEnableOpenDragGesture;

  /// The restoration ID of the underlying [Scaffold].
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    final StudioNavigation? navigation = this.navigation;
    final Listenable? controller = navigation?.controller;
    if (controller == null) {
      return _buildLayout(context, navigation?.selectedIndex);
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) =>
          _buildLayout(context, navigation?.controller?.value),
    );
  }

  Widget _buildLayout(BuildContext context, int? rawIndex) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final StudioBreakpoints effectiveBreakpoints =
            breakpoints ?? StudioThemeData.of(context).breakpoints;
        final double width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final StudioWindowSize size = effectiveBreakpoints.sizeFor(width);
        return _buildScaffold(context, size, rawIndex);
      },
    );
  }

  void _select(int index) {
    final StudioNavigation? navigation = this.navigation;
    if (navigation == null ||
        index < 0 ||
        index >= navigation.items.length ||
        !navigation.items[index].enabled) {
      return;
    }
    navigation.controller?.select(index);
    navigation.onSelected?.call(index);
  }

  Widget _buildScaffold(
    BuildContext context,
    StudioWindowSize size,
    int? rawIndex,
  ) {
    // Navigation is only shown when there is at least one destination.
    final StudioNavigation? candidate = navigation;
    final StudioNavigation? nav =
        candidate != null && candidate.items.isNotEmpty ? candidate : null;
    final List<StudioNavItem> items = nav?.items ?? const <StudioNavItem>[];
    final StudioNavigationMode? mode = nav?.modeFor(size);
    final int? selected = validIndex(rawIndex, items.length);

    // Bottom bar.
    Widget? bottomBar;
    bool floatingBar = false;
    bool notchedBar = false;
    final bool keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (nav != null &&
        mode == StudioNavigationMode.bottomBar &&
        !(nav.hideBottomBarOnKeyboard && keyboardVisible)) {
      final StudioBottomBarBuilder? builder = nav.bottomBarBuilder;
      if (builder != null) {
        final Widget custom = builder(context, items, selected, _select);
        if (custom is StudioBottomBar) {
          floatingBar = custom.isFloating;
          notchedBar = custom.hasNotch;
        }
        bottomBar = custom;
      } else {
        floatingBar = nav.bottomBarStyle == StudioBottomBarStyle.floating;
        notchedBar = nav.bottomBarStyle == StudioBottomBarStyle.notched;
        bottomBar = StudioBottomBar(
          items: items,
          selectedIndex: selected,
          onSelected: _select,
          style: nav.bottomBarStyle,
          labelBehavior: nav.labelBehavior,
        );
      }
    }

    // Floating action button placement.
    final Widget? fab = floatingActionButton;
    final bool fabInRail =
        nav != null &&
        mode == StudioNavigationMode.rail &&
        nav.floatingActionButtonInRail &&
        fab != null;
    final FloatingActionButtonLocation? fabLocation =
        floatingActionButtonLocation ??
        (notchedBar && bottomBar != null
            ? FloatingActionButtonLocation.centerDocked
            : null);

    // Side navigation, placed at the start edge.
    Widget? sideNavigation;
    if (nav != null && mode == StudioNavigationMode.rail) {
      sideNavigation = StudioNavigationRail(
        items: items,
        selectedIndex: selected,
        onSelected: _select,
        labelType: nav.railLabelType,
        leading: fabInRail
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ?nav.railLeading,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: fab,
                  ),
                ],
              )
            : nav.railLeading,
        trailing: nav.railTrailing,
      );
    } else if (nav != null && mode == StudioNavigationMode.sidebar) {
      sideNavigation = StudioSidebar(
        items: items,
        selectedIndex: selected,
        onSelected: _select,
        header: nav.sidebarHeader,
        footer: nav.sidebarFooter,
        width: nav.sidebarWidth,
      );
    }

    // Drawer navigation. A drawer supplied by the app takes precedence.
    Widget? effectiveDrawer = drawer;
    if (effectiveDrawer == null &&
        nav != null &&
        mode == StudioNavigationMode.drawer) {
      effectiveDrawer = Builder(
        builder: (BuildContext drawerContext) => StudioSidebar(
          items: items,
          selectedIndex: selected,
          modal: true,
          header: nav.sidebarHeader,
          footer: nav.sidebarFooter,
          onSelected: (int index) {
            Scaffold.maybeOf(drawerContext)?.closeDrawer();
            _select(index);
          },
        ),
      );
    }

    // Body.
    Widget content =
        bodyBuilder?.call(context, selected ?? -1) ??
        body ??
        const SizedBox.shrink();
    final EdgeInsetsGeometry? padding = bodyPadding;
    if (padding != null) {
      content = Padding(padding: padding, child: content);
    }
    content = _constrainWidth(context, content);

    // With side navigation, the navigation pads the start edge for system
    // insets and the body pads the remaining edges.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool navOnLeft = sideNavigation != null && !rtl;
    final bool navOnRight = sideNavigation != null && rtl;
    if (useSafeArea) {
      content = SafeArea(left: !navOnLeft, right: !navOnRight, child: content);
    }
    if (nav != null && sideNavigation != null) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (useSafeArea)
            SafeArea(left: navOnLeft, right: navOnRight, child: sideNavigation)
          else
            sideNavigation,
          if (nav.showDivider) const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      );
    }
    final Decoration? decoration = backgroundDecoration;
    if (decoration != null) {
      content = DecoratedBox(decoration: decoration, child: content);
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: _wrapAppBar(context),
      body: content,
      bottomNavigationBar: bottomBar,
      floatingActionButton: fabInRail ? null : fab,
      floatingActionButtonLocation: fabLocation,
      drawer: effectiveDrawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody ?? floatingBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      bottomSheet: bottomSheet,
      persistentFooterButtons: persistentFooterButtons,
      onDrawerChanged: onDrawerChanged,
      onEndDrawerChanged: onEndDrawerChanged,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }

  Widget _constrainWidth(BuildContext context, Widget child) {
    final double maxWidth =
        contentMaxWidth ?? StudioThemeData.of(context).contentMaxWidth;
    if (maxWidth.isNaN || maxWidth <= 0 || maxWidth.isInfinite) {
      return child;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= maxWidth) {
          return child;
        }
        // Keep the incoming height constraints so that scrollables and
        // full-height layouts behave as they would without the limit.
        return Align(
          alignment: contentAlignment,
          child: ConstrainedBox(
            constraints: constraints.copyWith(
              minWidth: maxWidth,
              maxWidth: maxWidth,
            ),
            child: child,
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _wrapAppBar(BuildContext context) {
    final PreferredSizeWidget? bar = appBar;
    if (bar is! StudioAppBar || !bar.adaptiveHeight) {
      return bar;
    }
    final double toolbarHeight = scaledToolbarHeight(
      baseHeight: bar.baseToolbarHeight,
      minHeight: bar.minHeight,
      textScaler: MediaQuery.textScalerOf(context),
    );
    final double bottomHeight = bar.bottom?.preferredSize.height ?? 0;
    return PreferredSize(
      preferredSize: Size.fromHeight(toolbarHeight + bottomHeight),
      child: AppBarHeightScope(toolbarHeight: toolbarHeight, child: bar),
    );
  }
}
