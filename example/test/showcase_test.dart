// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';
import 'package:scaffold_studio_example/demo_image.dart';
import 'package:scaffold_studio_example/home_page.dart';
import 'package:scaffold_studio_example/pages/app_bar_demo_page.dart';
import 'package:scaffold_studio_example/pages/app_bars_page.dart';
import 'package:scaffold_studio_example/pages/navigation_demos.dart';
import 'package:scaffold_studio_example/settings.dart';
import 'package:scaffold_studio_example/showcase_app.dart';

const Size narrowPhone = Size(320, 640);
const Size phone = Size(360, 780);
const Size phoneLandscape = Size(780, 360);
const Size tablet = Size(800, 1280);
const Size desktop = Size(1280, 800);
const Size wideDesktop = Size(1440, 900);

/// Sets the logical window size for the rest of the test.
void setWindowSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Pumps a fresh showcase at [size] and checks that it built cleanly.
Future<void> pumpShowcase(
  WidgetTester tester,
  Size size, {
  ShowcaseSettings settings = const ShowcaseSettings(),
}) async {
  setWindowSize(tester, size);
  // A new key per pump so that the root state starts from [settings].
  await tester.pumpWidget(
    ShowcaseApp(key: UniqueKey(), initialSettings: settings),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'Showcase at $size');
}

/// Pushes [page] on the root navigator and waits for the transition.
Future<void> pushPage(WidgetTester tester, Widget page) async {
  final NavigatorState navigator = tester.state<NavigatorState>(
    find.byType(Navigator).first,
  );
  // Not awaited: the route only completes when it is popped.
  navigator.push(
    MaterialPageRoute<void>(builder: (BuildContext context) => page),
  );
  await tester.pumpAndSettle();
}

/// Pops the top route and waits for the transition.
Future<void> popPage(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).first).pop();
  await tester.pumpAndSettle();
}

final Finder _anyNavigation = find.byWidgetPredicate(
  (Widget widget) =>
      widget is StudioBottomBar ||
      widget is StudioNavigationRail ||
      widget is StudioSidebar,
);

/// Taps the destination [label] in whichever navigation layout is shown.
Future<void> selectDestination(WidgetTester tester, String label) async {
  final Finder target = find.descendant(
    of: _anyNavigation,
    matching: find.text(label),
  );
  expect(target, findsWidgets, reason: 'Destination "$label"');
  // The rail and sidebar scroll when their destinations do not fit, for
  // example on a phone in landscape.
  await tester.ensureVisible(target.first);
  await tester.pumpAndSettle();
  await tester.tap(target.first);
  await tester.pumpAndSettle();
}

/// The key of each destination's page in the shell's IndexedStack.
const Map<String, String> pageKeys = <String, String>{
  'Typography': 'page-typography',
  'App bars': 'page-app-bars',
  'Navigation': 'page-navigation',
  'Widgets': 'page-widgets',
  'Settings': 'page-settings',
};

/// Checks that the shell shows [label]: the app bar title and the page,
/// which must be the one IndexedStack child that receives pointer events.
void expectDestination(String label) {
  expect(
    find.descendant(of: find.byType(StudioAppBar), matching: find.text(label)),
    findsOneWidget,
  );
  for (final MapEntry<String, String> page in pageKeys.entries) {
    expect(
      find.byKey(PageStorageKey<String>(page.value)).hitTestable(),
      page.key == label ? findsOneWidget : findsNothing,
      reason: 'Page ${page.key} while $label is selected',
    );
  }
}

/// Visits every destination and checks that each one shows without errors.
Future<void> visitAllDestinations(WidgetTester tester) async {
  for (final StudioNavItem item in showcaseDestinations) {
    await selectDestination(tester, item.label);
    expect(tester.takeException(), isNull, reason: item.label);
    expectDestination(item.label);
  }
}

