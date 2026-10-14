// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

void main() {
  testWidgets('passes MaterialApp options through', (
    WidgetTester tester,
  ) async {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    final _RecordingObserver observer = _RecordingObserver();
    await tester.pumpWidget(
      ScaffoldStudioApp(
        title: 'Studio',
        navigatorKey: navigatorKey,
        navigatorObservers: <NavigatorObserver>[observer],
        debugShowCheckedModeBanner: false,
        locale: const Locale('en', 'GB'),
        supportedLocales: const <Locale>[Locale('en', 'GB'), Locale('en')],
        routes: <String, WidgetBuilder>{
          '/': (_) => const Text('home'),
          '/details': (_) => const Text('details'),
        },
      ),
    );
    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.title, 'Studio');
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.locale, const Locale('en', 'GB'));
    expect(app.theme!.extension<StudioThemeData>(), isNotNull);
    expect(find.text('home'), findsOneWidget);

    unawaited(navigatorKey.currentState!.pushNamed('/details'));
    await tester.pumpAndSettle();
    expect(find.text('details'), findsOneWidget);
    expect(observer.pushed, contains('/details'));
  });

  testWidgets('router constructor works with a RouterConfig', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScaffoldStudioApp.router(
        fontFamily: StudioFont.roboto,
        routerConfig: RouterConfig<Object>(
          routerDelegate: _SingleRouteDelegate(),
        ),
      ),
    );
    expect(find.text('routed'), findsOneWidget);
    final ThemeData theme = Theme.of(tester.element(find.text('routed')));
    expect(
      theme.textTheme.bodyMedium!.fontFamily,
      'packages/scaffold_studio/Roboto',
    );
  });

  testWidgets('themeMode selects light or dark', (WidgetTester tester) async {
    for (final ThemeMode mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
      late Brightness brightness;
      await tester.pumpWidget(
        ScaffoldStudioApp(
          themeMode: mode,
          themeAnimationDuration: Duration.zero,
          home: Builder(
            builder: (BuildContext context) {
              brightness = Theme.of(context).brightness;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    }
  });

  testWidgets('explicit color schemes without a dark theme stay light', (
    WidgetTester tester,
  ) async {
    final ScaffoldStudioApp app = ScaffoldStudioApp(
      theme: StudioTheme(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const SizedBox.shrink(),
    );
    expect(app.effectiveDarkTheme, isNull);
    expect(const ScaffoldStudioApp().effectiveDarkTheme, isNotNull);
  });

  test('router constructor requires a router', () {
    expect(ScaffoldStudioApp.router, throwsAssertionError);
  });
}

class _RecordingObserver extends NavigatorObserver {
  final List<String?> pushed = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route.settings.name);
  }
}

class _SingleRouteDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: const <Page<void>>[
        MaterialPage<void>(child: Scaffold(body: Text('routed'))),
      ],
      onDidRemovePage: (Page<Object?> page) {},
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
