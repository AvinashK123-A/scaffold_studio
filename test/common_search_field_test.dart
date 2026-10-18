// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'test_utils.dart';

Widget _host(Widget field) {
  return Scaffold(
    body: Center(
      child: Padding(padding: const EdgeInsets.all(16), child: field),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget field, {
  StudioTheme theme = StudioTheme.light,
  double textScale = 1,
}) {
  return pumpStudio(tester, _host(field), theme: theme, textScale: textScale);
}

Future<void> _pumpWithTheme(
  WidgetTester tester,
  Widget field,
  ThemeData theme,
) {
  return tester.pumpWidget(MaterialApp(theme: theme, home: _host(field)));
}

InputDecoration _decoration(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

TextField _textField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

Finder get _clearButton => find.byTooltip('Clear');

void main() {
  group('CommonSearchField basics', () {
    testWidgets('shows the hint and the search icon', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const CommonSearchField(hintText: 'Find people'));
      expect(find.text('Find people'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(_clearButton, findsNothing);
      expect(_textField(tester).textInputAction, TextInputAction.search);
    });

    testWidgets('a custom hint widget replaces the hint text', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const CommonSearchField(hint: Text('Custom hint')));
      expect(find.text('Custom hint'), findsOneWidget);
      expect(find.text('Search'), findsNothing);
    });

    testWidgets('typing reports changes and shows the clear button', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await _pump(tester, CommonSearchField(onChanged: changes.add));
      await tester.enterText(find.byType(TextField), 'shoes');
      await tester.pump();
      expect(changes, <String>['shoes']);
      expect(_clearButton, findsOneWidget);
    });

    testWidgets('the clear button clears and notifies', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      int cleared = 0;
      await _pump(
        tester,
        CommonSearchField(
          initialValue: 'boots',
          onChanged: changes.add,
          onCleared: () => cleared++,
        ),
      );
      expect(find.text('boots'), findsOneWidget);
      await tester.tap(_clearButton);
      await tester.pump();
      expect(find.text('boots'), findsNothing);
      expect(changes, <String>['']);
      expect(cleared, 1);
      expect(_clearButton, findsNothing);
    });

    testWidgets('onSubmitted receives the text', (WidgetTester tester) async {
      String? submitted;
      await _pump(
        tester,
        CommonSearchField(onSubmitted: (String value) => submitted = value),
      );
      await tester.enterText(find.byType(TextField), 'hats');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(submitted, 'hats');
    });

    testWidgets('readOnly forwards taps and hides the clear button', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await _pump(
        tester,
        CommonSearchField(
          initialValue: 'fixed',
          readOnly: true,
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(taps, 1);
      expect(_clearButton, findsNothing);
    });

    testWidgets('disabled fields ignore input and dim the text', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(
          initialValue: 'off',
          enabled: false,
          style: CommonSearchFieldStyle(
            textStyle: TextStyle(color: Color(0xFF000000)),
          ),
        ),
      );
      final TextField field = _textField(tester);
      expect(field.enabled, isFalse);
      expect(field.style!.color!.a, closeTo(0.38, 0.01));
      expect(_clearButton, findsNothing);
    });

    testWidgets('shows a loading indicator with a label', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(isLoading: true, loadingLabel: 'Searching'),
      );
      final Finder finder = find.byType(CircularProgressIndicator);
      final CircularProgressIndicator indicator = tester.widget(finder);
      expect(indicator.semanticsLabel, 'Searching');
    });

    testWidgets('shows trailing widgets and a custom prefix', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        CommonSearchField(
          prefix: const Icon(Icons.person),
          trailing: <Widget>[
            IconButton(
              icon: const Icon(Icons.mic),
              tooltip: 'Voice search',
              onPressed: () {},
            ),
          ],
        ),
      );
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byTooltip('Voice search'), findsOneWidget);
    });

    testWidgets('showPrefixIcon false hides the prefix icon', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const CommonSearchField(showPrefixIcon: false));
      expect(find.byIcon(Icons.search), findsNothing);
      expect(_decoration(tester).prefixIcon, isNull);
    });

    testWidgets('maxLength limits input without showing a counter', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const CommonSearchField(maxLength: 3));
      await tester.enterText(find.byType(TextField), 'abcdef');
      await tester.pump();
      expect(find.text('abc'), findsOneWidget);
      expect(find.text('3/3'), findsNothing);
    });
  });

  group('CommonSearchField search callback', () {
    testWidgets('debounces onSearch', (WidgetTester tester) async {
      final List<String> queries = <String>[];
      await _pump(tester, CommonSearchField(onSearch: queries.add));
      final Finder field = find.byType(TextField);
      await tester.enterText(field, 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(field, 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(field, 'abc');
      await tester.pump(const Duration(milliseconds: 299));
      expect(queries, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(queries, <String>['abc']);
    });

    testWidgets('Duration.zero searches on every edit', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      await _pump(
        tester,
        CommonSearchField(onSearch: queries.add, searchDebounce: Duration.zero),
      );
      await tester.enterText(find.byType(TextField), 'a');
      await tester.enterText(find.byType(TextField), 'ab');
      expect(queries, <String>['a', 'ab']);
    });

    testWidgets('trims, skips short queries and de-duplicates', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      await _pump(
        tester,
        CommonSearchField(
          onSearch: queries.add,
          searchDebounce: Duration.zero,
          minSearchLength: 3,
        ),
      );
      final Finder field = find.byType(TextField);
      await tester.enterText(field, 'ab');
      await tester.enterText(field, '  abc ');
      await tester.enterText(field, 'abc');
      await tester.enterText(field, '');
      expect(queries, <String>['abc', '']);
    });

    testWidgets('keeps whitespace when trimSearchQuery is false', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      await _pump(
        tester,
        CommonSearchField(
          onSearch: queries.add,
          searchDebounce: Duration.zero,
          trimSearchQuery: false,
        ),
      );
      await tester.enterText(find.byType(TextField), ' a ');
      expect(queries, <String>[' a ']);
    });

    testWidgets('submitting searches immediately, even for the same query', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      await _pump(tester, CommonSearchField(onSearch: queries.add));
      await tester.enterText(find.byType(TextField), 'tea');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(queries, <String>['tea']);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(milliseconds: 500));
      expect(queries, <String>['tea', 'tea']);
    });

    testWidgets('clearing searches immediately with an empty query', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      await _pump(
        tester,
        CommonSearchField(onSearch: queries.add, initialValue: 'milk'),
      );
      await tester.tap(_clearButton);
      await tester.pump();
      expect(queries, <String>['']);
    });

    testWidgets('a pending search is cancelled on dispose', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      await _pump(tester, CommonSearchField(onSearch: queries.add));
      await tester.enterText(find.byType(TextField), 'late');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(queries, isEmpty);
    });
  });

  group('CommonSearchField keyboard and focus', () {
    testWidgets('Escape clears a focused field', (WidgetTester tester) async {
      int cleared = 0;
      await _pump(
        tester,
        CommonSearchField(initialValue: 'socks', onCleared: () => cleared++),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('socks'), findsNothing);
      expect(cleared, 1);
    });

    testWidgets('Escape does nothing when clearOnEscape is false', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(initialValue: 'socks', clearOnEscape: false),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('socks'), findsOneWidget);
    });

    testWidgets('reports focus changes', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        CommonSearchField(focusNode: node, onFocusChange: changes.add),
      );
      node.requestFocus();
      await tester.pump();
      node.unfocus();
      await tester.pump();
      expect(changes, <bool>[true, false]);
    });

    testWidgets('autofocus focuses the field', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _pump(tester, CommonSearchField(focusNode: node, autofocus: true));
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });
  });

  group('CommonSearchField clear button modes', () {
    testWidgets('never hides the clear button', (WidgetTester tester) async {
      await _pump(
        tester,
        const CommonSearchField(
          initialValue: 'x',
          clearButtonMode: CommonSearchFieldClearButtonMode.never,
        ),
      );
      expect(_clearButton, findsNothing);
    });

    testWidgets('always shows the clear button on an empty field', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(
          clearButtonMode: CommonSearchFieldClearButtonMode.always,
        ),
      );
      expect(_clearButton, findsOneWidget);
    });

    testWidgets('whenFocusedAndNotEmpty follows focus', (
      WidgetTester tester,
    ) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        CommonSearchField(
          focusNode: node,
          initialValue: 'x',
          clearButtonMode:
              CommonSearchFieldClearButtonMode.whenFocusedAndNotEmpty,
        ),
      );
      expect(_clearButton, findsNothing);
      node.requestFocus();
      await tester.pump();
      expect(_clearButton, findsOneWidget);
    });

    testWidgets('clearButtonBuilder replaces the default button', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        CommonSearchField(
          initialValue: 'x',
          clearButtonBuilder: (BuildContext context, VoidCallback onClear) {
            return TextButton(onPressed: onClear, child: const Text('Reset'));
          },
        ),
      );
      expect(_clearButton, findsNothing);
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('x'), findsNothing);
    });
  });

  group('CommonSearchField controller ownership', () {
    testWidgets('uses an external controller without disposing it', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController(
        text: 'start',
      );
      addTearDown(controller.dispose);
      await _pump(tester, CommonSearchField(controller: controller));
      expect(find.text('start'), findsOneWidget);
      controller.text = 'changed';
      await tester.pump();
      expect(_clearButton, findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      // Still usable after the field is gone.
      controller.text = 'after';
      expect(controller.text, 'after');
    });

    testWidgets('switches between controllers', (WidgetTester tester) async {
      final TextEditingController first = TextEditingController(text: 'one');
      final TextEditingController second = TextEditingController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await _pump(tester, CommonSearchField(controller: first));
      expect(_clearButton, findsOneWidget);
      await _pump(tester, CommonSearchField(controller: second));
      expect(_clearButton, findsNothing);
      second.text = 'two';
      await tester.pump();
      expect(_clearButton, findsOneWidget);
      await _pump(tester, const CommonSearchField());
      expect(find.byType(CommonSearchField), findsOneWidget);
    });
  });

  group('CommonSearchField styling', () {
    testWidgets('filled is the default variant', (WidgetTester tester) async {
      await _pump(tester, const CommonSearchField());
      final InputDecoration decoration = _decoration(tester);
      final BuildContext context = tester.element(find.byType(TextField));
      expect(decoration.filled, isTrue);
      expect(
        decoration.fillColor,
        isA<WidgetStateColor>().having(
          (WidgetStateColor color) => color.resolve(<WidgetState>{}),
          'resolved',
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
      final OutlineInputBorder border =
          decoration.enabledBorder! as OutlineInputBorder;
      expect(border.borderSide, BorderSide.none);
      expect(border.borderRadius, const BorderRadius.all(Radius.circular(28)));
    });

    testWidgets('outlined and underlined variants', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(variant: CommonSearchFieldVariant.outlined),
      );
      final OutlineInputBorder outline =
          _decoration(tester).enabledBorder! as OutlineInputBorder;
      expect(outline.borderSide.width, 1);
      expect(_decoration(tester).filled, isFalse);

      await _pump(
        tester,
        const CommonSearchField(variant: CommonSearchFieldVariant.underlined),
      );
      expect(_decoration(tester).enabledBorder, isA<UnderlineInputBorder>());
    });

    testWidgets('plain has no fill and no border', (WidgetTester tester) async {
      await _pump(
        tester,
        const CommonSearchField(variant: CommonSearchFieldVariant.plain),
      );
      final InputDecoration decoration = _decoration(tester);
      expect(decoration.filled, isFalse);
      expect(decoration.enabledBorder!.borderSide, BorderSide.none);
      expect(decoration.focusedBorder!.borderSide, BorderSide.none);
    });

    testWidgets('applies every border state from the style', (
      WidgetTester tester,
    ) async {
      const Color normal = Color(0xFF111111);
      const Color focused = Color(0xFF222222);
      const Color disabled = Color(0xFF333333);
      const CommonSearchFieldStyle style = CommonSearchFieldStyle(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderWidth: 1.5,
        focusedBorderWidth: 3,
        borderColor: normal,
        focusedBorderColor: focused,
        disabledBorderColor: disabled,
      );
      await _pump(tester, const CommonSearchField(style: style));
      final InputDecoration decoration = _decoration(tester);
      final OutlineInputBorder enabled =
          decoration.enabledBorder! as OutlineInputBorder;
      final OutlineInputBorder focus =
          decoration.focusedBorder! as OutlineInputBorder;
      final OutlineInputBorder off =
          decoration.disabledBorder! as OutlineInputBorder;
      expect(enabled.borderSide, const BorderSide(color: normal, width: 1.5));
      expect(focus.borderSide, const BorderSide(color: focused, width: 3));
      expect(off.borderSide, const BorderSide(color: disabled, width: 1.5));
      expect(enabled.borderRadius, const BorderRadius.all(Radius.circular(6)));
    });

    testWidgets('uses the hover border color under a mouse', (
      WidgetTester tester,
    ) async {
      const Color hover = Color(0xFF00AA00);
      await _pump(
        tester,
        const CommonSearchField(
          variant: CommonSearchFieldVariant.outlined,
          style: CommonSearchFieldStyle(hoverBorderColor: hover),
        ),
      );
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(
        location: tester.getCenter(find.byType(TextField)),
      );
      await tester.pump();
      expect(_decoration(tester).enabledBorder!.borderSide.color, hover);
      await gesture.removePointer();
    });

    testWidgets('elliptical corners are made circular', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(
          style: CommonSearchFieldStyle(
            borderRadius: BorderRadius.all(Radius.elliptical(20, 8)),
          ),
        ),
      );
      final OutlineInputBorder border =
          _decoration(tester).enabledBorder! as OutlineInputBorder;
      expect(border.borderRadius, const BorderRadius.all(Radius.circular(8)));
    });

    testWidgets('applies text, hint, cursor and font', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(
          style: CommonSearchFieldStyle(
            textStyle: TextStyle(fontSize: 21, color: Color(0xFF123456)),
            hintStyle: TextStyle(fontStyle: FontStyle.italic),
            font: StudioFont.roboto,
            cursorColor: Color(0xFFFF0000),
            cursorWidth: 3,
            cursorRadius: Radius.circular(2),
          ),
        ),
      );
      final TextField field = _textField(tester);
      expect(field.style!.fontSize, 21);
      expect(field.style!.color, const Color(0xFF123456));
      expect(field.style!.fontFamily, 'packages/scaffold_studio/Roboto');
      expect(field.decoration!.hintStyle!.fontStyle, FontStyle.italic);
      expect(
        field.decoration!.hintStyle!.fontFamily,
        'packages/scaffold_studio/Roboto',
      );
      expect(field.cursorColor, const Color(0xFFFF0000));
      expect(field.cursorWidth, 3);
      expect(field.cursorRadius, const Radius.circular(2));
    });

    testWidgets('applies background colors per state', (
      WidgetTester tester,
    ) async {
      const Color normal = Color(0xFFEEEEEE);
      const Color hover = Color(0xFFDDDDDD);
      const Color focused = Color(0xFFFFFFFF);
      const Color disabled = Color(0xFFCCCCCC);
      await _pump(
        tester,
        const CommonSearchField(
          style: CommonSearchFieldStyle(
            backgroundColor: normal,
            hoverBackgroundColor: hover,
            focusedBackgroundColor: focused,
            disabledBackgroundColor: disabled,
          ),
        ),
      );
      final InputDecoration decoration = _decoration(tester);
      final WidgetStateColor fill = decoration.fillColor! as WidgetStateColor;
      expect(fill.resolve(<WidgetState>{}), normal);
      expect(fill.resolve(<WidgetState>{WidgetState.hovered}), hover);
      expect(fill.resolve(<WidgetState>{WidgetState.focused}), focused);
      expect(fill.resolve(<WidgetState>{WidgetState.disabled}), disabled);
      expect(decoration.hoverColor, Colors.transparent);
    });

    testWidgets('applies icon customizations', (WidgetTester tester) async {
      await _pump(
        tester,
        const CommonSearchField(
          initialValue: 'x',
          style: CommonSearchFieldStyle(
            prefixIcon: Icons.travel_explore,
            prefixIconColor: Color(0xFF0000FF),
            prefixIconSize: 30,
            clearIcon: Icons.backspace,
            clearIconColor: Color(0xFF00FF00),
            clearIconSize: 16,
          ),
        ),
      );
      final Finder prefixFinder = find.byIcon(Icons.travel_explore);
      final Icon prefix = tester.widget<Icon>(prefixFinder);
      expect(prefix.color, const Color(0xFF0000FF));
      expect(prefix.size, 30);
      final IconButton clear = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.backspace),
      );
      expect(clear.color, const Color(0xFF00FF00));
      expect(clear.iconSize, 16);
    });

    testWidgets('selection colors come from the style', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(
          style: CommonSearchFieldStyle(selectionColor: Color(0x5500FF00)),
        ),
      );
      final BuildContext context = tester.element(find.byType(TextField));
      expect(
        TextSelectionTheme.of(context).selectionColor,
        const Color(0x5500FF00),
      );
    });

    testWidgets('draws shadows that change on focus', (
      WidgetTester tester,
    ) async {
      const BoxShadow rest = BoxShadow(blurRadius: 4);
      const BoxShadow active = BoxShadow(blurRadius: 12);
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        CommonSearchField(
          focusNode: node,
          style: const CommonSearchFieldStyle(
            shadows: <BoxShadow>[rest],
            focusedShadows: <BoxShadow>[active],
          ),
        ),
      );
      BoxDecoration decoration() {
        final AnimatedContainer container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        return container.decoration! as BoxDecoration;
      }

      expect(decoration().boxShadow, <BoxShadow>[rest]);
      node.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(decoration().boxShadow, <BoxShadow>[active]);
    });

    testWidgets('height sets the minimum height', (WidgetTester tester) async {
      await _pump(
        tester,
        const CommonSearchField(style: CommonSearchFieldStyle(height: 60)),
      );
      expect(tester.getSize(find.byType(TextField)).height, 60);
    });

    testWidgets('width and maxWidth limit the field', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const CommonSearchField(style: CommonSearchFieldStyle(width: 250)),
      );
      expect(tester.getSize(find.byType(TextField)).width, 250);

      await _pump(
        tester,
        const CommonSearchField(style: CommonSearchFieldStyle(maxWidth: 300)),
      );
      expect(tester.getSize(find.byType(TextField)).width, 300);
    });

    testWidgets('does not fail in a Row with unbounded width', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: <Widget>[CommonSearchField()]),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(TextField)).width, 360);
    });

    testWidgets('grows with large text instead of clipping', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const CommonSearchField(), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(TextField)).height, greaterThan(48));
    });

    testWidgets('renders in the dark theme', (WidgetTester tester) async {
      await _pump(
        tester,
        const CommonSearchField(initialValue: 'night'),
        theme: StudioTheme.dark,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('night'), findsOneWidget);
    });

    testWidgets('an app InputDecorationTheme does not leak in', (
      WidgetTester tester,
    ) async {
      await _pumpWithTheme(
        tester,
        const CommonSearchField(),
        ThemeData(
          inputDecorationTheme: const InputDecorationThemeData(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF0000), width: 5),
            ),
          ),
        ),
      );
      expect(_decoration(tester).enabledBorder!.borderSide, BorderSide.none);
    });

    testWidgets('decorationBuilder can adjust the decoration', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        CommonSearchField(
          decorationBuilder: (BuildContext context, InputDecoration base) {
            return base.copyWith(helperText: 'Try "shoes"');
          },
        ),
      );
      expect(find.text('Try "shoes"'), findsOneWidget);
    });
  });

  group('CommonSearchField theme', () {
    testWidgets('reads defaults from the theme extension', (
      WidgetTester tester,
    ) async {
      await _pumpWithTheme(
        tester,
        const CommonSearchField(),
        ThemeData(
          extensions: const <ThemeExtension<dynamic>>[
            CommonSearchFieldStyle(
              variant: CommonSearchFieldVariant.outlined,
              borderColor: Color(0xFF445566),
            ),
          ],
        ),
      );
      final OutlineInputBorder border =
          _decoration(tester).enabledBorder! as OutlineInputBorder;
      expect(border.borderSide.color, const Color(0xFF445566));
      expect(border.borderRadius, const BorderRadius.all(Radius.circular(12)));
    });

    testWidgets('widget values win over the theme', (
      WidgetTester tester,
    ) async {
      await _pumpWithTheme(
        tester,
        const CommonSearchField(
          variant: CommonSearchFieldVariant.underlined,
          style: CommonSearchFieldStyle(borderColor: Color(0xFF000001)),
        ),
        ThemeData(
          extensions: const <ThemeExtension<dynamic>>[
            CommonSearchFieldStyle(
              variant: CommonSearchFieldVariant.outlined,
              borderColor: Color(0xFF445566),
            ),
          ],
        ),
      );
      final InputBorder border = _decoration(tester).enabledBorder!;
      expect(border, isA<UnderlineInputBorder>());
      expect(border.borderSide.color, const Color(0xFF000001));
    });
  });

  group('CommonSearchFieldStyle', () {
    const CommonSearchFieldStyle a = CommonSearchFieldStyle(
      height: 40,
      borderColor: Color(0xFF000000),
      textStyle: TextStyle(fontSize: 14),
    );
    const CommonSearchFieldStyle b = CommonSearchFieldStyle(
      height: 60,
      backgroundColor: Color(0xFFFFFFFF),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    );

    test('merge prefers the other style and merges text styles', () {
      final CommonSearchFieldStyle merged = a.merge(b);
      expect(merged.height, 60);
      expect(merged.borderColor, const Color(0xFF000000));
      expect(merged.backgroundColor, const Color(0xFFFFFFFF));
      expect(merged.textStyle!.fontSize, 14);
      expect(merged.textStyle!.fontWeight, FontWeight.bold);
      expect(a.merge(null), same(a));
    });

    test('copyWith replaces only the given values', () {
      final CommonSearchFieldStyle copy = a.copyWith(height: 44);
      expect(copy.height, 44);
      expect(copy.borderColor, a.borderColor);
      expect(copy.textStyle, a.textStyle);
    });

    test('lerp interpolates numbers and switches enums at the midpoint', () {
      const CommonSearchFieldStyle from = CommonSearchFieldStyle(
        height: 40,
        variant: CommonSearchFieldVariant.filled,
      );
      const CommonSearchFieldStyle to = CommonSearchFieldStyle(
        height: 60,
        variant: CommonSearchFieldVariant.outlined,
      );
      expect(from.lerp(to, 0.25).height, 45);
      expect(from.lerp(to, 0.25).variant, CommonSearchFieldVariant.filled);
      expect(from.lerp(to, 0.75).variant, CommonSearchFieldVariant.outlined);
      expect(from.lerp(null, 0.5), same(from));
    });

    test('equality and hashCode are value based', () {
      const CommonSearchFieldStyle copy = CommonSearchFieldStyle(
        height: 40,
        borderColor: Color(0xFF000000),
        textStyle: TextStyle(fontSize: 14),
      );
      expect(copy, a);
      expect(copy.hashCode, a.hashCode);
      expect(a == b, isFalse);
    });

    test('defaultStyle sets every core value for every variant', () {
      final ThemeData theme = ThemeData();
      for (final CommonSearchFieldVariant variant
          in CommonSearchFieldVariant.values) {
        final CommonSearchFieldStyle style = CommonSearchField.defaultStyle(
          theme,
          variant,
        );
        expect(style.variant, variant);
        expect(style.height, 48);
        expect(style.textStyle, isNotNull);
        expect(style.hintStyle, isNotNull);
        expect(style.borderRadius, isNotNull);
        expect(style.borderWidth, isNotNull);
        expect(style.contentPadding, isNotNull);
        expect(style.prefixIcon, Icons.search);
      }
    });
  });
}
