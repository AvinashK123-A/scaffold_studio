// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

void main() {
  group('StudioBreakpoints.sizeFor', () {
    const StudioBreakpoints breakpoints = StudioBreakpoints.material;

    const List<(double, StudioWindowSize)> expected =
        <(double, StudioWindowSize)>[
          (320, StudioWindowSize.compact),
          (360, StudioWindowSize.compact),
          (390, StudioWindowSize.compact),
          (430, StudioWindowSize.compact),
          (599.9, StudioWindowSize.compact),
          (600, StudioWindowSize.medium),
          (768, StudioWindowSize.medium),
          (839.9, StudioWindowSize.medium),
          (840, StudioWindowSize.expanded),
          (1024, StudioWindowSize.expanded),
          (1280, StudioWindowSize.expanded),
          (1440, StudioWindowSize.expanded),
        ];
    for (final (double width, StudioWindowSize size) in expected) {
      test('$width is ${size.name}', () {
        expect(breakpoints.sizeFor(width), size);
      });
    }

    test('custom thresholds are respected', () {
      const StudioBreakpoints custom = StudioBreakpoints(
        medium: 500,
        expanded: 1000,
      );
      expect(custom.sizeFor(499), StudioWindowSize.compact);
      expect(custom.sizeFor(500), StudioWindowSize.medium);
      expect(custom.sizeFor(999), StudioWindowSize.medium);
      expect(custom.sizeFor(1000), StudioWindowSize.expanded);
    });

    test('degenerate widths do not throw', () {
      expect(breakpoints.sizeFor(double.infinity), StudioWindowSize.expanded);
      expect(breakpoints.sizeFor(double.nan), StudioWindowSize.compact);
      expect(breakpoints.sizeFor(-10), StudioWindowSize.compact);
      expect(breakpoints.sizeFor(0), StudioWindowSize.compact);
    });

    test('invalid thresholds fail assertions in debug builds', () {
      expect(
        () => StudioBreakpoints(medium: 0, expanded: 10),
        throwsAssertionError,
      );
      expect(
        () => StudioBreakpoints(medium: 800, expanded: 600),
        throwsAssertionError,
      );
    });

    test('equality and copyWith', () {
      expect(StudioBreakpoints.material.medium, 600);
      expect(StudioBreakpoints.material.expanded, 840);
      expect(breakpoints.copyWith(), StudioBreakpoints.material);
      expect(
        breakpoints.copyWith(expanded: 900),
        const StudioBreakpoints(expanded: 900),
      );
      expect(
        breakpoints.copyWith(expanded: 900).hashCode,
        const StudioBreakpoints(expanded: 900).hashCode,
      );
    });
  });

  group('StudioWindowSize helpers', () {
    test('flags', () {
      expect(StudioWindowSize.compact.isCompact, isTrue);
      expect(StudioWindowSize.compact.isMediumOrLarger, isFalse);
      expect(StudioWindowSize.medium.isMediumOrLarger, isTrue);
      expect(StudioWindowSize.expanded.isExpanded, isTrue);
    });
  });

  group('StudioResponsiveBuilder', () {
    testWidgets('uses parent constraints rather than the window', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(1280, 800));
      StudioWindowSize? inner;
      StudioWindowSize? window;
      await pumpStudio(
        tester,
        Row(
          children: <Widget>[
            SizedBox(
              width: 400,
              child: StudioResponsiveBuilder(
                builder: (BuildContext context, StudioWindowSize size, _) {
                  inner = size;
                  window = StudioResponsiveBuilder.windowSizeOf(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      );
      expect(inner, StudioWindowSize.compact);
      expect(window, StudioWindowSize.expanded);
    });

    testWidgets('uses theme breakpoints and explicit overrides', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(700, 800));
      final List<StudioWindowSize> sizes = <StudioWindowSize>[];
      await pumpStudio(
        tester,
        Column(
          children: <Widget>[
            StudioResponsiveBuilder(
              builder: (BuildContext context, StudioWindowSize size, _) {
                sizes.add(size);
                return const SizedBox.shrink();
              },
            ),
            StudioResponsiveBuilder(
              breakpoints: const StudioBreakpoints(medium: 300, expanded: 650),
              builder: (BuildContext context, StudioWindowSize size, _) {
                sizes.add(size);
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        theme: const StudioTheme(
          breakpoints: StudioBreakpoints(medium: 720, expanded: 1000),
        ),
      );
      expect(sizes, <StudioWindowSize>[
        StudioWindowSize.compact,
        StudioWindowSize.expanded,
      ]);
    });
  });
}
