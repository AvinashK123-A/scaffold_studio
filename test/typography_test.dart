// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

void main() {
  group('StudioFont', () {
    test('roboto is addressed through this package', () {
      expect(StudioFont.roboto.family, 'Roboto');
      expect(StudioFont.roboto.package, 'scaffold_studio');
      expect(
        StudioFont.roboto.resolvedFamily,
        'packages/scaffold_studio/Roboto',
      );
      expect(StudioFont.roboto.isSystem, isFalse);
    });

    test('roboto reports only the weights it bundles', () {
      expect(StudioFont.roboto.supportsWeight(FontWeight.w400), isTrue);
      expect(StudioFont.roboto.supportsWeight(FontWeight.w500), isTrue);
      expect(StudioFont.roboto.supportsWeight(FontWeight.w700), isTrue);
      expect(StudioFont.roboto.supportsWeight(FontWeight.w600), isFalse);
      expect(StudioFont.roboto.supportsWeight(FontWeight.w900), isFalse);
    });

    test('system font has no family and claims no specific weights', () {
      expect(StudioFont.system.isSystem, isTrue);
      expect(StudioFont.system.resolvedFamily, isNull);
      expect(StudioFont.system.supportsWeight(FontWeight.w600), isTrue);
      expect(StudioFont.system.displayName, 'System');
    });

    test('custom fonts qualify family and fallback by package', () {
      const StudioFont app = StudioFont.custom(
        'Inter',
        fallback: <String>['X'],
      );
      expect(app.resolvedFamily, 'Inter');
      expect(app.resolvedFallback, <String>['X']);

      const StudioFont packaged = StudioFont.custom(
        'Brand',
        package: 'brand_fonts',
        fallback: <String>['BrandFallback'],
      );
      expect(packaged.resolvedFamily, 'packages/brand_fonts/Brand');
      expect(packaged.resolvedFallback, <String>[
        'packages/brand_fonts/BrandFallback',
      ]);
    });

    test('applyTo sets the family and system restores the platform font', () {
      const TextStyle base = TextStyle(fontFamily: 'Something');
      expect(
        StudioFont.roboto
            .applyTo(base, platform: TargetPlatform.iOS)
            .fontFamily,
        'packages/scaffold_studio/Roboto',
      );
      final String? iosDefault = Typography.material2021(
        platform: TargetPlatform.iOS,
      ).black.bodyMedium?.fontFamily;
      expect(
        StudioFont.system
            .applyTo(base, platform: TargetPlatform.iOS)
            .fontFamily,
        iosDefault,
      );
    });

    test('equality', () {
      expect(
        const StudioFont.custom('A', package: 'p'),
        const StudioFont.custom('A', package: 'p'),
      );
      expect(
        const StudioFont.custom('A'),
        isNot(const StudioFont.custom('A', package: 'p')),
      );
      expect(StudioFont.roboto, isNot(StudioFont.system));
    });
  });

  group('StudioTypography', () {
    final TextTheme textTheme = ThemeData().textTheme;

    test('roles map to Material text theme styles', () {
      const StudioTypography typography = StudioTypography();
      final TextStyle header = typography.resolve(
        StudioTextRole.header,
        textTheme,
      );
      expect(header.fontSize, textTheme.titleLarge!.fontSize);
      expect(header.fontWeight, FontWeight.w600);
      expect(
        typography.resolve(StudioTextRole.body, textTheme).fontSize,
        textTheme.bodyMedium!.fontSize,
      );
      expect(
        typography.resolve(StudioTextRole.label, textTheme).fontSize,
        textTheme.labelLarge!.fontSize,
      );
      expect(
        typography.resolve(StudioTextRole.caption, textTheme).fontSize,
        textTheme.bodySmall!.fontSize,
      );
    });

    test('role overrides merge over the base style', () {
      const StudioTypography typography = StudioTypography(
        header: TextStyle(fontSize: 30, letterSpacing: 1),
        link: TextStyle(fontWeight: FontWeight.w700),
      );
      final TextStyle header = typography.resolve(
        StudioTextRole.header,
        textTheme,
      );
      expect(header.fontSize, 30);
      expect(header.letterSpacing, 1);
      expect(header.fontWeight, FontWeight.w600);
      expect(
        typography.resolve(StudioTextRole.link, textTheme).fontWeight,
        FontWeight.w700,
      );
    });

    test('copyWith, equality and lerp', () {
      const StudioTypography a = StudioTypography(
        body: TextStyle(fontSize: 10),
      );
      final StudioTypography b = a.copyWith(
        body: const TextStyle(fontSize: 20),
      );
      expect(a, const StudioTypography(body: TextStyle(fontSize: 10)));
      expect(a, isNot(b));
      expect(StudioTypography.lerp(a, b, 0.5).body!.fontSize, 15);
    });

    testWidgets('styleOf reads the ambient theme', (WidgetTester tester) async {
      late TextStyle style;
      await pumpStudio(
        tester,
        Builder(
          builder: (BuildContext context) {
            style = StudioTypography.styleOf(context, StudioTextRole.header);
            return const SizedBox.shrink();
          },
        ),
        font: StudioFont.roboto,
        typography: const StudioTypography(header: TextStyle(fontSize: 31)),
      );
      expect(style.fontSize, 31);
      expect(style.fontFamily, 'packages/scaffold_studio/Roboto');
    });
  });

  group('global font', () {
    testWidgets('ScaffoldStudioApp applies the font to the text theme', (
      WidgetTester tester,
    ) async {
      late ThemeData theme;
      await tester.pumpWidget(
        ScaffoldStudioApp(
          fontFamily: StudioFont.roboto,
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                theme = Theme.of(context);
                return const Text('plain');
              },
            ),
          ),
        ),
      );
      expect(
        theme.textTheme.bodyMedium!.fontFamily,
        'packages/scaffold_studio/Roboto',
      );
      expect(
        theme.textTheme.titleLarge!.fontFamily,
        'packages/scaffold_studio/Roboto',
      );
      expect(
        theme.primaryTextTheme.bodyMedium!.fontFamily,
        'packages/scaffold_studio/Roboto',
      );

      // A plain Text inherits the font through DefaultTextStyle.
      final RichText plain = tester.widget<RichText>(
        find.descendant(
          of: find.text('plain'),
          matching: find.byType(RichText),
        ),
      );
      expect(plain.text.style!.fontFamily, 'packages/scaffold_studio/Roboto');
    });

    testWidgets('explicit TextStyle families are not overridden', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ScaffoldStudioApp(
          fontFamily: StudioFont.roboto,
          home: Material(
            child: Text('explicit', style: TextStyle(fontFamily: 'Courier')),
          ),
        ),
      );
      final RichText text = tester.widget<RichText>(
        find.descendant(
          of: find.text('explicit'),
          matching: find.byType(RichText),
        ),
      );
      expect(text.text.style!.fontFamily, 'Courier');
    });

    testWidgets('system font leaves the platform default in place', (
      WidgetTester tester,
    ) async {
      late ThemeData theme;
      await tester.pumpWidget(
        ScaffoldStudioApp(
          home: Builder(
            builder: (BuildContext context) {
              theme = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final String? expected = Typography.material2021(
        platform: theme.platform,
      ).black.bodyMedium?.fontFamily;
      expect(theme.textTheme.bodyMedium!.fontFamily, expected);
    });

    testWidgets('a widget can override the global font', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        const Column(
          children: <Widget>[
            CommonBodyText('global'),
            CommonBodyText('local', fontFamily: StudioFont.system),
            CommonBodyText(
              'custom',
              fontFamily: StudioFont.custom('Inter', package: 'brand'),
            ),
          ],
        ),
        font: StudioFont.roboto,
      );
      String? familyOf(String text) =>
          tester.widget<Text>(find.text(text)).style!.fontFamily;
      expect(familyOf('global'), 'packages/scaffold_studio/Roboto');
      expect(familyOf('local'), isNot(contains('scaffold_studio')));
      expect(familyOf('custom'), 'packages/brand/Inter');
    });
  });
}