void main() {
  setUp(DemoImages.resetForTesting);
  tearDown(DemoImages.resetForTesting);

  group('adaptive shell', () {
    testWidgets('360x780 shows a bottom bar and every destination', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      expect(find.byType(StudioBottomBar), findsOneWidget);
      expect(find.byType(StudioNavigationRail), findsNothing);
      expect(find.byType(StudioSidebar), findsNothing);
      expectDestination('Typography');
      await visitAllDestinations(tester);
    });

    testWidgets('800x1280 shows a rail and every destination', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, tablet);
      expect(find.byType(StudioNavigationRail), findsOneWidget);
      expect(find.byType(StudioBottomBar), findsNothing);
      expect(find.byType(StudioSidebar), findsNothing);
      await visitAllDestinations(tester);
    });

    testWidgets('1280x800 shows a sidebar and every destination', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, desktop);
      expect(find.byType(StudioSidebar), findsOneWidget);
      expect(find.byType(StudioBottomBar), findsNothing);
      expect(find.byType(StudioNavigationRail), findsNothing);
      expect(find.text('Live showcase'), findsOneWidget);
      await visitAllDestinations(tester);
    });

    testWidgets('other sizes lay out without errors', (
      WidgetTester tester,
    ) async {
      for (final Size size in <Size>[
        narrowPhone,
        phoneLandscape,
        wideDesktop,
      ]) {
        await pumpShowcase(tester, size);
        await visitAllDestinations(tester);
      }
    });

    testWidgets('selection survives resizing', (WidgetTester tester) async {
      await pumpShowcase(tester, phone);
      await selectDestination(tester, 'Widgets');
      expectDestination('Widgets');

      setWindowSize(tester, tablet);
      await tester.pumpAndSettle();
      expect(find.byType(StudioNavigationRail), findsOneWidget);
      expectDestination('Widgets');

      setWindowSize(tester, desktop);
      await tester.pumpAndSettle();
      expect(find.byType(StudioSidebar), findsOneWidget);
      expectDestination('Widgets');
      expect(tester.takeException(), isNull);
    });

    testWidgets('resizing within the compact range does not overflow', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, const Size(599, 800));
      for (final double width in <double>[480, 360, 320, 540]) {
        setWindowSize(tester, Size(width, 800));
        // Check the frames in the middle of any animation too.
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull, reason: 'Width $width');
        await tester.pumpAndSettle();
        expect(find.byType(StudioBottomBar), findsOneWidget);
      }
    });

    testWidgets('page state is preserved between destinations', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await selectDestination(tester, 'Widgets');
      final Finder nameField = find.widgetWithText(TextField, 'Name');
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'Alex');
      await selectDestination(tester, 'Settings');
      await selectDestination(tester, 'Widgets');
      expect(find.text('Alex'), findsOneWidget);
    });

    testWidgets('the floating action button opens settings', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await tester.tap(find.byTooltip('Open settings'));
      await tester.pumpAndSettle();
      expectDestination('Settings');
    });
  });

  group('settings', () {
    testWidgets('text scale 2.0 at 360 wide does not overflow', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await selectDestination(tester, 'Settings');
      final Finder chip = find.text('2.0×');
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final BuildContext context = tester.element(find.byType(ShowcaseHome));
      expect(MediaQuery.textScalerOf(context), const TextScaler.linear(2));
      await visitAllDestinations(tester);
    });

    testWidgets('large text at narrow and landscape sizes', (
      WidgetTester tester,
    ) async {
      for (final Size size in <Size>[narrowPhone, phoneLandscape, tablet]) {
        await pumpShowcase(
          tester,
          size,
          settings: const ShowcaseSettings(textScale: 2),
        );
        await visitAllDestinations(tester);
      }
    });

    testWidgets('theme mode, font and seed color apply app-wide', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(
        tester,
        phone,
        settings: const ShowcaseSettings(themeMode: ThemeMode.light),
      );
      await selectDestination(tester, 'Settings');

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      BuildContext context = tester.element(find.byType(ShowcaseHome));
      expect(Theme.of(context).brightness, Brightness.dark);

      final Finder roboto = find.text('Roboto');
      await tester.ensureVisible(roboto);
      await tester.pumpAndSettle();
      await tester.tap(roboto);
      await tester.pumpAndSettle();
      context = tester.element(find.byType(ShowcaseHome));
      expect(
        Theme.of(context).textTheme.bodyMedium?.fontFamily,
        StudioFont.roboto.resolvedFamily,
      );

      final Finder teal = find.text('Teal');
      await tester.ensureVisible(teal);
      await tester.pumpAndSettle();
      await tester.tap(teal);
      await tester.pumpAndSettle();
      context = tester.element(find.byType(ShowcaseHome));
      expect(
        Theme.of(context).colorScheme,
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          brightness: Brightness.dark,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('typography', () {
    testWidgets('links show a snack bar when tapped', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      final Finder link = find.text('View profile');
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pump();
      expect(find.text('"View profile" tapped'), findsOneWidget);
      // Let the snack bar time out.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });

  group('app bars', () {
    testWidgets('tapping a style opens its demo page', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await selectDestination(tester, 'App bars');
      final Finder card = find.byKey(
        const ValueKey<String>('app-bar-style-rounded'),
      );
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(AppBarDemoPage), findsOneWidget);
      expect(find.text('Rounded'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(AppBarDemoPage), findsNothing);
    });

    for (final StudioAppBarStyle style in StudioAppBarStyle.values) {
      testWidgets('${style.name} demo lays out at every size and text scale', (
        WidgetTester tester,
      ) async {
        for (final double scale in <double>[1, 2]) {
          for (final Size size in <Size>[
            narrowPhone,
            phone,
            phoneLandscape,
            tablet,
            desktop,
          ]) {
            await pumpShowcase(
              tester,
              size,
              settings: ShowcaseSettings(textScale: scale),
            );
            await pushPage(tester, AppBarDemoPage(style: style));
            expect(find.byType(AppBarDemoPage), findsOneWidget);
            expect(
              tester.takeException(),
              isNull,
              reason: '${style.name} at $size, scale $scale',
            );
            // The long title must ellipsize, not overflow.
            await tester.ensureVisible(find.byType(Switch));
            await tester.pumpAndSettle();
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${style.name} long title at $size, scale $scale',
            );
          }
        }
      });
    }

    testWidgets('actions overflow into a menu on narrow widths', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await pushPage(
        tester,
        const AppBarDemoPage(style: StudioAppBarStyle.standard),
      );
      expect(find.byTooltip('More options'), findsOneWidget);
      expect(find.byTooltip('Help'), findsNothing);
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      expect(find.text('Help'), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      setWindowSize(tester, wideDesktop);
      await tester.pumpAndSettle();
      expect(find.byTooltip('More options'), findsNothing);
      expect(find.byTooltip('Help'), findsOneWidget);
    });

    testWidgets('notification action clears its badge', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, desktop);
      await pushPage(
        tester,
        const AppBarDemoPage(style: StudioAppBarStyle.standard),
      );
      expect(find.text('3'), findsWidgets);
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pump();
      expect(find.text('All notifications read'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('search filters the product list', (WidgetTester tester) async {
      await pumpShowcase(tester, phone);
      await pushPage(
        tester,
        const AppBarDemoPage(style: StudioAppBarStyle.search),
      );
      expect(find.text('10 products'), findsOneWidget);
      await tester.enterText(find.byType(SearchBar), 'desk');
      await tester.pumpAndSettle();
      expect(find.text('2 products'), findsOneWidget);
      expect(find.text('Standing desk'), findsOneWidget);
    });

    testWidgets('onBackPressed asks before leaving', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await pushPage(
        tester,
        const AppBarDemoPage(style: StudioAppBarStyle.centered),
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Leave this demo?'), findsOneWidget);
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBarDemoPage), findsNothing);
    });

    testWidgets('image demo shows the fallback while the image is generated', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await pushPage(
        tester,
        const AppBarDemoPage(style: StudioAppBarStyle.image),
      );
      final StudioAppBar bar = tester.widget<StudioAppBar>(
        find.descendant(
          of: find.byType(AppBarDemoPage),
          matching: find.byType(StudioAppBar),
        ),
      );
      expect(bar.style, StudioAppBarStyle.image);
      expect(bar.backgroundImage, isNull);
      expect(find.text('Generating the image...'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('profile demo keeps the back button on a pushed route', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await pushPage(
        tester,
        const AppBarDemoPage(style: StudioAppBarStyle.profile),
      );
      final Finder bar = find.descendant(
        of: find.byType(AppBarDemoPage),
        matching: find.byType(StudioAppBar),
      );
      final Finder back = find.descendant(
        of: bar,
        matching: find.byType(BackButton),
      );
      expect(back, findsOneWidget);
      expect(find.byTooltip('Close demo'), findsNothing);
      final Finder avatar = find.descendant(
        of: bar,
        matching: find.byType(CircleAvatar),
      );
      expect(avatar, findsOneWidget);
      expect(
        tester.getCenter(avatar).dx,
        greaterThan(tester.getCenter(back).dx),
      );
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(find.byType(AppBarDemoPage), findsNothing);
    });

    testWidgets('flexible demo ellipsizes the name in the leading widget', (
      WidgetTester tester,
    ) async {
      for (final Size size in <Size>[narrowPhone, desktop]) {
        await pumpShowcase(tester, size);
        await pushPage(
          tester,
          const AppBarDemoPage(style: StudioAppBarStyle.flexible),
        );
        expect(find.text('Alex Johnson'), findsOneWidget);
        expect(
          find.text('Invite'),
          size == desktop ? findsOneWidget : findsNothing,
        );
        expect(
          find.byTooltip('Invite'),
          size == desktop ? findsNothing : findsOneWidget,
        );
        expect(tester.takeException(), isNull, reason: '$size');
      }
    });

    testWidgets('image demo uses the generated MemoryImage', (
      WidgetTester tester,
    ) async {
      final ImageProvider<Object>? image = await tester.runAsync(
        DemoImages.header,
      );
      expect(image, isA<MemoryImage>());
      await pumpShowcase(tester, phone);
      await pushPage(
        tester,
        const AppBarDemoPage(style: StudioAppBarStyle.image),
      );
      final StudioAppBar bar = tester.widget<StudioAppBar>(
        find.descendant(
          of: find.byType(AppBarDemoPage),
          matching: find.byType(StudioAppBar),
        ),
      );
      expect(bar.style, StudioAppBarStyle.image);
      expect(bar.backgroundImage, same(image));
      expect(tester.takeException(), isNull);
    });
  });

  group('navigation', () {
    Future<void> openNavigationPage(
      WidgetTester tester,
      Size size, {
      double? textScale,
    }) async {
      await pumpShowcase(
        tester,
        size,
        settings: ShowcaseSettings(textScale: textScale),
      );
      await selectDestination(tester, 'Navigation');
    }

    Future<void> tapChip(WidgetTester tester, String label) async {
      final Finder chip = find.widgetWithText(ChoiceChip, label);
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
    }

    final Finder previewBar = find.byKey(
      const ValueKey<String>('preview-bottom-bar'),
    );

    testWidgets('every preview style, count and label behavior lays out', (
      WidgetTester tester,
    ) async {
      for (final (Size, double) setup in <(Size, double)>[
        (narrowPhone, 2),
        (phone, 1),
        (desktop, 1),
      ]) {
        await openNavigationPage(tester, setup.$1, textScale: setup.$2);
        for (final StudioBottomBarStyle style in StudioBottomBarStyle.values) {
          await tapChip(tester, bottomBarStyleName(style));
          for (final int count in <int>[2, 7]) {
            await tapChip(tester, '$count');
            for (final StudioNavLabelBehavior? labels
                in <StudioNavLabelBehavior?>[
                  null,
                  ...StudioNavLabelBehavior.values,
                ]) {
              await tapChip(tester, labelBehaviorName(labels));
              expect(
                tester.takeException(),
                isNull,
                reason: '$style, $count items, $labels at ${setup.$1}',
              );
            }
          }
        }
      }
    });

    testWidgets('seven destinations overflow into More', (
      WidgetTester tester,
    ) async {
      await openNavigationPage(tester, phone);
      await tapChip(tester, '7');
      await tester.ensureVisible(previewBar);
      await tester.pumpAndSettle();
      final Finder more = find.descendant(
        of: previewBar,
        matching: find.text('More'),
      );
      expect(more, findsOneWidget);
      await tester.tap(more);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Selected: Settings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('demo buttons push full-screen demos', (
      WidgetTester tester,
    ) async {
      await openNavigationPage(tester, phone);
      final Finder rail = find.widgetWithText(CommonButton, 'Rail');
      await tester.ensureVisible(rail);
      await tester.pumpAndSettle();
      await tester.tap(rail);
      await tester.pumpAndSettle();
      expect(find.byType(FixedNavigationDemo), findsOneWidget);
      expect(find.byType(StudioNavigationRail), findsOneWidget);
      await tester.tap(find.byTooltip('Close demo'));
      await tester.pumpAndSettle();
      expect(find.byType(FixedNavigationDemo), findsNothing);
    });

    for (final StudioNavigationMode mode in <StudioNavigationMode>[
      StudioNavigationMode.bottomBar,
      StudioNavigationMode.rail,
      StudioNavigationMode.sidebar,
      StudioNavigationMode.drawer,
    ]) {
      testWidgets('fixed ${mode.name} demo at every size', (
        WidgetTester tester,
      ) async {
        for (final double scale in <double>[1, 2]) {
          for (final Size size in <Size>[
            narrowPhone,
            phone,
            phoneLandscape,
            tablet,
            desktop,
          ]) {
            await pumpShowcase(
              tester,
              size,
              settings: ShowcaseSettings(textScale: scale),
            );
            await pushPage(
              tester,
              FixedNavigationDemo(mode: mode, itemCount: 7),
            );
            final Finder demo = find.byType(FixedNavigationDemo);
            Finder inDemo(Type type) =>
                find.descendant(of: demo, matching: find.byType(type));
            switch (mode) {
              case StudioNavigationMode.bottomBar:
                expect(inDemo(StudioBottomBar), findsOneWidget);
              case StudioNavigationMode.rail:
                expect(inDemo(StudioNavigationRail), findsOneWidget);
              case StudioNavigationMode.sidebar:
                expect(inDemo(StudioSidebar), findsOneWidget);
              case StudioNavigationMode.drawer:
                expect(inDemo(StudioSidebar), findsNothing);
                await tester.tap(find.byTooltip('Open navigation menu'));
                await tester.pumpAndSettle();
                expect(find.byType(StudioSidebar), findsOneWidget);
                await tester.tap(
                  find.descendant(
                    of: find.byType(StudioSidebar),
                    matching: find.text('Inbox'),
                  ),
                );
                await tester.pumpAndSettle();
                expect(find.byType(StudioSidebar), findsNothing);
                expect(
                  find.descendant(
                    of: find.byType(StudioAppBar),
                    matching: find.text('Inbox'),
                  ),
                  findsOneWidget,
                );
              case StudioNavigationMode.adaptive:
                break;
            }
            expect(
              tester.takeException(),
              isNull,
              reason: '${mode.name} at $size, scale $scale',
            );
          }
        }
      });
    }

    testWidgets('every bottom bar style in a full-screen demo', (
      WidgetTester tester,
    ) async {
      for (final Size size in <Size>[narrowPhone, phone, desktop]) {
        for (final StudioBottomBarStyle style in StudioBottomBarStyle.values) {
          await pumpShowcase(
            tester,
            size,
            settings: const ShowcaseSettings(textScale: 2),
          );
          await pushPage(
            tester,
            FixedNavigationDemo(
              mode: StudioNavigationMode.bottomBar,
              bottomBarStyle: style,
              itemCount: 5,
            ),
          );
          if (style == StudioBottomBarStyle.notched) {
            expect(find.byType(BottomAppBar), findsOneWidget);
            expect(find.byType(FloatingActionButton), findsWidgets);
          }
          expect(
            tester.takeException(),
            isNull,
            reason: '${style.name} at $size',
          );
        }
      }
    });

    testWidgets('controller demo selects from taps, code and resizes', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await pushPage(tester, const ControllerNavigationDemo());
      expect(find.text('controller.index = 0 (Home)'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(StudioBottomBar),
          matching: find.text('Inbox'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('controller.index = 1 (Inbox)'), findsOneWidget);

      final Finder goToSearch = find.text('Go to Search');
      await tester.ensureVisible(goToSearch);
      await tester.pumpAndSettle();
      await tester.tap(goToSearch);
      await tester.pumpAndSettle();
      expect(find.text('controller.index = 2 (Search)'), findsOneWidget);

      setWindowSize(tester, desktop);
      await tester.pumpAndSettle();
      expect(find.byType(StudioSidebar), findsOneWidget);
      expect(find.text('controller.index = 2 (Search)'), findsOneWidget);

      // Closing the demo disposes the controller without errors.
      await popPage(tester);
      expect(find.byType(ControllerNavigationDemo), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('widgets page', () {
    testWidgets('responsive grid follows the available width', (
      WidgetTester tester,
    ) async {
      final Map<Size, String> expected = <Size, String>{
        phone: '1 column',
        tablet: '2 columns',
        desktop: '3 columns',
      };
      for (final MapEntry<Size, String> entry in expected.entries) {
        await pumpShowcase(tester, entry.key);
        await selectDestination(tester, 'Widgets');
        expect(
          find.textContaining(entry.value),
          findsOneWidget,
          reason: 'Grid at ${entry.key}',
        );
      }
    });

    testWidgets('expand fills the width and long divider labels wrap', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(
        tester,
        narrowPhone,
        settings: const ShowcaseSettings(textScale: 2),
      );
      await selectDestination(tester, 'Widgets');
      final Finder expanded = find.ancestor(
        of: find.text('Expanded to the full width'),
        matching: find.byType(FilledButton),
      );
      final Finder section = find.ancestor(
        of: expanded,
        matching: find.byType(Column),
      );
      expect(
        tester.getSize(expanded).width,
        tester.getSize(section.first).width,
      );
      final Finder label = find.text('Or continue with one of these accounts');
      await tester.ensureVisible(label);
      await tester.pumpAndSettle();
      // Wrapped onto several lines rather than overflowing.
      expect(tester.getSize(label).height, greaterThan(40));
      expect(tester.takeException(), isNull);
    });

    testWidgets('loading toggle and bookmark toggle', (
      WidgetTester tester,
    ) async {
      await pumpShowcase(tester, phone);
      await selectDestination(tester, 'Widgets');
      final Finder loading = find.widgetWithText(SwitchListTile, 'Loading');
      await tester.ensureVisible(loading);
      await tester.pumpAndSettle();
      await tester.tap(loading);
      // The spinner animates forever, so do not wait for it to settle.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(loading);
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      final Finder bookmark = find.byTooltip('Bookmark');
      await tester.ensureVisible(bookmark);
      await tester.pumpAndSettle();
      await tester.tap(bookmark);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove bookmark'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('app bar names cover every style', () {
    for (final StudioAppBarStyle style in StudioAppBarStyle.values) {
      expect(appBarStyleName(style), isNotEmpty);
    }
  });
}
