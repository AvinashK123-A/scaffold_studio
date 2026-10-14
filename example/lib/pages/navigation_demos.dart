// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import '../widgets/showcase_widgets.dart';

/// Sample destinations for the navigation demos. Inbox, Chat and Alerts
/// carry badges: a count, a count above 99 and a dot.
const List<StudioNavItem> demoNavItems = <StudioNavItem>[
  StudioNavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Home',
  ),
  StudioNavItem(
    icon: Icons.inbox_outlined,
    selectedIcon: Icons.inbox,
    label: 'Inbox',
    badgeCount: 4,
  ),
  StudioNavItem(icon: Icons.search, label: 'Search'),
  StudioNavItem(
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
    label: 'Chat',
    badgeCount: 120,
  ),
  StudioNavItem(
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
    label: 'Alerts',
    badge: '',
  ),
  StudioNavItem(
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Profile',
  ),
  StudioNavItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Settings',
  ),
];

/// The first [count] sample destinations.
List<StudioNavItem> demoNavItemsFor(int count) =>
    demoNavItems.take(count).toList(growable: false);

/// A display name for [style].
String bottomBarStyleName(StudioBottomBarStyle style) => switch (style) {
  StudioBottomBarStyle.material => 'Material',
  StudioBottomBarStyle.floating => 'Floating',
  StudioBottomBarStyle.rounded => 'Rounded',
  StudioBottomBarStyle.minimal => 'Minimal',
  StudioBottomBarStyle.labeled => 'Labeled',
  StudioBottomBarStyle.animated => 'Animated',
  StudioBottomBarStyle.notched => 'Notched',
};

/// A display name for [behavior]; `null` is the style default.
String labelBehaviorName(StudioNavLabelBehavior? behavior) =>
    switch (behavior) {
      null => 'Style default',
      StudioNavLabelBehavior.alwaysShow => 'Always',
      StudioNavLabelBehavior.onlySelected => 'Selected only',
      StudioNavLabelBehavior.never => 'Never',
    };

String _modeName(StudioNavigationMode mode) => switch (mode) {
  StudioNavigationMode.adaptive => 'Adaptive',
  StudioNavigationMode.bottomBar => 'Bottom bar',
  StudioNavigationMode.rail => 'Rail',
  StudioNavigationMode.sidebar => 'Sidebar',
  StudioNavigationMode.drawer => 'Drawer',
};

/// A sidebar and drawer header for the demos.
class _DemoNavHeader extends StatelessWidget {
  const _DemoNavHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 16, 16, 12),
      child: Row(
        children: <Widget>[
          DemoAvatar(radius: 20),
          SizedBox(width: 12),
          Expanded(
            child: CommonHeaderText('Avinash', fontSize: 16, maxLines: 1),
          ),
        ],
      ),
    );
  }
}

StudioAction _closeAction(BuildContext context) => StudioAction(
  icon: Icons.close,
  tooltip: 'Close demo',
  onPressed: () => Navigator.of(context).maybePop(),
);

/// The body shown for a selected demo destination.
class _DestinationBody extends StatelessWidget {
  const _DestinationBody({
    required this.item,
    required this.explanation,
    this.extra = const <Widget>[],
  });

