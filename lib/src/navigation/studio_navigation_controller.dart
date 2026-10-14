// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// @docImport 'package:flutter/widgets.dart';
library;

import 'package:flutter/foundation.dart';

/// Holds the selected navigation index, for apps that prefer not to manage
/// it in their own state.
///
/// Navigation widgets in this package support two ownership models:
///
/// * **Controlled**: pass `selectedIndex` and `onSelected`, and rebuild with
///   the new index yourself.
/// * **Controller-managed**: pass a `StudioNavigationController`. Taps update
///   the controller, and the widgets rebuild by listening to it. Listen to
///   the controller (for example with a [ValueListenableBuilder]) to switch
///   pages.
///
/// The controller is a [ValueNotifier]; you create it, so you must dispose
/// it, typically in [State.dispose].
///
/// ```dart
/// final controller = StudioNavigationController();
///
/// ValueListenableBuilder<int>(
///   valueListenable: controller,
///   builder: (context, index, _) => pages[index],
/// )
/// ```
class StudioNavigationController extends ValueNotifier<int> {
  /// Creates a controller with an initial selection.
  ///
  /// A negative [initialIndex] means that nothing is selected.
  StudioNavigationController({int initialIndex = 0}) : super(initialIndex);

  /// The selected index.
  int get index => value;

  /// Selects [index] and notifies listeners if it changed.
  void select(int index) {
    value = index;
  }
}
