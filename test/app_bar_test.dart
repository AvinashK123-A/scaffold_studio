// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

List<Widget> _actions(List<String> log, {int count = 5}) => <Widget>[
  StudioAction(
    icon: Icons.notifications_outlined,
    tooltip: 'Notifications',
    badge: '3',
    onPressed: () => log.add('Notifications'),
  ),
  for (int i = 1; i < count; i++)
    StudioAction(
      icon: Icons.star_border,
      tooltip: 'Action $i',
      onPressed: () => log.add('Action $i'),
    ),
];

Widget _host(PreferredSizeWidget appBar) =>
    Scaffold(appBar: appBar, body: const SizedBox.expand());

void main() {
  group('slots', () {
    testWidgets('title, leading, logo, profile and actions render', (
      WidgetTester tester,
    ) async {
      final List<String> log = <String>[];
      setWindowSize(tester, const Size(1024, 700));
      await pumpStudio(
        tester,
        _host(
          StudioAppBar(
            titleText: 'Dashboard',
            subtitleText: 'Welcome back',
            leading: const Icon(Icons.menu_book, key: Key('leading')),
            logo: const FlutterLogo(key: Key('logo')),
            profile: const CircleAvatar(key: Key('avatar')),
            actions: _actions(log, count: 2),
          ),
        ),
      );
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byKey(const Key('leading')), findsOneWidget);
      expect(find.byKey(const Key('logo')), findsOneWidget);
      expect(find.byKey(const Key('avatar')), findsOneWidget);
      await tester.tap(find.byTooltip('Action 1'));
      expect(log, <String>['Action 1']);
    });

    testWidgets('arbitrary title widgets are supported', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[Icon(Icons.bolt), Text('Custom')],
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.bolt), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    test('title and titleText are mutually exclusive', () {
      expect(
        () => StudioAppBar(title: const Text('a'), titleText: 'b'),
        throwsAssertionError,
      );
    });

    testWidgets('profile style leads with the avatar', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            style: StudioAppBarStyle.profile,
            titleText: 'Hi Alex',
            subtitleText: 'Good morning',
            profile: CircleAvatar(key: Key('avatar')),
          ),
        ),
      );
      expect(
        tester.getCenter(find.byKey(const Key('avatar'))).dx,
        lessThan(tester.getTopLeft(find.text('Hi Alex')).dx),
      );
    });

    testWidgets('flexible style keeps a wide leading widget inline', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(390, 800));
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            style: StudioAppBarStyle.flexible,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 8),
                Flexible(
                  child: Text('Alex Johnson', overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            titleText: 'Dashboard',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.text('Dashboard')).dx,
        greaterThanOrEqualTo(tester.getTopRight(find.text('Alex Johnson')).dx),
      );
    });
  });

  group('badges', () {
    testWidgets('StudioAction shows its badge and announces it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(
        tester,
        _host(
          StudioAppBar(
            titleText: 'Inbox',
            actions: <Widget>[
              StudioAction(
                icon: Icons.notifications,
                tooltip: 'Notifications',
                badge: '3',
                onPressed: () {},
              ),
              StudioAction(
                icon: Icons.mail,
                tooltip: 'Mail',
                badgeCount: 250,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      expect(find.text('3'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(
        tester.getSemantics(find.byTooltip('Notifications')),
        isSemantics(tooltip: 'Notifications', label: '3', isButton: true),
      );
      handle.dispose();
    });
  });

  group('action overflow', () {
    testWidgets('narrow widths move trailing actions into a menu', (
      WidgetTester tester,
    ) async {
      final List<String> log = <String>[];
      setWindowSize(tester, const Size(320, 640));
      await pumpStudio(
        tester,
        _host(StudioAppBar(titleText: 'Narrow', actions: _actions(log))),
      );
      expect(find.byType(PopupMenuButton<VoidCallback>), findsOneWidget);
      expect(find.byTooltip('Action 4'), findsNothing);

      await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
      await tester.pumpAndSettle();
      expect(find.text('Action 4'), findsOneWidget);
      await tester.tap(find.text('Action 4'));
      await tester.pumpAndSettle();
      expect(log, <String>['Action 4']);
    });

    testWidgets('wide layouts show every action', (WidgetTester tester) async {
      setWindowSize(tester, const Size(1280, 800));
      await pumpStudio(
        tester,
        _host(StudioAppBar(titleText: 'Wide', actions: _actions(<String>[]))),
      );
      expect(find.byType(PopupMenuButton<VoidCallback>), findsNothing);
      expect(find.byTooltip('Action 4'), findsOneWidget);
    });

    testWidgets('maxVisibleActions forces the menu', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1280, 800));
      await pumpStudio(
        tester,
        _host(
          StudioAppBar(
            titleText: 'Limited',
            maxVisibleActions: 2,
            actions: _actions(<String>[]),
          ),
        ),
      );
      expect(find.byType(PopupMenuButton<VoidCallback>), findsOneWidget);
      expect(find.byTooltip('Notifications'), findsOneWidget);
      expect(find.byTooltip('Action 1'), findsNothing);
    });

    testWidgets('an overflowed badge marks the menu button', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1280, 800));
      await pumpStudio(
        tester,
        _host(
          StudioAppBar(
            titleText: 'Badge',
            maxVisibleActions: 1,
            actions: <Widget>[
              StudioAction(icon: Icons.abc, tooltip: 'A', onPressed: () {}),
              StudioAction(
                icon: Icons.backup,
                tooltip: 'B',
                badge: '1',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      final Badge badge = tester.widget<Badge>(
        find.descendant(
          of: find.byType(PopupMenuButton<VoidCallback>),
          matching: find.byType(Badge),
        ),
      );
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('widgets other than StudioAction never overflow', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1280, 800));
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            titleText: 'Custom',
            maxVisibleActions: 1,
            actions: <Widget>[
              Icon(Icons.wifi, key: Key('a')),
              Icon(Icons.wifi, key: Key('b')),
            ],
          ),
        ),
      );
      expect(find.byType(PopupMenuButton<VoidCallback>), findsNothing);
      expect(find.byKey(const Key('b')), findsOneWidget);
    });
  });

  group('search', () {
    testWidgets('search style shows a field that reports input', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      await pumpStudio(
        tester,
        _host(
          StudioAppBar(
            style: StudioAppBarStyle.search,
            search: StudioAppBarSearch(
              hintText: 'Find orders',
              onChanged: queries.add,
            ),
          ),
        ),
      );
      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('Find orders'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'shoes');
      await tester.pump();
      expect(queries.last, 'shoes');
      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();
      expect(queries.last, '');
    });

    testWidgets('compact non-search styles expand search on demand', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(360, 700));
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            titleText: 'Products',
            search: StudioAppBarSearch(),
          ),
        ),
      );
      expect(find.byType(SearchBar), findsNothing);
      await tester.tap(find.byTooltip('Search'));
      await tester.pump();
      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('Products'), findsNothing);
      await tester.tap(find.byTooltip('Close search'));
      await tester.pump();
      expect(find.byType(SearchBar), findsNothing);
      expect(find.text('Products'), findsOneWidget);
    });

    testWidgets('wide non-search styles show the field next to the title', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1024, 700));
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            titleText: 'Products',
            search: StudioAppBarSearch(),
          ),
        ),
      );
      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
    });
  });

  group('back behavior', () {
    testWidgets('onBackPressed shows a back button that calls it', (
      WidgetTester tester,
    ) async {
      int backs = 0;
      await pumpStudio(
        tester,
        _host(StudioAppBar(titleText: 'Details', onBackPressed: () => backs++)),
      );
      await tester.tap(find.byType(BackButton));
      expect(backs, 1);
    });

    testWidgets('a pushed route gets an implied back button', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _host(const StudioAppBar(titleText: 'Second')),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(BackButtonIcon), findsOneWidget);
      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('height', () {
    test('defaults per style and minimum height', () {
      expect(const StudioAppBar().preferredSize.height, 64);
      expect(
        const StudioAppBar(
          style: StudioAppBarStyle.minimal,
        ).preferredSize.height,
        56,
      );
      expect(
        const StudioAppBar(
          style: StudioAppBarStyle.profile,
        ).preferredSize.height,
        72,
      );
      expect(
        const StudioAppBar(height: 30).preferredSize.height,
        kMinInteractiveDimension,
      );
      expect(
        const StudioAppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: SizedBox(),
          ),
        ).preferredSize.height,
        104,
      );
    });

    testWidgets('grows with text scale inside ScaffoldStudio', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        const ScaffoldStudio(appBar: StudioAppBar(titleText: 'Scaled')),
        textScale: 2,
      );
      final double height = tester.getSize(find.byType(AppBar)).height;
      final double topPadding = MediaQuery.of(
        tester.element(find.byType(AppBar)),
      ).padding.top;
      // 64 × 1.5 (the maximum growth factor) plus the status bar.
      expect(height, 96 + topPadding);
    });

    testWidgets('adaptiveHeight: false keeps the base height', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        const ScaffoldStudio(
          appBar: StudioAppBar(titleText: 'Fixed', adaptiveHeight: false),
        ),
        textScale: 2,
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.toolbarHeight, 64);
    });
  });

  group('styles', () {
    testWidgets('gradient and image styles paint a background', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            style: StudioAppBarStyle.gradient,
            titleText: 'Gradient',
          ),
        ),
      );
      final AppBar gradientBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(gradientBar.flexibleSpace, isA<DecoratedBox>());
      final DecoratedBox box = gradientBar.flexibleSpace! as DecoratedBox;
      expect((box.decoration as BoxDecoration).gradient, isNotNull);
      expect(gradientBar.backgroundColor, Colors.transparent);
    });

    testWidgets('rounded style uses bottom corner radius', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            style: StudioAppBarStyle.rounded,
            titleText: 'Rounded',
          ),
        ),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      final RoundedRectangleBorder shape = bar.shape! as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        const BorderRadius.vertical(bottom: Radius.circular(24)),
      );
    });

    testWidgets('centered and explicit overrides', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        _host(
          const StudioAppBar(
            style: StudioAppBarStyle.centered,
            titleText: 'Centered',
            backgroundColor: Colors.amber,
            elevation: 3,
          ),
        ),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.centerTitle, isTrue);
      expect(bar.backgroundColor, Colors.amber);
      expect(bar.elevation, 3);
    });

    testWidgets('long titles are ellipsized', (WidgetTester tester) async {
      setWindowSize(tester, const Size(320, 640));
      await pumpStudio(
        tester,
        _host(StudioAppBar(titleText: 'Long title ' * 10)),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      final Text title = tester.widget<Text>(find.textContaining('Long title'));
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);
    });
  });
}
