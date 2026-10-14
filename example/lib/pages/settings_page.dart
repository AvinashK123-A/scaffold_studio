// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import '../settings.dart';
import '../widgets/showcase_widgets.dart';

/// App-level settings: theme mode, font, seed color and text scale.
///
/// Changes go to the root widget through [ShowcaseScope] and are applied by
/// `ScaffoldStudioApp` to every route.
class SettingsPage extends StatelessWidget {
  /// Creates the page.
  const SettingsPage({super.key});

  static const List<StudioFont> _fonts = <StudioFont>[
    StudioFont.system,
    StudioFont.roboto,
  ];

  @override
  Widget build(BuildContext context) {
    final ShowcaseScope scope = ShowcaseScope.of(context);
    final ShowcaseSettings settings = scope.settings;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    void update(ShowcaseSettings value) => scope.onChanged(value);

    return ShowcasePage(
      children: <Widget>[
        ShowcaseSection(
          title: 'Theme mode',
          child: RadioGroup<ThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) {
                update(settings.copyWith(themeMode: mode));
              }
            },
            child: const Column(
              children: <Widget>[
                RadioListTile<ThemeMode>(
                  contentPadding: EdgeInsets.zero,
                  value: ThemeMode.light,
                  title: Text('Light'),
                  secondary: Icon(Icons.light_mode_outlined),
                ),
                RadioListTile<ThemeMode>(
                  contentPadding: EdgeInsets.zero,
                  value: ThemeMode.dark,
                  title: Text('Dark'),
                  secondary: Icon(Icons.dark_mode_outlined),
                ),
                RadioListTile<ThemeMode>(
                  contentPadding: EdgeInsets.zero,
                  value: ThemeMode.system,
                  title: Text('System'),
                  subtitle: Text('Follow the device setting'),
                  secondary: Icon(Icons.brightness_auto_outlined),
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Font',
          description:
              'StudioFont.system uses the platform font; StudioFont.roboto '
              'is bundled with the package, so the app declares nothing.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final StudioFont font in _fonts)
                ChoiceChip(
                  label: Text(font.displayName),
                  selected: settings.font == font,
                  onSelected: (bool _) => update(settings.copyWith(font: font)),
                ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Seed color',
          description:
              'The light and dark color schemes are both generated from this '
              'seed.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final SeedChoice choice in seedChoices)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: choice.color),
                  label: Text(choice.name),
                  selected: settings.seedColor == choice.color,
                  onSelected: (bool _) =>
                      update(settings.copyWith(seedColor: choice.color)),
                ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Text scale',
          description:
              'Overrides the system text size for the whole app, to check '
              'every screen with large accessibility text.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final double? scale in textScaleChoices)
                ChoiceChip(
                  label: Text(textScaleLabel(scale)),
                  selected: settings.textScale == scale,
                  onSelected: (bool _) => update(settings.withTextScale(scale)),
                ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Preview',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: <Widget>[
              const CommonHeaderText(
                'Hi Avinash, how are you?',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                maxLines: 2,
              ),
              CommonBodyText(
                'Font: ${settings.font.displayName}. Text scale: '
                '${textScaleLabel(settings.textScale)}.',
                color: scheme.onSurfaceVariant,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  CommonButton(
                    label: 'Primary',
                    onPressed: () => showDemoSnackBar(context, 'Primary'),
                  ),
                  CommonButton(
                    label: 'Tonal',
                    variant: CommonButtonVariant.tonal,
                    onPressed: () => showDemoSnackBar(context, 'Tonal'),
                  ),
                ],
              ),
            ],
          ),
        ),
        CommonButton(
          label: 'Reset to defaults',
          icon: Icons.restart_alt,
          variant: CommonButtonVariant.text,
          onPressed: () => update(const ShowcaseSettings()),
        ),
      ],
    );
  }
}
