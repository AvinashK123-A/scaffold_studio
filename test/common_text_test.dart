// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

TextStyle _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

void main() {
  group('CommonHeaderText', () {
    testWidgets('uses the themed header style by default', (
      WidgetTester tester,
    ) async {
      await pumpStudio(tester, const CommonHeaderText('Hello'));
      final ThemeData theme = Theme.of(tester.element(find.text('Hello')));
      final TextStyle style = _styleOf(tester, 'Hello');
      expect(style.fontSize, theme.textTheme.titleLarge!.fontSize);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.decoration, isNot(TextDecoration.underline));
    });

    testWidgets('applies individual overrides', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        const CommonHeaderText(
          'Hi Alex, how are you?',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          maxLines: 2,
          letterSpacing: 0.5,
          lineHeight: 1.4,
          fontStyle: FontStyle.italic,
          textAlign: TextAlign.center,
        ),
      );
      final Text text = tester.widget<Text>(find.text('Hi Alex, how are you?'));
      expect(text.style!.fontSize, 20);
      expect(text.style!.fontWeight, FontWeight.w600);
      expect(text.style!.color, Colors.black);
      expect(text.style!.letterSpacing, 0.5);
      expect(text.style!.height, 1.4);
      expect(text.style!.fontStyle, FontStyle.italic);
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('individual arguments win over style, which wins over theme', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        const CommonBodyText(
          'precedence',
          style: TextStyle(fontSize: 30, color: Colors.green),
          fontSize: 12,
        ),
        typography: const StudioTypography(
          body: TextStyle(fontSize: 40, letterSpacing: 3),
        ),
      );
      final TextStyle style = _styleOf(tester, 'precedence');
      expect(style.fontSize, 12);
      expect(style.color, Colors.green);
      expect(style.letterSpacing, 3);
    });

    testWidgets('is announced as a heading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(tester, const CommonHeaderText('Section'));
      expect(
        tester.getSemantics(find.text('Section')),
        matchesSemantics(label: 'Section', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('non-positive fontSize and maxLines are rejected in debug', (
      WidgetTester tester,
    ) async {
      expect(() => CommonHeaderText('x', fontSize: 0), throwsAssertionError);
      expect(() => CommonHeaderText('x', maxLines: 0), throwsAssertionError);
    });
  });

  group('link mode', () {
    testWidgets('uses the theme link color and an underline by default', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        CommonHeaderText('View profile', link: true, onTap: () {}),
      );
      final StudioThemeData tokens = StudioThemeData.of(
        tester.element(find.text('View profile')),
      );
      final TextStyle style = _styleOf(tester, 'View profile');
      expect(style.color, tokens.linkColor);
      expect(style.decoration, TextDecoration.underline);
    });

    testWidgets('underline: false removes only the underline', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpStudio(
        tester,
        CommonHeaderText(
          'Open dashboard',
          link: true,
          underline: false,
          onTap: () => taps++,
        ),
      );
      final TextStyle style = _styleOf(tester, 'Open dashboard');
      expect(style.decoration, TextDecoration.none);
      expect(
        style.color,
        StudioThemeData.of(
          tester.element(find.text('Open dashboard')),
        ).linkColor,
      );
      await tester.tap(find.text('Open dashboard'));
      expect(taps, 1);
    });

    testWidgets('a custom theme link color is used', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        CommonBodyText('link', link: true, onTap: () {}),
        theme: const StudioTheme(linkColor: Color(0xFF00AA00)),
      );
      expect(_styleOf(tester, 'link').color, const Color(0xFF00AA00));
    });

    testWidgets('dark themes get a lighter link color', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        CommonBodyText('link', link: true, onTap: () {}),
        theme: StudioTheme.dark,
      );
      final Color color = _styleOf(tester, 'link').color!;
      expect(
        color.computeLuminance(),
        greaterThan(
          StudioThemeData.defaultLinkColor(Brightness.light).computeLuminance(),
        ),
      );
    });

    testWidgets('extra decorations combine with the underline', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        CommonBodyText(
          'combo',
          link: true,
          decoration: TextDecoration.lineThrough,
          underlineColor: Colors.red,
          underlineStyle: TextDecorationStyle.dashed,
          onTap: () {},
        ),
      );
      final TextStyle style = _styleOf(tester, 'combo');
      expect(style.decoration!.contains(TextDecoration.underline), isTrue);
      expect(style.decoration!.contains(TextDecoration.lineThrough), isTrue);
      expect(style.decorationColor, Colors.red);
      expect(style.decorationStyle, TextDecorationStyle.dashed);
    });

    testWidgets('an explicit color overrides the link color', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        CommonBodyText('red', link: true, color: Colors.red, onTap: () {}),
      );
      expect(_styleOf(tester, 'red').color, Colors.red);
    });

    test('a link without onTap fails an assertion', () {
      expect(
        () => CommonHeaderText('broken', link: true),
        throwsA(
          isA<AssertionError>().having(
            (AssertionError e) => e.message,
            'message',
            contains('onTap'),
          ),
        ),
      );
    });

    testWidgets('links expose link semantics and a tap action', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(
        tester,
        CommonBodyText('Terms', link: true, onTap: () {}),
      );
      expect(
        tester.getSemantics(find.text('Terms')),
        matchesSemantics(
          label: 'Terms',
          isLink: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('non-link text with onTap is announced as a button', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpStudio(tester, CommonLabelText('Retry', onTap: () {}));
      expect(
        tester.getSemantics(find.text('Retry')),
        matchesSemantics(
          label: 'Retry',
          isButton: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      expect(
        _styleOf(tester, 'Retry').decoration,
        isNot(TextDecoration.underline),
      );
      handle.dispose();
    });

    testWidgets('can be focused and activated from the keyboard', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pumpStudio(
        tester,
        Column(
          children: <Widget>[
            CommonBodyText('First', link: true, onTap: () => taps += 1),
            CommonBodyText('Second', link: true, onTap: () => taps += 10),
          ],
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 11);
    });

    testWidgets('shows a click cursor on hover', (WidgetTester tester) async {
      await pumpStudio(
        tester,
        Center(child: CommonBodyText('hover me', link: true, onTap: () {})),
      );
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(
        location: tester.getCenter(find.text('hover me')),
      );
      await tester.pump();
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.click,
      );
      await gesture.removePointer();
    });

    testWidgets('pads the touch target to 48 when the theme asks for it', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        Center(child: CommonLabelText('tiny', link: true, onTap: () {})),
      );
      final Finder region = find.ancestor(
        of: find.text('tiny'),
        matching: find.byType(GestureDetector),
      );
      expect(tester.getSize(region.first).height, greaterThanOrEqualTo(48));
    });
  });

  group('plain text', () {
    testWidgets('adds no gesture detector without onTap', (
      WidgetTester tester,
    ) async {
      await pumpStudio(tester, const CommonBodyText('static'));
      expect(
        find.ancestor(
          of: find.text('static'),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('remains selectable inside a SelectionArea', (
      WidgetTester tester,
    ) async {
      await pumpStudio(
        tester,
        const SelectionArea(child: CommonBodyText('Select me')),
      );
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.text('Select me'),
          matching: find.byType(RichText),
        ),
      );
      expect(paragraph.registrar, isNotNull);
    });

    testWidgets('long text wraps without overflow at large text scales', (
      WidgetTester tester,
    ) async {
      setWindowSize(tester, const Size(320, 640));
      await pumpStudio(
        tester,
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CommonHeaderText('Long heading ' * 20),
              CommonBodyText('Long body ' * 40, maxLines: 3),
              CommonLabelText('Long link ' * 10, link: true, onTap: () {}),
            ],
          ),
        ),
        textScale: 3,
      );
      expect(tester.takeException(), isNull);
      final Text body = tester.widget<Text>(find.textContaining('Long body'));
      expect(body.overflow, TextOverflow.ellipsis);
    });

    testWidgets('respects the system text scale', (WidgetTester tester) async {
      await pumpStudio(tester, const CommonBodyText('scaled'), textScale: 2);
      final RichText rich = tester.widget<RichText>(
        find.descendant(
          of: find.text('scaled'),
          matching: find.byType(RichText),
        ),
      );
      expect(rich.textScaler, const TextScaler.linear(2));
    });
  });
}
