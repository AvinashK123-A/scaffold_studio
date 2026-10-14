// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

/// A shell exercising every responsive part at once: an app bar with a long
/// title, a subtitle, many actions and a badge; five destinations with
/// badges; a FAB; and scrolling body content with long text.
Widget _shell({
  StudioAppBarStyle appBarStyle = StudioAppBarStyle.standard,
  StudioBottomBarStyle barStyle = StudioBottomBarStyle.material,
  int destinations = 5,
}) {
  return ScaffoldStudio(
    appBar: StudioAppBar(
      style: appBarStyle,
      titleText: 'A deliberately long dashboard title that must not overflow',
      subtitleText: 'Subtitle with additional context',
      logo: const FlutterLogo(size: 28),
      profile: const CircleAvatar(radius: 16, child: Text('A')),
      search: appBarStyle == StudioAppBarStyle.search
          ? const StudioAppBarSearch(hintText: 'Search everything')
          : null,
      backgroundImage: appBarStyle == StudioAppBarStyle.image
          ? MemoryImage(kTransparentPng)
          : null,
      actions: <Widget>[
        StudioAction(
          icon: Icons.notifications_outlined,
          tooltip: 'Notifications',
          badge: '3',
          onPressed: () {},
        ),
        StudioAction(icon: Icons.share, tooltip: 'Share', onPressed: () {}),
        StudioAction(icon: Icons.print, tooltip: 'Print', onPressed: () {}),
        StudioAction(icon: Icons.edit, tooltip: 'Edit', onPressed: () {}),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      tooltip: 'Compose',
      child: const Icon(Icons.add),
    ),
    navigation: StudioNavigation(
      items: <StudioNavItem>[
        for (final StudioNavItem item in navItems(destinations))
          StudioNavItem(
            icon: item.icon!,
            label: '${item.label} with a long label',
            badgeCount: item.label.endsWith('1') ? 120 : null,
          ),
      ],
      selectedIndex: 1,
      onSelected: (_) {},
      bottomBarStyle: barStyle,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        CommonHeaderText(
          'Hi Alex, how are you? This heading is long enough to wrap.',
        ),
        CommonBodyText(
          'Body text that is long enough to wrap across several lines on '
          'narrow layouts without overflowing horizontally.',
        ),
      ],
    ),
  );
}

/// A 1×1 transparent PNG, so the image style can be tested offline.
final Uint8List kTransparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  group('responsive matrix', () {
    for (final double width in kMatrixWidths) {
      for (final bool landscape in <bool>[false, true]) {
        for (final double scale in <double>[1, 2]) {
          final String name =
              '${width.toInt()} ${landscape ? 'landscape' : 'portrait'} '
              'text ×$scale';
          testWidgets('$name lays out without overflow', (
            WidgetTester tester,
          ) async {
            setWindowSize(tester, sizeFor(width, landscape: landscape));
            await pumpStudio(tester, _shell(), textScale: scale);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);

            final StudioWindowSize size = StudioBreakpoints.material.sizeFor(
              width,
            );
            switch (size) {
              case StudioWindowSize.compact:
                expect(find.byType(StudioBottomBar), findsOneWidget);
              case StudioWindowSize.medium:
                expect(find.byType(StudioNavigationRail), findsOneWidget);
              case StudioWindowSize.expanded:
                expect(find.byType(StudioSidebar), findsOneWidget);
            }
          });
        }
      }
    }
  });

  group('every app bar style', () {
    for (final StudioAppBarStyle style in StudioAppBarStyle.values) {
      for (final double width in <double>[320, 600, 1280]) {
        testWidgets('${style.name} at ${width.toInt()} with text ×2', (
          WidgetTester tester,
        ) async {
          setWindowSize(tester, sizeFor(width));
          await pumpStudio(tester, _shell(appBarStyle: style), textScale: 2);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(AppBar), findsOneWidget);
        });
      }
    }
  });

  group('every bottom bar style', () {
    for (final StudioBottomBarStyle style in StudioBottomBarStyle.values) {
      for (final int count in <int>[2, 3, 4, 5]) {
        for (final double width in <double>[320, 430]) {
          testWidgets('${style.name}, $count items at ${width.toInt()}', (
            WidgetTester tester,
          ) async {
            setWindowSize(tester, sizeFor(width));
            await pumpStudio(
              tester,
              _shell(barStyle: style, destinations: count),
              textScale: 2,
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(StudioBottomBar), findsOneWidget);
          });
        }
      }
    }
  });
}
