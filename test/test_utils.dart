// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

/// Representative logical widths from the test matrix.
const List<double> kMatrixWidths = <double>[
  320,
  360,
  390,
  430,
  600,
  768,
  840,
  1024,
  1280,
  1440,
];

/// Sets the test window to [size] logical pixels and restores it afterwards.
void setWindowSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

/// A portrait or landscape size for [width] that keeps a phone-like aspect
/// ratio on narrow widths and a desktop-like one on wide widths.
Size sizeFor(double width, {bool landscape = false}) {
  if (landscape) {
    return Size(width, width < 600 ? width * 0.5 : width * 0.62);
  }
  return Size(width, width < 600 ? width * 2.1 : width * 1.3);
}

/// Pumps [child] inside a themed [MaterialApp].
///
/// [textScale] wraps the app in a [MediaQuery] with a linear text scaler.
Future<void> pumpStudio(
  WidgetTester tester,
  Widget child, {
  StudioTheme theme = StudioTheme.light,
  StudioFont font = StudioFont.system,
  StudioTypography typography = const StudioTypography(),
  double textScale = 1,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme.toThemeData(font: font, typography: typography),
      builder: (BuildContext context, Widget? app) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: app!,
        );
      },
      home: child,
    ),
  );
}

/// Destinations used across navigation tests.
List<StudioNavItem> navItems(int count) {
  const List<IconData> icons = <IconData>[
    Icons.home_outlined,
    Icons.search,
    Icons.favorite_border,
    Icons.mail_outline,
    Icons.person_outline,
    Icons.settings_outlined,
    Icons.help_outline,
    Icons.info_outline,
  ];
  return <StudioNavItem>[
    for (int i = 0; i < count; i++)
      StudioNavItem(icon: icons[i % icons.length], label: 'Item $i'),
  ];
}
