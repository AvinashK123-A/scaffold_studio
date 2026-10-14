// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// Preset visual styles for `StudioBottomBar`.
///
/// Badges, custom backgrounds (color, gradient, elevation, radius), custom
/// indicators and per-item builders are options available on every style,
/// not separate styles.
enum StudioBottomBarStyle {
  /// The Material 3 navigation bar: a tonal surface with a pill indicator
  /// behind the selected icon and labels below the icons.
  material,

  /// A floating, fully rounded pill inset from the screen edges.
  ///
  /// `ScaffoldStudio` extends the body behind it so content scrolls under
  /// the gap around the pill.
  floating,

  /// A bar with rounded top corners and a soft shadow.
  rounded,

  /// Icons only, without an indicator; the selected item is marked by its
  /// color and a small dot.
  minimal,

  /// The classic layout: icons with labels and a color change on
  /// selection, without an indicator.
  labeled,

  /// The selected item expands into a pill that reveals its label; the other
  /// items show icons only.
  animated,

  /// A bar with a centered notch for a docked floating action button. Items
  /// are split evenly around the notch.
  notched,
}

/// When `StudioBottomBar` shows item labels.
enum StudioNavLabelBehavior {
  /// Every item shows its label.
  alwaysShow,

  /// Only the selected item shows its label.
  onlySelected,

  /// No labels are shown. Labels remain available as tooltips and to screen
  /// readers.
  never,
}
