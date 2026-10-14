// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

void main() {
  group('CommonButton', () {
    const Map<CommonButtonVariant, Type> expectedTypes =
        <CommonButtonVariant, Type>{
          CommonButtonVariant.filled: FilledButton,
          CommonButtonVariant.tonal: FilledButton,
          CommonButtonVariant.elevated: ElevatedButton,
          CommonButtonVariant.outlined: OutlinedButton,
          CommonButtonVariant.text: TextButton,
        };

    for (final MapEntry<CommonButtonVariant, Type> entry
        in expectedTypes.entries) {
      testWidgets('${entry.key.name} builds a ${entry.value}', (
        WidgetTester tester,
      ) async {
        int taps = 0;
        await pumpStudio(
          tester,
          Center(
            child: CommonButton(
              label: 'Go',
              variant: entry.key,
              onPressed: () => taps++,
            ),
          ),
        );
        expect(find.byType(entry.value), findsOneWidget);
        await tester.tap(find.text('Go'));
        expect(taps, 1);
      });
    }

    testWidgets('size sets the minimum height', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        Center(
          child: CommonButton(
            label: 'Large',
            size: CommonButtonSize.large,
            onPressed: () {},
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(56),
      );
    });

    testWidgets('is disabled without onPressed', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        const Center(child: CommonButton(label: 'Off', onPressed: null)),
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('loading shows progress and ignores taps', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int taps = 0;
      await pumpStudio(
        tester,
        Center(
          child: CommonButton(
            label: 'Save',
            icon: Icons.check,
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(FilledButton)),
        isSemantics(label: 'Save', value: 'Loading', isButton: true),
      );
      expect(find.byIcon(Icons.check), findsNothing);
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(taps, 0);
      handle.dispose();
    });

    testWidgets('icon placement and expand', (WidgetTester tester) async {
      setWindowSize(tester, const Size(400, 400));
      await pumpStudio(
        tester,
        Column(
          children: <Widget>[
            CommonButton(
              label: 'Next',
              icon: Icons.arrow_forward,
              trailingIcon: true,
              expand: true,
              onPressed: () {},
            ),
          ],
        ),
      );
      expect(tester.getSize(find.byType(FilledButton)).width, 400);
      expect(
        tester.getCenter(find.byIcon(Icons.arrow_forward)).dx,
        greaterThan(tester.getCenter(find.text('Next')).dx),
      );
    });

    testWidgets('long labels do not overflow', (WidgetTester tester) async {
      setWindowSize(tester, const Size(200, 400));
      await pumpStudio(
        tester,
        Center(
          child: CommonButton(
            label: 'A very long button label that cannot fit ' * 3,
            icon: Icons.check,
            onPressed: () {},
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('CommonIconButton', () {
    testWidgets('tooltip is the accessible label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int taps = 0;
      await pumpStudio(
        tester,
        Center(
          child: CommonIconButton(
            icon: Icons.favorite,
            tooltip: 'Favorite',
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.byTooltip('Favorite'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(tooltip: 'Favorite', isButton: true),
      );
      await tester.tap(find.byIcon(Icons.favorite));
      expect(taps, 1);
      expect(tester.getSize(find.byType(IconButton)).width, greaterThan(47));
      handle.dispose();
    });

    testWidgets('semanticsLabel works without a tooltip', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(
        tester,
        Center(
          child: CommonIconButton(
            icon: Icons.close,
            semanticsLabel: 'Close',
            onPressed: () {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(label: 'Close', isButton: true),
      );
      handle.dispose();
    });

    test('requires a tooltip or semanticsLabel', () {
      expect(
        () => CommonIconButton(icon: Icons.close, onPressed: () {}),
        throwsAssertionError,
      );
    });

    testWidgets('variants and badges', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        Row(
          children: <Widget>[
            for (final CommonIconButtonVariant variant
                in CommonIconButtonVariant.values)
              CommonIconButton(
                icon: Icons.mail,
                tooltip: variant.name,
                variant: variant,
                badgeCount: 5,
                onPressed: () {},
              ),
          ],
        ),
      );
      expect(find.byType(IconButton), findsNWidgets(4));
      expect(find.text('5'), findsNWidgets(4));
    });
  });

  group('CommonBadge', () {
    test('formats counts', () {
      expect(const CommonBadge(count: 7).displayText, '7');
      expect(const CommonBadge(count: 100).displayText, '99+');
      expect(const CommonBadge(count: 12, maxCount: 9).displayText, '9+');
      expect(const CommonBadge(label: 'New').displayText, 'New');
      expect(const CommonBadge(label: '').displayText, isNull);
      expect(const CommonBadge().displayText, isNull);
    });

    test('zero counts are hidden unless requested', () {
      expect(const CommonBadge(count: 0).effectiveVisible, isFalse);
      expect(
        const CommonBadge(count: 0, showZero: true).effectiveVisible,
        isTrue,
      );
      expect(
        const CommonBadge(count: 3, isVisible: false).effectiveVisible,
        isFalse,
      );
    });

    testWidgets('renders a Material badge with semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(
        tester,
        const Center(
          child: CommonBadge(
            count: 120,
            semanticsLabel: '120 unread',
            child: Icon(Icons.mail),
          ),
        ),
      );
      expect(find.text('99+'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('120 unread')), findsOneWidget);
      final Badge badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
      handle.dispose();
    });
  });

  group('CommonCard', () {
    testWidgets('variants and tap handling', (WidgetTester tester) async {
      int taps = 0;
      await pumpStudio(
        tester,
        Column(
          children: <Widget>[
            CommonCard(onTap: () => taps++, child: const Text('elevated')),
            const CommonCard(
              variant: CommonCardVariant.filled,
              child: Text('filled'),
            ),
            CommonCard(
              variant: CommonCardVariant.outlined,
              borderRadius: BorderRadius.circular(4),
              semanticsLabel: 'Outlined card',
              child: const Text('outlined'),
            ),
          ],
        ),
      );
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.text('elevated'));
      expect(taps, 1);
    });
  });

  group('CommonDivider', () {
    testWidgets('plain, labeled and vertical', (WidgetTester tester) async {
      setWindowSize(tester, const Size(320, 400));
      await pumpStudio(
        tester,
        const Column(
          children: <Widget>[
            CommonDivider(),
            CommonDivider(label: 'OR continue with a very long label text'),
            SizedBox(
              height: 40,
              child: Row(
                children: <Widget>[
                  Text('A'),
                  CommonDivider(axis: Axis.vertical),
                  Text('B'),
                ],
              ),
            ),
          ],
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Divider), findsNWidgets(3));
      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(find.textContaining('OR continue'), findsOneWidget);
    });
  });
}
