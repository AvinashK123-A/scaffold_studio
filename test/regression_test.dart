// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

/// Regression tests for layout bugs found while building the example app.
void main() {
  for (final StudioBottomBarStyle style in StudioBottomBarStyle.values) {
    testWidgets('${style.name} bottom bar survives resizing mid-animation', (
      WidgetTester tester,
    ) async {
      Widget bar(double width, int count) => Center(
        child: SizedBox(
          width: width,
          child: Material(
            child: StudioBottomBar(
              items: navItems(count),
              selectedIndex: 0,
              style: style,
            ),
          ),
        ),
      );
      await pumpStudio(tester, bar(500, 5));
      await pumpStudio(tester, bar(320, 5));
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      await pumpStudio(tester, bar(320, 2));
      await pumpStudio(tester, bar(320, 5));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('a long divider label wraps in a narrow space', (
    WidgetTester tester,
  ) async {
    await pumpStudio(
      tester,
      const Center(
        child: SizedBox(
          width: 200,
          child: CommonDivider(label: 'Or continue with one of these accounts'),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('flexible app bar with a wide leading fits on phones', (
    WidgetTester tester,
  ) async {
    setWindowSize(tester, const Size(320, 640));
    await pumpStudio(
      tester,
      Scaffold(
        appBar: StudioAppBar(
          style: StudioAppBarStyle.flexible,
          leading: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(child: Icon(Icons.person)),
              SizedBox(width: 8),
              Flexible(
                child: Text('Avinash Reddy', overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          titleText: 'Dashboard',
          actions: <Widget>[
            for (final IconData icon in <IconData>[
              Icons.notifications,
              Icons.share,
              Icons.print,
            ])
              StudioAction(icon: icon, tooltip: '$icon', onPressed: () {}),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile style keeps the back button on pushed routes', (
    WidgetTester tester,
  ) async {
    await pumpStudio(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const Scaffold(
                appBar: StudioAppBar(
                  style: StudioAppBarStyle.profile,
                  titleText: 'Profile',
                  profile: CircleAvatar(key: Key('avatar')),
                ),
              ),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.byKey(const Key('avatar')), findsOneWidget);
  });

  testWidgets('image style shows a fallback until an image is provided', (
    WidgetTester tester,
  ) async {
    await pumpStudio(
      tester,
      const Scaffold(
        appBar: StudioAppBar(style: StudioAppBarStyle.image, titleText: 'Img'),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Img'), findsOneWidget);
  });
}
