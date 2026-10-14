// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

void main() {
  group('StudioTheme', () {
    test('light and dark produce matching brightness', () {
      final ThemeData light = StudioTheme.light.toThemeData();
      final ThemeData dark = StudioTheme.dark.toThemeData();
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.useMaterial3, isTrue);
      expect(light.colorScheme, isNot(dark.colorScheme));
    });

    test('installs the StudioThemeData extension', () {
      final ThemeData theme = const StudioTheme(
        linkColor: Color(0xFF123456),
        contentMaxWidth: 900,
        breakpoints: StudioBreakpoints(medium: 500, expanded: 900),
      ).toThemeData(typography: const StudioTypography(body: TextStyle()));
      final StudioThemeData? tokens = theme.extension<StudioThemeData>();
      expect(tokens, isNotNull);
      expect(tokens!.linkColor, const Color(0xFF123456));
      expect(tokens.contentMaxWidth, 900);
      expect(tokens.breakpoints.medium, 500);
      expect(tokens.typography.body, const TextStyle());
    });

    test('seed color drives the color scheme', () {
      final ColorScheme teal = const StudioTheme(
        seedColor: Colors.teal,
      ).buildColorScheme();
      final ColorScheme defaults = StudioTheme.light.buildColorScheme();
      expect(teal.primary, isNot(defaults.primary));
    });

    test('explicit color scheme wins and sets brightness', () {
      final ColorScheme scheme = ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.dark,
      );
      final StudioTheme theme = StudioTheme(colorScheme: scheme);
      expect(theme.effectiveBrightness, Brightness.dark);
      expect(theme.toThemeData().colorScheme, scheme);
    });

    test('component defaults are configured', () {
      final ThemeData theme = const StudioTheme(cornerRadius: 8).toThemeData();
      final RoundedRectangleBorder shape =
          theme.cardTheme.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, const BorderRadius.all(Radius.circular(8)));
      expect(theme.badgeTheme.backgroundColor, theme.colorScheme.error);
      expect(theme.dividerTheme.color, theme.colorScheme.outlineVariant);
    });

    test('copyWith and equality', () {
      expect(StudioTheme.light.copyWith(), StudioTheme.light);
      expect(StudioTheme.light.seedColor, StudioTheme.defaultSeedColor);
      expect(
        StudioTheme.light.copyWith(brightness: Brightness.dark),
        StudioTheme.dark,
      );
      expect(
        StudioTheme.light.copyWith(seedColor: Colors.red).hashCode,
        const StudioTheme(seedColor: Colors.red).hashCode,
      );
    });
  });

  group('StudioThemeData', () {
    testWidgets('falls back to defaults under a plain MaterialApp', (
      WidgetTester tester,
    ) async {
      late StudioThemeData light;
      late StudioThemeData dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          home: Builder(
            builder: (BuildContext context) {
              light = StudioThemeData.of(context);
              return Theme(
                data: ThemeData(brightness: Brightness.dark),
                child: Builder(
                  builder: (BuildContext context) {
                    dark = StudioThemeData.of(context);
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );
      expect(
        light.linkColor,
        StudioThemeData.defaultLinkColor(Brightness.light),
      );
      expect(dark.linkColor, StudioThemeData.defaultLinkColor(Brightness.dark));
      expect(light.linkColor, isNot(dark.linkColor));
      expect(light.breakpoints, StudioBreakpoints.material);
    });

    test('default link colors are blue and readable on surfaces', () {
      for (final Brightness brightness in Brightness.values) {
        final Color link = StudioThemeData.defaultLinkColor(brightness);
        final HSLColor hsl = HSLColor.fromColor(link);
        // Blue hues sit roughly between 200 and 240 degrees.
        expect(hsl.hue, inInclusiveRange(195, 245));
        final Color surface = StudioTheme(
          brightness: brightness,
        ).buildColorScheme().surface;
        expect(_contrast(link, surface), greaterThanOrEqualTo(4.5));
      }
    });

    test('lerp interpolates colors and switches discrete values', () {
      const StudioThemeData a = StudioThemeData(
        linkColor: Color(0xFF000000),
        contentMaxWidth: 1000,
      );
      const StudioThemeData b = StudioThemeData(
        linkColor: Color(0xFFFFFFFF),
        contentMaxWidth: 2000,
        breakpoints: StudioBreakpoints(medium: 400, expanded: 800),
      );
      final StudioThemeData early = a.lerp(b, 0.25);
      final StudioThemeData late = a.lerp(b, 0.75);
      expect(early.contentMaxWidth, 1250);
      expect(early.breakpoints, a.breakpoints);
      expect(late.breakpoints, b.breakpoints);
      expect(a.lerp(null, 0.5), a);
    });

    test('copyWith and equality', () {
      const StudioThemeData a = StudioThemeData(linkColor: Colors.blue);
      expect(a.copyWith(), a);
      expect(a.copyWith(contentMaxWidth: 10), isNot(a));
    });
  });

  group('ScaffoldStudioApp themes', () {
    testWidgets('dark mode follows a custom seed by default', (
      WidgetTester tester,
    ) async {
      late ThemeData theme;
      await tester.pumpWidget(
        ScaffoldStudioApp(
          theme: const StudioTheme(seedColor: Colors.teal),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (BuildContext context) {
              theme = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(theme.brightness, Brightness.dark);
      expect(
        theme.colorScheme.primary,
        const StudioTheme(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ).buildColorScheme().primary,
      );
    });

    testWidgets('themeOverride adjusts the generated theme', (
      WidgetTester tester,
    ) async {
      late ThemeData theme;
      await tester.pumpWidget(
        ScaffoldStudioApp(
          themeOverride: _bigVisualDensity,
          home: Builder(
            builder: (BuildContext context) {
              theme = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(theme.visualDensity, VisualDensity.comfortable);
      expect(theme.extension<StudioThemeData>(), isNotNull);
    });

    testWidgets('changing the theme rebuilds the cached ThemeData', (
      WidgetTester tester,
    ) async {
      late ThemeData theme;
      Widget app(StudioTheme studioTheme) => ScaffoldStudioApp(
        theme: studioTheme,
        themeMode: ThemeMode.light,
        themeAnimationDuration: Duration.zero,
        home: Builder(
          builder: (BuildContext context) {
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpWidget(app(const StudioTheme(seedColor: Colors.red)));
      final Color red = theme.colorScheme.primary;
      await tester.pumpWidget(app(const StudioTheme(seedColor: Colors.green)));
      await tester.pumpAndSettle();
      expect(theme.colorScheme.primary, isNot(red));
    });
  });
}

ThemeData _bigVisualDensity(ThemeData theme) =>
    theme.copyWith(visualDensity: VisualDensity.comfortable);

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double lighter = la > lb ? la : lb;
  final double darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