  final StudioNavItem? item;
  final String explanation;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final StudioNavItem? item = this.item;
    return ShowcasePage(
      children: <Widget>[
        ObserveNote(explanation),
        ...extra,
        CommonCard(
          variant: CommonCardVariant.filled,
          child: Column(
            children: <Widget>[
              Icon(
                item?.selectedIcon ?? item?.icon ?? Icons.block,
                size: 48,
                color: scheme.primary,
              ),
              const SizedBox(height: 8),
              CommonHeaderText(
                item?.label ?? 'Nothing selected',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const CommonBodyText(
                'Destination content goes here. Switch destinations and resize '
                'the window: the selection is kept.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A [ScaffoldStudio] whose navigation is fixed to one [mode].
class FixedNavigationDemo extends StatefulWidget {
  /// Creates a fixed-mode demo.
  const FixedNavigationDemo({
    super.key,
    required this.mode,
    this.bottomBarStyle = StudioBottomBarStyle.material,
    this.labelBehavior,
    this.itemCount = 5,
  });

  /// The fixed navigation presentation.
  final StudioNavigationMode mode;

  /// The bottom bar style, used when [mode] is a bottom bar.
  final StudioBottomBarStyle bottomBarStyle;

  /// The bottom bar label behavior; `null` uses the style default.
  final StudioNavLabelBehavior? labelBehavior;

  /// The number of destinations.
  final int itemCount;

  @override
  State<FixedNavigationDemo> createState() => _FixedNavigationDemoState();
}

class _FixedNavigationDemoState extends State<FixedNavigationDemo> {
  int _index = 0;

  String get _notchNote => widget.bottomBarStyle == StudioBottomBarStyle.notched
      ? ' The floating action button docks into the notch.'
      : '';

  String get _explanation => switch (widget.mode) {
    StudioNavigationMode.bottomBar =>
      'This shell is fixed to a ${bottomBarStyleName(widget.bottomBarStyle)} '
          'bottom bar (StudioNavigationMode.bottomBar), even on wide windows. '
          'When the destinations do not fit, the trailing ones move into '
          '"More".$_notchNote',
    StudioNavigationMode.rail =>
      'A fixed navigation rail. The floating action button moves to the top '
          'of the rail, and the rail scrolls when its destinations do not '
          'fit, for example on a phone in landscape.',
    StudioNavigationMode.sidebar =>
      'A fixed sidebar with a header and a footer. This demo narrows it on '
          'small windows through sidebarWidth so the content keeps room.',
    StudioNavigationMode.drawer =>
      'The destinations live in a modal drawer: open it with the menu button '
          'in the app bar. Choosing a destination closes the drawer.',
    StudioNavigationMode.adaptive =>
      'Adaptive navigation: resize the window to switch layouts.',
  };

  @override
  Widget build(BuildContext context) {
    final List<StudioNavItem> items = demoNavItemsFor(widget.itemCount);
    final double width = MediaQuery.sizeOf(context).width;
    final int index = _index < items.length ? _index : 0;
    return ScaffoldStudio(
      appBar: StudioAppBar(
        titleText: '${_modeName(widget.mode)} demo',
        subtitleText: items[index].label,
        actions: <Widget>[_closeAction(context)],
      ),
      navigation: StudioNavigation(
        mode: widget.mode,
        items: items,
        selectedIndex: index,
        onSelected: (int value) => setState(() => _index = value),
        bottomBarStyle: widget.bottomBarStyle,
        labelBehavior: widget.labelBehavior,
        sidebarHeader: const _DemoNavHeader(),
        sidebarFooter: const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 16, 16),
          child: CommonLabelText('Signed in as Avinash', maxLines: 2),
        ),
        sidebarWidth: (width * 0.6).clamp(160.0, 280.0),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'navigation-demo-fab',
        tooltip: 'Compose',
        onPressed: () => showDemoSnackBar(context, 'Compose pressed'),
        child: const Icon(Icons.edit_outlined),
      ),
      body: _DestinationBody(item: items[index], explanation: _explanation),
    );
  }
}

/// A shell whose selection is owned by a [StudioNavigationController] and
/// whose body comes from [ScaffoldStudio.bodyBuilder].
class ControllerNavigationDemo extends StatefulWidget {
  /// Creates the demo.
  const ControllerNavigationDemo({super.key});

  @override
  State<ControllerNavigationDemo> createState() =>
      _ControllerNavigationDemoState();
}

class _ControllerNavigationDemoState extends State<ControllerNavigationDemo> {
  // Created and owned here, so it must be disposed here.
  final StudioNavigationController _controller = StudioNavigationController();
  final List<StudioNavItem> _items = demoNavItemsFor(5);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This build runs once: taps update the controller, and ScaffoldStudio
    // and the widgets below listen to it. No setState is involved.
    return ScaffoldStudio(
      appBar: StudioAppBar(
        titleText: 'Controller demo',
        subtitle: ValueListenableBuilder<int>(
          valueListenable: _controller,
          builder: (BuildContext context, int index, Widget? child) => Text(
            index >= 0 && index < _items.length
                ? 'controller.index = $index (${_items[index].label})'
                : 'Nothing selected',
          ),
        ),
        actions: <Widget>[_closeAction(context)],
      ),
      navigation: StudioNavigation(
        items: _items,
        controller: _controller,
        sidebarHeader: const _DemoNavHeader(),
      ),
      bodyBuilder: (BuildContext context, int index) => _DestinationBody(
        item: index >= 0 ? _items[index] : null,
        explanation:
            'StudioNavigationController owns the selection and bodyBuilder '
            'builds the body for it. Resize the window: the bottom bar, rail '
            'and sidebar all follow the same controller.',
        extra: <Widget>[
          ShowcaseSection(
            title: 'Select from code',
            description: 'These buttons call controller.select(index).',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (int i = 0; i < _items.length; i++)
                  CommonButton(
                    label: 'Go to ${_items[i].label}',
                    size: CommonButtonSize.small,
                    variant: i == index
                        ? CommonButtonVariant.filled
                        : CommonButtonVariant.outlined,
                    onPressed: () => _controller.select(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
