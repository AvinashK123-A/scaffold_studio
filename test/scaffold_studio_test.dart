// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

/// A stateful host that owns the selected index, as an app would.
class _Host extends StatefulWidget {
  const _Host({
    this.mode = StudioNavigationMode.adaptive,
    this.barStyle = StudioBottomBarStyle.material,
    this.fab = false,
  });

  final StudioNavigationMode mode;
  final StudioBottomBarStyle barStyle;
  final bool fab;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldStudio(
      appBar: const StudioAppBar(titleText: 'Shell'),
      floatingActionButton: widget.fab
          ? FloatingActionButton(
              onPressed: () {},
              tooltip: 'Add',
              child: const Icon(Icons.add),
            )
          : null,
      navigation: StudioNavigation(
        items: navItems(4),
        selectedIndex: index,
        onSelected: (int value) => setState(() => index = value),
        mode: widget.mode,
        bottomBarStyle: widget.barStyle,
        sidebarHeader: const ListTile(title: Text('Header')),
      ),
      body: Center(child: Text('Page $index')),
    );
  }
}

void main() {
  group('adaptive navigation', () {
    for (final double width in kMatrixWidths) {
      testWidgets('picks the right layout at ${width.toInt()}', (
        WidgetTester tester,
      ) async {
        setWindowSize(tester, sizeFor(width));
        await pumpStudio(tester, const _Host());
        final StudioWindowSize size = StudioBreakpoints.material.sizeFor(width);
        expect(
          find.byType(StudioBottomBar),
          size.isCompact ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(StudioNavigationRail),
          size == StudioWindowSize.medium ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(StudioSidebar),
          size.isExpanded ? findsOneWidget : findsNothing,
        );
      });
    }

    testWidgets('the selection survives window resizing', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(390, 844));
      await pumpStudio(tester, const _Host());
      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      for (final Size size in <Size>[
        const Size(700, 900),
        const Size(1280, 800),
        const Size(390, 844),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(find.text('Page 2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pump();
      expect(
        tester.getSemantics(find.text('Item 2')),
        isSemantics(isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('a fixed mode overrides adaptation', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1280, 800));
      await pumpStudio(
        tester,
        const _Host(mode: StudioNavigationMode.bottomBar),
      );
      expect(find.byType(StudioBottomBar), findsOneWidget);
      expect(find.byType(StudioSidebar), findsNothing);
    });

    testWidgets('custom breakpoints change the decision', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(700, 900));
      await pumpStudio(
        tester,
        ScaffoldStudio(
          breakpoints: const StudioBreakpoints(medium: 750, expanded: 1000),
          navigation: StudioNavigation(items: navItems(3), selectedIndex: 0),
        ),
      );
      expect(find.byType(StudioBottomBar), findsOneWidget);
    });

    testWidgets('navigation with no items is omitted', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        const ScaffoldStudio(
          navigation: StudioNavigation(items: <StudioNavItem>[]),
          body: Text('content'),
        ),
      );
      expect(find.byType(StudioBottomBar), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('an invalid index does not crash the shell', (
      WidgetTester tester,
    ) async {
      int? built;
      for (final Size size in <Size>[
        const Size(390, 800),
        const Size(700, 900),
        const Size(1280, 800),
      ]) {
        setWindowSize(tester, size);
        await pumpStudio(
          tester,
          ScaffoldStudio(
            navigation: StudioNavigation(items: navItems(3), selectedIndex: 7),
            bodyBuilder: (BuildContext context, int index) {
              built = index;
              return const SizedBox.shrink();
            },
          ),
        );
        expect(tester.takeException(), isNull);
        expect(built, -1);
      }
    });
  });

  group('drawer mode', () {
    testWidgets('opens from the menu button, selects and closes', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(390, 844));
      await pumpStudio(tester, const _Host(mode: StudioNavigationMode.drawer));
      expect(find.byType(StudioBottomBar), findsNothing);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Header'), findsOneWidget);
      await tester.tap(find.text('Item 3'));
      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);
      expect(find.text('Header'), findsNothing);
    });

    testWidgets('an app drawer takes precedence', (WidgetTester tester) async {
      final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
      await pumpStudio(
        tester,
        ScaffoldStudio(
          scaffoldKey: key,
          drawer: const Drawer(child: Text('Mine')),
          navigation: StudioNavigation(
            items: navItems(3),
            mode: StudioNavigationMode.drawer,
          ),
        ),
      );
      key.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Mine'), findsOneWidget);
      expect(find.byType(StudioSidebar), findsNothing);
    });
  });

  group('floating action button', () {
    testWidgets('moves into the rail on medium widths', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(700, 900));
      await pumpStudio(tester, const _Host(fab: true));
      expect(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.byType(FloatingActionButton),
        ),
        findsOneWidget,
      );
      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.floatingActionButton, isNull);
    });

    testWidgets('docks into the notched bar', (WidgetTester tester) async {
      setWindowSize(tester, const Size(390, 844));
      await pumpStudio(
        tester,
        const _Host(fab: true, barStyle: StudioBottomBarStyle.notched),
      );
      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.floatingActionButtonLocation,
        FloatingActionButtonLocation.centerDocked,
      );
      expect(find.byType(BottomAppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('floating bars extend the body', (WidgetTester tester) async {
      setWindowSize(tester, const Size(390, 844));
      await pumpStudio(
        tester,
        const _Host(barStyle: StudioBottomBarStyle.floating),
      );
      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBody, isTrue);
    });
  });

  group('content', () {
    testWidgets('is limited to the max width on wide layouts', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1440, 900));
      await pumpStudio(
        tester,
        const ScaffoldStudio(
          contentMaxWidth: 800,
          body: SizedBox.expand(key: Key('body')),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('body'))).width, 800);
      expect(tester.getSize(find.byKey(const Key('body'))).height, 900);
    });

    testWidgets('uses the theme max width and can be disabled', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1440, 900));
      await pumpStudio(
        tester,
        const ScaffoldStudio(body: SizedBox.expand(key: Key('body'))),
        theme: const StudioTheme(contentMaxWidth: 1000),
      );
      expect(tester.getSize(find.byKey(const Key('body'))).width, 1000);

      await pumpStudio(
        tester,
        const ScaffoldStudio(
          contentMaxWidth: double.infinity,
          body: SizedBox.expand(key: Key('body')),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('body'))).width, 1440);
    });

    testWidgets('respects safe areas and padding', (WidgetTester tester) async {
      setWindowSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.fromLTRB(20, 40, 10, 30),
            ),
            child: ScaffoldStudio(
              bodyPadding: EdgeInsets.all(8),
              body: SizedBox.expand(key: Key('body')),
            ),
          ),
        ),
      );
      final Rect rect = tester.getRect(find.byKey(const Key('body')));
      expect(rect.left, 28);
      expect(rect.top, 48);
      expect(rect.right, 400 - 18);
      expect(rect.bottom, 800 - 38);
    });

    testWidgets('bodyBuilder receives the controller index', (
      WidgetTester tester,
    ) async {
      final StudioNavigationController controller = StudioNavigationController(
        initialIndex: 1,
      );
      addTearDown(controller.dispose);
      setWindowSize(tester, const Size(390, 844));
      await pumpStudio(
        tester,
        ScaffoldStudio(
          navigation: StudioNavigation(
            items: navItems(3),
            controller: controller,
          ),
          bodyBuilder: (BuildContext context, int index) => Text('Body $index'),
        ),
      );
      expect(find.text('Body 1'), findsOneWidget);
      await tester.tap(find.text('Item 2'));
      await tester.pump();
      expect(find.text('Body 2'), findsOneWidget);
      controller.select(0);
      await tester.pump();
      expect(find.text('Body 0'), findsOneWidget);
    });

    testWidgets('page state can be preserved with an IndexedStack', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(390, 844));
      await pumpStudio(tester, const _PreservingHost());
      await tester.enterText(find.byType(TextField), 'draft');
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 0'));
      await tester.pumpAndSettle();
      expect(find.text('draft'), findsOneWidget);
    });
  });

  group('keyboard', () {
    testWidgets('the bottom bar hides while the keyboard is visible', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(390, 844));
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await pumpStudio(tester, const _Host());
      expect(find.byType(StudioBottomBar), findsNothing);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(find.byType(StudioBottomBar), findsOneWidget);
    });
  });
}

class _PreservingHost extends StatefulWidget {
  const _PreservingHost();

  @override
  State<_PreservingHost> createState() => _PreservingHostState();
}

class _PreservingHostState extends State<_PreservingHost> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldStudio(
      navigation: StudioNavigation(
        items: navItems(2),
        selectedIndex: index,
        onSelected: (int value) => setState(() => index = value),
      ),
      body: IndexedStack(
        index: index,
        children: const <Widget>[
          Material(child: TextField()),
          Text('Second'),
        ],
      ),
    );
  }
}
