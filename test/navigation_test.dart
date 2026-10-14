// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

Widget _barHost(Widget bar) =>
    Scaffold(body: const SizedBox.expand(), bottomNavigationBar: bar);

void main() {
  group('StudioBottomBar', () {
    for (final int count in <int>[2, 3, 4, 5]) {
      testWidgets('renders and selects among $count items', (
        WidgetTester tester,
      ) async {
        setWindowSize(tester, const Size(390, 844));
        final List<int> selections = <int>[];
        await pumpStudio(
          tester,
          _barHost(
            StudioBottomBar(
              items: navItems(count),
              selectedIndex: 0,
              onSelected: selections.add,
            ),
          ),
        );
        for (int i = 0; i < count; i++) {
          expect(find.text('Item $i'), findsOneWidget);
        }
        await tester.tap(find.text('Item ${count - 1}'));
        expect(selections, <int>[count - 1]);
      });
    }

    testWidgets('empty items render nothing', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        _barHost(const StudioBottomBar(items: <StudioNavItem>[])),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(InkWell), findsNothing);
      expect(tester.getSize(find.byType(StudioBottomBar)).height, 0);
    });

    for (final int invalid in <int>[-1, 3, 99]) {
      testWidgets('index $invalid selects nothing without throwing', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await pumpStudio(
          tester,
          _barHost(StudioBottomBar(items: navItems(3), selectedIndex: invalid)),
        );
        expect(tester.takeException(), isNull);
        for (int i = 0; i < 3; i++) {
          expect(
            tester.getSemantics(
              find.ancestor(
                of: find.text('Item $i'),
                matching: find.byType(InkWell),
              ),
            ),
            isSemantics(isSelected: false),
          );
        }
        handle.dispose();
      });
    }

    testWidgets('announces label, badge, selection and position', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(
        tester,
        _barHost(
          const StudioBottomBar(
            items: <StudioNavItem>[
              StudioNavItem(icon: Icons.home, label: 'Home'),
              StudioNavItem(icon: Icons.mail, label: 'Mail', badgeCount: 4),
            ],
            selectedIndex: 0,
          ),
        ),
      );
      expect(find.semantics.byLabel('Home, Tab 1 of 2'), findsOne);
      expect(
        tester.getSemantics(find.text('Home').first),
        isSemantics(
          label: 'Home, Tab 1 of 2',
          isSelected: true,
          isButton: true,
        ),
      );
      expect(find.semantics.byLabel('Mail, 4, Tab 2 of 2'), findsOne);
      expect(find.text('4'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a controller owns the selection', (WidgetTester tester) async {
      final StudioNavigationController controller = StudioNavigationController(
        initialIndex: 1,
      );
      addTearDown(controller.dispose);
      final List<int> callbacks = <int>[];
      await pumpStudio(
        tester,
        _barHost(
          StudioBottomBar(
            items: navItems(3),
            controller: controller,
            onSelected: callbacks.add,
          ),
        ),
      );
      await tester.tap(find.text('Item 2'));
      await tester.pump();
      expect(controller.index, 2);
      expect(callbacks, <int>[2]);

      controller.select(0);
      await tester.pump();
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pump();
      expect(
        tester.getSemantics(find.text('Item 0')),
        isSemantics(isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('disabled items ignore taps', (WidgetTester tester) async {
      final List<int> selections = <int>[];
      await pumpStudio(
        tester,
        _barHost(
          StudioBottomBar(
            items: const <StudioNavItem>[
              StudioNavItem(icon: Icons.home, label: 'Home'),
              StudioNavItem(icon: Icons.lock, label: 'Locked', enabled: false),
            ],
            selectedIndex: 0,
            onSelected: selections.add,
          ),
        ),
      );
      await tester.tap(find.text('Locked'));
      expect(selections, isEmpty);
    });

    testWidgets('too many items overflow into a More sheet', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(320, 700));
      final List<int> selections = <int>[];
      await pumpStudio(
        tester,
        _barHost(
          StudioBottomBar(
            items: navItems(7),
            selectedIndex: 0,
            onSelected: selections.add,
          ),
        ),
      );
      // 320 / 64 = 5 slots: four items and "More".
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.text('Item 4'), findsNothing);
      expect(find.text('More'), findsOneWidget);

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Item 6'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Item 6'));
      await tester.pumpAndSettle();
      expect(selections, <int>[6]);
    });

    testWidgets('More is selected when an overflowed item is selected', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(320, 700));
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(
        tester,
        _barHost(StudioBottomBar(items: navItems(7), selectedIndex: 5)),
      );
      expect(
        tester.getSemantics(find.text('More')),
        isSemantics(isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('label behavior controls visible labels', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _barHost(
          StudioBottomBar(
            items: navItems(3),
            selectedIndex: 1,
            labelBehavior: StudioNavLabelBehavior.onlySelected,
          ),
        ),
      );
      expect(find.text('Item 0'), findsNothing);
      expect(find.text('Item 1'), findsOneWidget);
      // Hidden labels are still available as tooltips.
      expect(find.byTooltip('Item 0'), findsOneWidget);

      await pumpStudio(
        tester,
        _barHost(
          StudioBottomBar(
            items: navItems(3),
            selectedIndex: 1,
            style: StudioBottomBarStyle.minimal,
          ),
        ),
      );
      expect(find.text('Item 1'), findsNothing);
    });

    testWidgets('selected icons and custom item builders', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _barHost(
          StudioBottomBar(
            items: const <StudioNavItem>[
              StudioNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              StudioNavItem(icon: Icons.mail_outline, label: 'Mail'),
            ],
            selectedIndex: 0,
            itemBuilder: (BuildContext context, StudioNavItem item, bool on) =>
                Text(on ? '[${item.label}]' : item.label),
          ),
        ),
      );
      expect(find.text('[Home]'), findsOneWidget);
      expect(find.text('Mail'), findsOneWidget);

      await pumpStudio(
        tester,
        _barHost(
          const StudioBottomBar(
            items: <StudioNavItem>[
              StudioNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              StudioNavItem(icon: Icons.mail_outline, label: 'Mail'),
            ],
            selectedIndex: 0,
          ),
        ),
      );
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
    });

    testWidgets('custom background, indicator and colors apply', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _barHost(
          StudioBottomBar(
            items: navItems(2),
            selectedIndex: 0,
            backgroundColor: Colors.purple,
            indicatorColor: Colors.yellow,
            selectedColor: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(StudioBottomBar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, Colors.purple);
      final Icon icon = tester.widget<Icon>(find.byIcon(Icons.home_outlined));
      expect(icon.color, Colors.red);
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is AnimatedContainer &&
              (w.decoration as ShapeDecoration?)?.color == Colors.yellow,
        ),
        findsOneWidget,
      );
    });

    testWidgets('reduced motion disables indicator animation', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _barHost(StudioBottomBar(items: navItems(3), selectedIndex: 0)),
        disableAnimations: true,
      );
      final AnimatedContainer container = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .first;
      expect(container.duration, Duration.zero);
    });

    testWidgets('grows taller at large text scales', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        _barHost(StudioBottomBar(items: navItems(3), selectedIndex: 0)),
      );
      final double normal = tester.getSize(find.byType(StudioBottomBar)).height;
      await pumpStudio(
        tester,
        _barHost(StudioBottomBar(items: navItems(3), selectedIndex: 0)),
        textScale: 3,
      );
      final double scaled = tester.getSize(find.byType(StudioBottomBar)).height;
      expect(scaled, greaterThan(normal));
      expect(tester.takeException(), isNull);
    });
  });

  group('extreme text scale', () {
    for (final StudioBottomBarStyle style in StudioBottomBarStyle.values) {
      testWidgets('${style.name} fits labels at text ×3.5', (
        WidgetTester tester,
      ) async {
        setWindowSize(tester, const Size(360, 780));
        await pumpStudio(
          tester,
          _barHost(
            StudioBottomBar(
              items: navItems(4),
              selectedIndex: 1,
              style: style,
              labelBehavior: StudioNavLabelBehavior.alwaysShow,
            ),
          ),
          textScale: 3.5,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('StudioNavigationRail', () {
    testWidgets('wraps NavigationRail and validates the index', (
      WidgetTester tester,
    ) async {
      final List<int> selections = <int>[];
      await pumpStudio(
        tester,
        Scaffold(
          body: Row(
            children: <Widget>[
              StudioNavigationRail(
                items: navItems(3),
                selectedIndex: 10,
                onSelected: selections.add,
              ),
            ],
          ),
        ),
      );
      final NavigationRail rail = tester.widget<NavigationRail>(
        find.byType(NavigationRail),
      );
      expect(rail.selectedIndex, isNull);
      expect(rail.scrollable, isTrue);
      await tester.tap(find.text('Item 1'));
      expect(selections, <int>[1]);
    });

    testWidgets('icon-only rails provide tooltips', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        Scaffold(
          body: Row(
            children: <Widget>[
              StudioNavigationRail(
                items: navItems(2),
                selectedIndex: 0,
                labelType: NavigationRailLabelType.none,
              ),
            ],
          ),
        ),
      );
      expect(find.byTooltip('Item 1'), findsOneWidget);
    });

    testWidgets('empty items render nothing', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        const Scaffold(
          body: Row(
            children: <Widget>[StudioNavigationRail(items: <StudioNavItem>[])],
          ),
        ),
      );
      expect(find.byType(NavigationRail), findsNothing);
    });
  });

  group('StudioSidebar', () {
    testWidgets('shows header, items and footer and selects', (
      WidgetTester tester,
    ) async {
      final List<int> selections = <int>[];
      setWindowSize(tester, const Size(1280, 800));
      await pumpStudio(
        tester,
        Scaffold(
          body: Row(
            children: <Widget>[
              StudioSidebar(
                items: navItems(3),
                selectedIndex: 0,
                onSelected: selections.add,
                header: const Text('Header'),
                footer: const Text('Footer'),
                width: 300,
              ),
            ],
          ),
        ),
      );
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
      expect(tester.getSize(find.byType(NavigationDrawer)).width, 300);
      await tester.tap(find.text('Item 2'));
      expect(selections, <int>[2]);
    });

    testWidgets('out-of-range selection selects nothing', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        Scaffold(
          body: Row(
            children: <Widget>[
              StudioSidebar(items: navItems(2), selectedIndex: -5),
            ],
          ),
        ),
      );
      expect(
        tester
            .widget<NavigationDrawer>(find.byType(NavigationDrawer))
            .selectedIndex,
        isNull,
      );
    });
  });

  group('StudioNavigation', () {
    test('modeFor maps window sizes and honors fixed modes', () {
      const StudioNavigation adaptive = StudioNavigation(
        items: <StudioNavItem>[],
      );
      expect(
        adaptive.modeFor(StudioWindowSize.compact),
        StudioNavigationMode.bottomBar,
      );
      expect(
        adaptive.modeFor(StudioWindowSize.medium),
        StudioNavigationMode.rail,
      );
      expect(
        adaptive.modeFor(StudioWindowSize.expanded),
        StudioNavigationMode.sidebar,
      );
      const StudioNavigation fixed = StudioNavigation(
        items: <StudioNavItem>[],
        mode: StudioNavigationMode.drawer,
      );
      expect(
        fixed.modeFor(StudioWindowSize.expanded),
        StudioNavigationMode.drawer,
      );
    });

    test('rejects both selectedIndex and controller', () {
      final StudioNavigationController controller =
          StudioNavigationController();
      expect(
        () => StudioNavigation(
          items: const <StudioNavItem>[],
          selectedIndex: 0,
          controller: controller,
        ),
        throwsAssertionError,
      );
      controller.dispose();
    });

    test('StudioNavItem equality', () {
      expect(
        const StudioNavItem(icon: Icons.home, label: 'Home'),
        const StudioNavItem(icon: Icons.home, label: 'Home'),
      );
      expect(
        const StudioNavItem(icon: Icons.home, label: 'Home'),
        isNot(const StudioNavItem(icon: Icons.home, label: 'Start')),
      );
    });
  });
}
