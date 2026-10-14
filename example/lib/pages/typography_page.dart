// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import '../settings.dart';
import '../widgets/showcase_widgets.dart';

/// Demonstrates `CommonHeaderText`, `CommonBodyText` and `CommonLabelText`:
/// plain text, links, style customization, per-widget fonts and overflow.
class TypographyPage extends StatelessWidget {
  /// Creates the page.
  const TypographyPage({super.key});

  static const String _longText =
      'This is a deliberately long sentence that keeps going so that it '
      'cannot fit on a single line of a phone screen, which shows how '
      'maxLines and the ellipsis keep the layout tidy instead of overflowing.';

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final StudioFont appFont = ShowcaseScope.of(context).settings.font;
    void tapped(String what) => showDemoSnackBar(context, '$what tapped');

    return ShowcasePage(
      children: <Widget>[
        const ObserveNote(
          'Every interactive text below is keyboard accessible: press Tab to '
          'move focus to a link (a focus ring appears), then Enter or Space '
          'to activate it.',
          icon: Icons.keyboard,
        ),
        const ShowcaseSection(
          title: 'Header text',
          description:
              'CommonHeaderText uses a semibold titleLarge, is announced as '
              'a heading and ellipsizes after maxLines.',
          child: CommonHeaderText(
            'Hi Avinash, how are you?',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            maxLines: 2,
          ),
        ),
        ShowcaseSection(
          title: 'Links',
          description:
              'link: true applies the theme link color and an underline. '
              'underline: false keeps the color, focus and semantics.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CommonHeaderText(
                'View profile',
                link: true,
                onTap: () => tapped('"View profile"'),
              ),
              CommonHeaderText(
                'Edit preferences (no underline)',
                link: true,
                underline: false,
                onTap: () => tapped('"Edit preferences"'),
              ),
              CommonBodyText(
                'Read the terms of service (dotted underline)',
                link: true,
                underlineStyle: TextDecorationStyle.dotted,
                onTap: () => tapped('"Terms of service"'),
              ),
              CommonLabelText(
                'See all',
                link: true,
                onTap: () => tapped('"See all"'),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Size, weight and color',
          description:
              'Individual arguments win over the themed role style and the '
              'style argument.',
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              const CommonHeaderText('14', fontSize: 14),
              const CommonHeaderText('20', fontSize: 20),
              const CommonHeaderText('28', fontSize: 28),
              const CommonHeaderText('Light', fontWeight: FontWeight.w300),
              const CommonHeaderText('Regular', fontWeight: FontWeight.w400),
              const CommonHeaderText('Bold', fontWeight: FontWeight.w700),
              CommonHeaderText('Primary', color: scheme.primary),
              CommonHeaderText('Tertiary', color: scheme.tertiary),
              CommonHeaderText('Error', color: scheme.error),
              const CommonBodyText('Italic', fontStyle: FontStyle.italic),
              const CommonBodyText('Spaced out', letterSpacing: 3),
              const CommonBodyText(
                'Struck through',
                decoration: TextDecoration.lineThrough,
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Per-widget font',
          description:
              'The app font is ${appFont.displayName} (change it in '
              'Settings). fontFamily overrides it for one widget; '
              'StudioFont.system restores the platform font even when the '
              'app uses Roboto.',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: <Widget>[
              CommonHeaderText(
                'Bundled Roboto (StudioFont.roboto)',
                fontFamily: StudioFont.roboto,
                maxLines: 2,
              ),
              CommonHeaderText(
                'Platform font (StudioFont.system)',
                fontFamily: StudioFont.system,
                maxLines: 2,
              ),
              CommonBodyText(
                'Roboto bundles weights 300, 400, 500 and 700. Other weights, '
                'such as w600, use the nearest bundled face.',
                fontFamily: StudioFont.roboto,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Body and label text',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: <Widget>[
              const CommonBodyText(
                'CommonBodyText is for running text. It wraps by default and '
                'never overflows horizontally, so it adapts to any width and '
                'any text scale.',
              ),
              CommonLabelText(
                'CommonLabelText - updated 2 min ago',
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const ShowcaseSection(
          title: 'Overflow',
          description:
              'With maxLines set, overflowing text is ellipsized '
              'automatically.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              CommonLabelText('maxLines: 1'),
              CommonBodyText(_longText, maxLines: 1),
              CommonLabelText('maxLines: 2'),
              CommonBodyText(_longText, maxLines: 2),
            ],
          ),
        ),
      ],
    );
  }
}
