// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'pages/app_bars_page.dart';
import 'pages/navigation_page.dart';
import 'pages/settings_page.dart';
import 'pages/typography_page.dart';
import 'pages/widgets_page.dart';
import 'settings.dart';
import 'widgets/showcase_widgets.dart';

/// The destinations of the showcase, shared by every navigation layout.
const List<StudioNavItem> showcaseDestinations = <StudioNavItem>[
  StudioNavItem(
    icon: Icons.text_fields_outlined,
    selectedIcon: Icons.text_fields,
    label: 'Typography',
  ),
  StudioNavItem(
    icon: Icons.web_asset_outlined,
    selectedIcon: Icons.web_asset,
    label: 'App bars',
    badgeCount: 10,
  ),
  StudioNavItem(
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
    label: 'Navigation',
    badge: '',
  ),
  StudioNavItem(
    icon: Icons.widgets_outlined,
    selectedIcon: Icons.widgets,
    label: 'Widgets',
  ),
  StudioNavItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Settings',
  ),
];

/// The index of the Settings destination.
const int settingsDestination = 4;

/// The showcase shell: a [ScaffoldStudio] with adaptive navigation.
///
/// Below 600 logical pixels it shows a bottom bar, up to 840 a navigation
/// rail (with the floating action button moved into it) and above that a
/// sidebar. The selected index lives in this state, not in the navigation
/// widgets, so it survives every layout switch while the window is resized.
class ShowcaseHome extends StatefulWidget {
  /// Creates the shell.
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  void _toggleBrightness(BuildContext context) {
    final ShowcaseScope scope = ShowcaseScope.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    scope.onChanged(
      scope.settings.copyWith(
        themeMode: dark ? ThemeMode.light : ThemeMode.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return ScaffoldStudio(
      appBar: StudioAppBar(
        logo: const DemoLogo(),
        titleText: showcaseDestinations[_index].label,
        subtitleText: 'Scaffold Studio showcase',
        actions: <Widget>[
          StudioAction(
            icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () => _toggleBrightness(context),
          ),
          StudioAction(
            icon: Icons.info_outline,
            tooltip: 'About',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Scaffold Studio',
              applicationVersion: 'Showcase',
              applicationIcon: const DemoLogo(size: 40),
              children: const <Widget>[
                CommonBodyText(
                  'A live tour of every scaffold_studio building block. '
                  'Resize the window to watch the navigation adapt.',
                ),
              ],
            ),
          ),
        ],
      ),
      navigation: StudioNavigation(
        items: showcaseDestinations,
        selectedIndex: _index,
        onSelected: _select,
        sidebarHeader: const _SidebarHeader(),
        sidebarFooter: const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 16),
          child: CommonLabelText(
            'Resize the window: sidebar, rail and bottom bar share one '
            'selection.',
            maxLines: 3,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'showcase-fab',
        tooltip: 'Open settings',
        onPressed: _index == settingsDestination
            ? null
            : () => _select(settingsDestination),
        child: const Icon(Icons.tune),
      ),
      // IndexedStack keeps every page mounted and only shows the selected
      // one. ScaffoldStudio deliberately does not preserve page state when
      // the destination changes, so without this each page would be rebuilt
      // from scratch: scroll positions, text field input, toggles and the
      // live navigation preview would all reset on every switch. Hidden
      // pages are excluded from focus traversal, semantics and hit testing.
      body: IndexedStack(
        index: _index,
        children: const <Widget>[
          TypographyPage(key: PageStorageKey<String>('page-typography')),
          AppBarsPage(key: PageStorageKey<String>('page-app-bars')),
          NavigationPage(key: PageStorageKey<String>('page-navigation')),
          WidgetsPage(key: PageStorageKey<String>('page-widgets')),
          SettingsPage(key: PageStorageKey<String>('page-settings')),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 16, 16),
      child: Row(
        children: <Widget>[
          const DemoLogo(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CommonHeaderText(
                  'Scaffold Studio',
                  fontSize: 18,
                  maxLines: 1,
                ),
                CommonLabelText(
                  'Live showcase',
                  maxLines: 1,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
