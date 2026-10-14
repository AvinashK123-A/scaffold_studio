// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import '../widgets/showcase_widgets.dart';
import 'app_bar_demo_page.dart';

/// A display name for [style].
String appBarStyleName(StudioAppBarStyle style) => switch (style) {
  StudioAppBarStyle.standard => 'Standard',
  StudioAppBarStyle.centered => 'Centered',
  StudioAppBarStyle.minimal => 'Minimal',
  StudioAppBarStyle.transparent => 'Transparent',
  StudioAppBarStyle.gradient => 'Gradient',
  StudioAppBarStyle.image => 'Image',
  StudioAppBarStyle.rounded => 'Rounded',
  StudioAppBarStyle.search => 'Search',
  StudioAppBarStyle.profile => 'Profile',
  StudioAppBarStyle.flexible => 'Flexible',
};

/// A one-line description of what the demo for [style] shows.
String appBarStyleSummary(StudioAppBarStyle style) => switch (style) {
  StudioAppBarStyle.standard =>
    'Logo, notification badge, many actions and a profile avatar.',
  StudioAppBarStyle.centered =>
    'Centered title and a custom back handler (onBackPressed).',
  StudioAppBarStyle.minimal => 'A quiet bar with a smaller title.',
  StudioAppBarStyle.transparent =>
    'Content extends behind a fully transparent bar.',
  StudioAppBarStyle.gradient => 'Primary-to-tertiary gradient background.',
  StudioAppBarStyle.image => 'A runtime-generated image under a scrim.',
  StudioAppBarStyle.rounded => 'Tonal surface with rounded bottom corners.',
  StudioAppBarStyle.search => 'A search field that filters the page.',
  StudioAppBarStyle.profile => 'Greeting header led by the profile avatar.',
  StudioAppBarStyle.flexible =>
    'Custom widgets: avatar with name, custom title and actions.',
};

/// The icon used for [style] in the list.
IconData appBarStyleIcon(StudioAppBarStyle style) => switch (style) {
  StudioAppBarStyle.standard => Icons.web_asset,
  StudioAppBarStyle.centered => Icons.format_align_center,
  StudioAppBarStyle.minimal => Icons.minimize,
  StudioAppBarStyle.transparent => Icons.layers_clear_outlined,
  StudioAppBarStyle.gradient => Icons.gradient,
  StudioAppBarStyle.image => Icons.image_outlined,
  StudioAppBarStyle.rounded => Icons.rounded_corner,
  StudioAppBarStyle.search => Icons.search,
  StudioAppBarStyle.profile => Icons.account_circle_outlined,
  StudioAppBarStyle.flexible => Icons.view_column_outlined,
};

/// Lists every [StudioAppBarStyle]; tapping one opens a full demo page.
class AppBarsPage extends StatelessWidget {
  /// Creates the page.
  const AppBarsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ShowcasePage(
      children: <Widget>[
        const ObserveNote(
          'Open a style, then resize the window or rotate the device: '
          'actions collapse into a "More options" menu on narrow widths, '
          'titles ellipsize, and the bar grows with large text.',
        ),
        for (final StudioAppBarStyle style in StudioAppBarStyle.values)
          CommonCard(
            key: ValueKey<String>('app-bar-style-${style.name}'),
            semanticsLabel: '${appBarStyleName(style)} app bar demo',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => AppBarDemoPage(style: style),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(appBarStyleIcon(style), color: scheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CommonHeaderText(
                        appBarStyleName(style),
                        fontSize: 16,
                        maxLines: 1,
                      ),
                      CommonBodyText(
                        appBarStyleSummary(style),
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
      ],
    );
  }
}
