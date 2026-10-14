// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// Preset visual styles for `StudioAppBar`.
///
/// Every style is rendered by the same implementation; a style only changes
/// defaults (colors, height, shape, title alignment and slot layout). Any
/// explicit argument on `StudioAppBar` overrides the style default.
enum StudioAppBarStyle {
  /// A Material 3 small top app bar: start-aligned title on the surface
  /// color, with a tonal elevation when content scrolls underneath.
  standard,

  /// Like [standard], with a centered title.
  centered,

  /// A quiet bar with a smaller title and no scroll elevation.
  minimal,

  /// A fully transparent bar for content that extends behind it. Pair with
  /// `ScaffoldStudio.extendBodyBehindAppBar`.
  transparent,

  /// A bar filled with a gradient. Defaults to a primary-to-tertiary
  /// gradient with matching on-primary foreground colors.
  gradient,

  /// A bar with a background image under a darkening scrim for legible
  /// white foreground content. Shows a neutral dark color until
  /// `backgroundImage` is provided and while it loads.
  image,

  /// A bar with rounded bottom corners on a tonal surface.
  rounded,

  /// A bar whose title slot is a search field. Provide `search`.
  ///
  /// On medium and expanded widths, the title (if any) is shown before the
  /// field.
  search,

  /// A taller bar that leads with the `profile` avatar and shows a title
  /// with an optional subtitle, as in a greeting header. When the route can
  /// be popped or a drawer exists, the implied button keeps the leading slot
  /// and the avatar moves to the end.
  profile,

  /// A layout without fixed slot widths. The leading widget, title and
  /// actions are laid out in a single flexible row, so leading content wider
  /// than an icon (for example an avatar with a name) fits naturally.
  flexible,
}
