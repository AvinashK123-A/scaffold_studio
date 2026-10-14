// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

/// Measures [text] laid out with [style] by the real engine text stack.
double _measure(String text, TextStyle style) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final double width = painter.width;
  painter.dispose();
  return width;
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int index = 0;
  int linkTaps = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldStudio(
      appBar: StudioAppBar(
        titleText: 'Integration',
        actions: <Widget>[
          StudioAction(
            icon: Icons.notifications_outlined,
            tooltip: 'Notifications',
            badge: '3',
            onPressed: () {},
          ),
        ],
      ),
      navigation: StudioNavigation(
        items: const <StudioNavItem>[
          StudioNavItem(icon: Icons.home_outlined, label: 'Home'),
          StudioNavItem(icon: Icons.search, label: 'Search'),
          StudioNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
        selectedIndex: index,
        onSelected: (int value) => setState(() => index = value),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          CommonHeaderText('Page $index'),
          CommonBodyText(
            'Tapped $linkTaps',
            link: true,
            onTap: () => setState(() => linkTaps++),
          ),
        ],
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the package fonts are bundled without app declarations', (
    WidgetTester tester,
  ) async {
    // This app's pubspec does not declare any fonts. The Flutter tool adds
    // the package's fonts to the manifest automatically.
    final String manifest = await rootBundle.loadString('FontManifest.json');
    final List<Object?> families = jsonDecode(manifest) as List<Object?>;
    final Map<String, Object?> roboto = families
        .cast<Map<String, Object?>>()
        .firstWhere(
          (Map<String, Object?> entry) =>
              entry['family'] == 'packages/scaffold_studio/Roboto',
        );
    final List<Object?> fonts = roboto['fonts']! as List<Object?>;
    expect(fonts, hasLength(5));
    for (final Object? font in fonts) {
      final String asset = (font! as Map<String, Object?>)['asset']! as String;
      final ByteData data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(100000), reason: asset);
    }
  });

  testWidgets('bundled Roboto is registered with the engine', (
    WidgetTester tester,
  ) async {
    const String sample = 'The quick brown fox jumps over the lazy dog 0123';
    final String family = StudioFont.roboto.resolvedFamily!;
    final double roboto = _measure(
      sample,
      TextStyle(fontFamily: family, fontSize: 40),
    );
    final double missing = _measure(
      sample,
      const TextStyle(fontFamily: 'NoSuchFontFamily', fontSize: 40),
    );
    final double robotoBold = _measure(
      sample,
      TextStyle(fontFamily: family, fontSize: 40, fontWeight: FontWeight.w700),
    );
    final double robotoLight = _measure(
      sample,
      TextStyle(fontFamily: family, fontSize: 40, fontWeight: FontWeight.w300),
    );
    // A registered family lays out differently from the platform fallback,
    // and distinct bundled weights produce distinct metrics.
    expect(roboto, isNot(closeTo(missing, 0.5)));
    expect(robotoBold, greaterThan(roboto));
    expect(robotoLight, lessThan(roboto));
  });

  testWidgets('ScaffoldStudioApp configures theme and font', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ScaffoldStudioApp(
        fontFamily: StudioFont.roboto,
        theme: StudioTheme(seedColor: Colors.teal),
        themeMode: ThemeMode.light,
        home: _Shell(),
      ),
    );
    await tester.pumpAndSettle();
    final ThemeData theme = Theme.of(tester.element(find.text('Page 0')));
    expect(theme.extension<StudioThemeData>(), isNotNull);
    expect(
      theme.textTheme.bodyMedium!.fontFamily,
      'packages/scaffold_studio/Roboto',
    );
    expect(
      theme.colorScheme.primary,
      const StudioTheme(seedColor: Colors.teal).buildColorScheme().primary,
    );
  });

  testWidgets('layouts follow window resizing and callbacks work', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ScaffoldStudioApp(fontFamily: StudioFont.roboto, home: _Shell()),
    );

    const List<double> widths = <double>[
      320,
      360,
      390,
      430,
      600,
      768,
      840,
      1024,
      1280,
      1440,
    ];
    for (final double width in widths) {
      for (final double height in <double>[width * 0.6, width * 1.8]) {
        tester.view.physicalSize = Size(width, height.clamp(320, 2000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'at $width×$height');
        final StudioWindowSize size = StudioBreakpoints.material.sizeFor(width);
        expect(
          find.byType(StudioBottomBar),
          size.isCompact ? findsOneWidget : findsNothing,
          reason: 'bottom bar at $width',
        );
        expect(
          find.byType(StudioNavigationRail),
          size == StudioWindowSize.medium ? findsOneWidget : findsNothing,
          reason: 'rail at $width',
        );
        expect(
          find.byType(StudioSidebar),
          size.isExpanded ? findsOneWidget : findsNothing,
          reason: 'sidebar at $width',
        );
      }
    }

    // Selection callbacks and preservation across a layout switch.
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);

    // Link callbacks.
    await tester.tap(find.text('Tapped 0'));
    await tester.pumpAndSettle();
    expect(find.text('Tapped 1'), findsOneWidget);
  });
}
