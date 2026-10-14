// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import 'home_page.dart';
import 'settings.dart';

/// The root of the showcase.
///
/// A small [StatefulWidget] owns the app-level settings (theme mode, font,
/// seed color and a text scale override) and rebuilds [ScaffoldStudioApp]
/// when they change. [ShowcaseScope] hands the settings to every route.
class ShowcaseApp extends StatefulWidget {
  /// Creates the showcase app.
  const ShowcaseApp({
    super.key,
    this.initialSettings = const ShowcaseSettings(),
  });

  /// The settings the app starts with.
  final ShowcaseSettings initialSettings;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late ShowcaseSettings _settings = widget.initialSettings;

  void _update(ShowcaseSettings settings) {
    if (settings != _settings) {
      setState(() => _settings = settings);
    }
  }

  /// Applies the text scale override on top of the platform setting, so the
  /// whole app (including pushed routes and dialogs) can be checked at large
  /// accessibility text sizes.
  Widget _applyTextScale(BuildContext context, Widget? child) {
    final Widget content = child ?? const SizedBox.shrink();
    final double? scale = _settings.textScale;
    if (scale == null) {
      return content;
    }
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ShowcaseSettings settings = _settings;
    return ShowcaseScope(
      settings: settings,
      onChanged: _update,
      child: ScaffoldStudioApp(
        title: 'Scaffold Studio',
        debugShowCheckedModeBanner: false,
        // Only the light configuration is given: because it is seed-based,
        // ScaffoldStudioApp derives the dark theme from the same seed.
        theme: StudioTheme(seedColor: settings.seedColor),
        themeMode: settings.themeMode,
        fontFamily: settings.font,
        builder: _applyTextScale,
        home: const ShowcaseHome(),
      ),
    );
  }
}
