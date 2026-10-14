// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/studio_theme_data.dart';
import 'internal/nav_utils.dart';
import 'studio_bottom_bar_style.dart';
import 'studio_nav_item.dart';
import 'studio_navigation_controller.dart';

/// Builds custom content for one bottom bar item.
///
/// The bar still provides the tap target, focus, tooltip and semantics; the
/// builder only replaces what is drawn inside the item.
typedef StudioNavItemBuilder =
    Widget Function(BuildContext context, StudioNavItem item, bool selected);

/// A responsive bottom navigation bar with several visual styles.
///
/// ```dart
/// StudioBottomBar(
///   style: StudioBottomBarStyle.floating,
///   items: const [
///     StudioNavItem(icon: Icons.home_outlined, label: 'Home'),
///     StudioNavItem(icon: Icons.search, label: 'Search'),
///     StudioNavItem(icon: Icons.person_outline, label: 'Profile'),
///   ],
///   selectedIndex: index,
///   onSelected: (i) => setState(() => index = i),
/// )
/// ```
///
/// ## State
///
/// The bar does not own the selection. Either pass [selectedIndex] and
/// rebuild in [onSelected] (controlled), or pass a [controller], which the
/// bar updates and listens to. [onSelected] is called in both cases.
///
/// ## Validation
///
/// * An empty [items] list renders nothing.
/// * A [selectedIndex] outside `0..items.length - 1` (including a negative
///   one) selects nothing. It does not throw, because a stale index is a
///   normal situation while item lists change.
/// * Disabled items ignore taps.
///
/// ## Responsive behavior
///
/// Each item needs at least [minItemWidth] logical pixels. When the bar is
/// too narrow for every item, the trailing items move into a "More" item
/// that opens a bottom sheet, rather than being squeezed below a usable
/// size. The bar grows taller with the system text scale so labels are never
/// clipped; long labels are ellipsized, and the full label remains available
/// as a tooltip and to screen readers.
///
/// On medium and expanded layouts, prefer a navigation rail or sidebar;
/// `ScaffoldStudio` switches automatically.
///
/// ## Accessibility
///
/// Items are focusable buttons that announce their label, badge, selected
/// state and position ("Tab 2 of 4"). Animations are skipped when the
/// platform requests reduced motion.
class StudioBottomBar extends StatelessWidget {
  /// Creates a bottom navigation bar.
  const StudioBottomBar({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onSelected,
    this.controller,
    this.style = StudioBottomBarStyle.material,
    this.labelBehavior,
    this.backgroundColor,
    this.gradient,
    this.elevation,
    this.shadowColor,
    this.borderRadius,
    this.margin,
    this.height,
    this.selectedColor,
    this.unselectedColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.iconSize = 24,
    this.selectedIconSize,
    this.showIndicator,
    this.indicatorColor,
    this.indicatorShape,
    this.itemSpacing = 0,
    this.itemBuilder,
    this.animationDuration,
    this.animationCurve,
    this.minItemWidth = 64,
    this.moreLabel = 'More',
    this.moreIcon = Icons.more_horiz,
    this.notchGap = 72,
  }) : assert(
         selectedIndex == null || controller == null,
         'Pass either selectedIndex or controller, not both.',
       ),
       assert(iconSize > 0, 'iconSize must be positive.'),
       assert(minItemWidth > 0, 'minItemWidth must be positive.'),
       assert(itemSpacing >= 0, 'itemSpacing must not be negative.');

  /// The destinations.
  final List<StudioNavItem> items;

  /// The selected index, when the bar is controlled by its parent.
  final int? selectedIndex;

  /// Called with the index of the item the user selects.
  final ValueChanged<int>? onSelected;

  /// A controller that owns the selection. See [StudioNavigationController].
  final StudioNavigationController? controller;

  /// The visual style.
  final StudioBottomBarStyle style;

  /// When labels are shown. Defaults to the style: labels always for
  /// [StudioBottomBarStyle.material], [StudioBottomBarStyle.rounded],
  /// [StudioBottomBarStyle.labeled] and [StudioBottomBarStyle.notched];
  /// only for the selected item for [StudioBottomBarStyle.floating] and
  /// [StudioBottomBarStyle.animated]; never for
  /// [StudioBottomBarStyle.minimal].
  final StudioNavLabelBehavior? labelBehavior;

  /// The bar color. Defaults to the [NavigationBarThemeData] background or a
  /// surface container color.
  final Color? backgroundColor;

  /// A background gradient that replaces [backgroundColor].
  final Gradient? gradient;

  /// The elevation.
  final double? elevation;

  /// The shadow color.
  final Color? shadowColor;

  /// The corner radius. Defaults to the style.
  final BorderRadius? borderRadius;

  /// Space around the bar. Defaults to the style; only
  /// [StudioBottomBarStyle.floating] is inset by default. Safe-area insets
  /// are added automatically.
  final EdgeInsets? margin;

  /// The minimum bar height, excluding safe-area insets. Defaults to the
  /// style. The bar grows beyond it when text scaling requires.
  final double? height;

  /// The color of the selected icon and label.
  final Color? selectedColor;

  /// The color of unselected icons and labels.
  final Color? unselectedColor;

  /// The selected label style.
  final TextStyle? selectedLabelStyle;

  /// The unselected label style.
  final TextStyle? unselectedLabelStyle;

  /// The icon size.
  final double iconSize;

  /// The selected icon size. Defaults to [iconSize].
  final double? selectedIconSize;

  /// Whether to draw a selection indicator. Defaults to the style.
  final bool? showIndicator;

  /// The indicator color. Defaults to the [NavigationBarThemeData] indicator
  /// color or [ColorScheme.secondaryContainer].
  final Color? indicatorColor;

  /// The indicator shape. Defaults to a stadium.
  final ShapeBorder? indicatorShape;

  /// Horizontal space between items.
  final double itemSpacing;

  /// Replaces the content of each item. See [StudioNavItemBuilder].
  final StudioNavItemBuilder? itemBuilder;

  /// The duration of selection animations. Defaults to
  /// [StudioThemeData.navigationAnimationDuration].
  final Duration? animationDuration;

  /// The curve of selection animations. Defaults to
  /// [StudioThemeData.navigationAnimationCurve].
  final Curve? animationCurve;

  /// The narrowest an item may be before items overflow into "More".
  /// Values below 48 are raised to 48, the minimum touch target.
  final double minItemWidth;

  /// The label of the overflow item. Override it to localize.
  final String moreLabel;

  /// The icon of the overflow item.
  final IconData moreIcon;

  /// The width of the gap left for the floating action button by
  /// [StudioBottomBarStyle.notched].
  final double notchGap;

  /// Whether [style] reserves a gap for a docked floating action button.
  ///
  /// The notch itself is cut only when the bar is inside a [Scaffold].
  bool get hasNotch => style == StudioBottomBarStyle.notched;

  /// Whether [style] floats above the content, so the body should extend
  /// behind it.
  bool get isFloating => style == StudioBottomBarStyle.floating;

  @override
  Widget build(BuildContext context) {
    final StudioNavigationController? controller = this.controller;
    if (controller == null) {
      return _buildBar(context, selectedIndex);
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) =>
          _buildBar(context, controller.value),
    );
  }

  void _select(int index) {
    if (!items[index].enabled) {
      return;
    }
    controller?.select(index);
    onSelected?.call(index);
  }

  Widget _buildBar(BuildContext context, int? rawIndex) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final int? selected = validIndex(rawIndex, items.length);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final NavigationBarThemeData navTheme = NavigationBarTheme.of(context);
    final StudioThemeData tokens = StudioThemeData.of(context);
    final _BarSpec spec = _BarSpec.resolve(style, scheme, navTheme);

    final bool indicator = showIndicator ?? spec.indicator;
    final StudioNavLabelBehavior labels = labelBehavior ?? spec.labels;
    final Color selectedFg =
        selectedColor ??
        (indicator ? scheme.onSecondaryContainer : scheme.primary);
    final Color unselectedFg = unselectedColor ?? scheme.onSurfaceVariant;
    final TextStyle baseLabel =
        theme.textTheme.labelMedium ?? const TextStyle(fontSize: 12);
    final TextStyle selectedLabel = baseLabel
        .copyWith(
          color:
              selectedColor ?? (indicator ? scheme.onSurface : scheme.primary),
          fontWeight: FontWeight.w600,
        )
        .merge(selectedLabelStyle);
    final TextStyle unselectedLabel = baseLabel
        .copyWith(color: unselectedFg)
        .merge(unselectedLabelStyle);

    final Duration duration = effectiveDuration(
      context,
      animationDuration ?? tokens.navigationAnimationDuration,
    );
    final Curve curve = animationCurve ?? tokens.navigationAnimationCurve;

    // Grow with text scaling so that labels always fit vertically.
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final double labelFontSize = math.max(
      selectedLabel.fontSize ?? 12,
      unselectedLabel.fontSize ?? 12,
    );
    final double labelLine =
        textScaler.scale(labelFontSize) * (selectedLabel.height ?? 1.34);
    final double iconBox = math.max(
      32,
      math.max(iconSize, selectedIconSize ?? iconSize) + 8,
    );
    final bool anyLabels = labels != StudioNavLabelBehavior.never;
    final bool labelsBelow =
        anyLabels && style != StudioBottomBarStyle.animated;
    // The animated style shows its label beside the icon, inside a pill
    // with 8 pixels of vertical padding.
    final double pillHeight =
        anyLabels && style == StudioBottomBarStyle.animated
        ? 16 + 16 + labelLine
        : 0;
    final double contentHeight = math.max(
      16 + iconBox + (labelsBelow ? 4 + labelLine : 0),
      pillHeight,
    );
    final double barHeight = math.max(
      height ?? spec.height,
      math.max(contentHeight, kMinInteractiveDimension),
    );

    final _ItemVisuals visuals = _ItemVisuals(
      style: style,
      indicator: indicator,
      labels: labels,
      selectedColor: selectedFg,
      unselectedColor: unselectedFg,
      selectedLabelStyle: selectedLabel,
      unselectedLabelStyle: unselectedLabel,
      iconSize: iconSize,
      selectedIconSize: selectedIconSize ?? iconSize,
      indicatorColor:
          indicatorColor ??
          navTheme.indicatorColor ??
          scheme.secondaryContainer,
      indicatorShape: indicatorShape ?? const StadiumBorder(),
      duration: duration,
      curve: curve,
      itemBuilder: itemBuilder,
      height: barHeight,
    );

    final Widget row = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _buildItems(
          context,
          width: constraints.maxWidth,
          selected: selected,
          visuals: visuals,
        );
      },
    );

    final Color background = gradient != null
        ? Colors.transparent
        : backgroundColor ?? spec.background;
    final double effectiveElevation = elevation ?? spec.elevation;
    final BorderRadius radius = borderRadius ?? spec.radius;

    // BottomAppBar needs a Scaffold to find the floating action button it
    // notches around. Outside a Scaffold, render the bar without a notch.
    if (hasNotch && Scaffold.maybeOf(context) != null) {
      return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: background,
        elevation: effectiveElevation,
        shadowColor: shadowColor,
        surfaceTintColor: Colors.transparent,
        height: barHeight,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: _decorate(row),
      );
    }

    final EdgeInsets outer = margin ?? spec.margin;
    final Widget material = Material(
      color: background,
      elevation: effectiveElevation,
      shadowColor: shadowColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: _decorate(
        isFloating
            ? SizedBox(height: barHeight, child: row)
            : SafeArea(
                top: false,
                child: SizedBox(height: barHeight, child: row),
              ),
      ),
    );

    if (isFloating || outer != EdgeInsets.zero) {
      // Inset bars keep clear of the system gesture area and cutouts on
      // their own, since they do not extend to the screen edge.
      return SafeArea(top: false, minimum: outer, child: material);
    }
    return material;
  }

  Widget _decorate(Widget child) {
    final Gradient? gradient = this.gradient;
    if (gradient == null) {
      return child;
    }
    // Ink paints on the bar's Material, so item ripples stay visible above
    // the gradient.
    return Ink(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }

  Widget _buildItems(
    BuildContext context, {
    required double width,
    required int? selected,
    required _ItemVisuals visuals,
  }) {
    final double gap = hasNotch ? math.max(0, notchGap) : 0;
    final double usable = math.max(0, (width.isFinite ? width : 0) - gap);
    final double minWidth = math.max(kMinInteractiveDimension, minItemWidth);
    final int capacity = math.max(1, (usable / minWidth).floor());

    // Which items are shown directly, and which go to "More".
    final int visibleCount = items.length <= capacity
        ? items.length
        : math.max(1, capacity - 1);
    final bool hasMore = visibleCount < items.length;
    final int slotCount = visibleCount + (hasMore ? 1 : 0);
    final bool moreSelected =
        hasMore && selected != null && selected >= visibleCount;

    // The animated style gives the selected item extra room for its label.
    final List<double> widths = List<double>.filled(
      slotCount,
      usable / slotCount,
    );
    if (style == StudioBottomBarStyle.animated && slotCount > 1) {
      final int selectedSlot = moreSelected
          ? slotCount - 1
          : (selected != null && selected < visibleCount ? selected : -1);
      if (selectedSlot >= 0) {
        final double share = usable / slotCount;
        final double wide = math.min(
          share * 1.8,
          usable - (slotCount - 1) * math.min(share, minWidth),
        );
        if (wide > share) {
          final double narrow = (usable - wide) / (slotCount - 1);
          for (int i = 0; i < slotCount; i++) {
            widths[i] = i == selectedSlot ? wide : narrow;
          }
        }
      }
    }

    // Item widths only animate between selections at a fixed bar width and
    // item count, where the widths always sum to the bar width. A resize or
    // a change in item count produces new keys, so items are rebuilt at their
    // final width instead of animating through sizes that overflow the row.
    final String layoutKey = '$slotCount/${usable.round()}';
    final MaterialLocalizations? localizations =
        Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
    final List<Widget> slots = <Widget>[];
    for (int slot = 0; slot < slotCount; slot++) {
      final bool isMore = hasMore && slot == slotCount - 1;
      final String? position = localizations?.tabLabel(
        tabIndex: slot + 1,
        tabCount: slotCount,
      );
      if (isMore) {
        final StudioNavItem moreItem = StudioNavItem(
          icon: moreIcon,
          label: moreLabel,
          badge: _overflowHasBadge(visibleCount) ? '' : null,
        );
        slots.add(
          _NavBarItem(
            key: ValueKey<String>('more/$layoutKey'),
            item: moreItem,
            selected: moreSelected,
            width: widths[slot],
            spacing: itemSpacing,
            visuals: visuals,
            position: position,
            onTap: () => _showMore(context, visibleCount, selected),
          ),
        );
      } else {
        final StudioNavItem item = items[slot];
        slots.add(
          _NavBarItem(
            key: ValueKey<String>('$slot/$layoutKey'),
            item: item,
            selected: selected == slot,
            width: widths[slot],
            spacing: itemSpacing,
            visuals: visuals,
            position: position,
            onTap: item.enabled ? () => _select(slot) : null,
          ),
        );
      }
    }

    if (gap > 0) {
      slots.insert(slots.length ~/ 2 + slots.length % 2, SizedBox(width: gap));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: slots);
  }

  bool _overflowHasBadge(int visibleCount) {
    for (int i = visibleCount; i < items.length; i++) {
      if (badgeSemantics(items[i]) != null ||
          (items[i].badge?.isEmpty ?? false)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _showMore(
    BuildContext context,
    int visibleCount,
    int? selected,
  ) async {
    final int? choice = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              for (int i = visibleCount; i < items.length; i++)
                ListTile(
                  leading: buildNavIcon(items[i], selected: selected == i),
                  title: Text(items[i].label),
                  selected: selected == i,
                  enabled: items[i].enabled,
                  onTap: () => Navigator.of(sheetContext).pop(i),
                ),
            ],
          ),
        );
      },
    );
    if (choice != null) {
      _select(choice);
    }
  }
}

/// Style-dependent defaults for [StudioBottomBar].
@immutable
class _BarSpec {
  const _BarSpec({
    required this.background,
    required this.elevation,
    required this.radius,
    required this.margin,
    required this.height,
    required this.indicator,
    required this.labels,
  });

  factory _BarSpec.resolve(
    StudioBottomBarStyle style,
    ColorScheme scheme,
    NavigationBarThemeData navTheme,
  ) {
    final Color surface = navTheme.backgroundColor ?? scheme.surfaceContainer;
    return switch (style) {
      StudioBottomBarStyle.material => _BarSpec(
        background: surface,
        elevation: navTheme.elevation ?? 3,
        radius: BorderRadius.zero,
        margin: EdgeInsets.zero,
        height: navTheme.height ?? 80,
        indicator: true,
        labels: StudioNavLabelBehavior.alwaysShow,
      ),
      StudioBottomBarStyle.floating => _BarSpec(
        background: scheme.surfaceContainerHigh,
        elevation: 6,
        radius: const BorderRadius.all(Radius.circular(32)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 64,
        indicator: true,
        labels: StudioNavLabelBehavior.onlySelected,
      ),
      StudioBottomBarStyle.rounded => _BarSpec(
        background: surface,
        elevation: 8,
        radius: const BorderRadius.vertical(top: Radius.circular(24)),
        margin: EdgeInsets.zero,
        height: 76,
        indicator: true,
        labels: StudioNavLabelBehavior.alwaysShow,
      ),
      StudioBottomBarStyle.minimal => _BarSpec(
        background: scheme.surface,
        elevation: 0,
        radius: BorderRadius.zero,
        margin: EdgeInsets.zero,
        height: 60,
        indicator: false,
        labels: StudioNavLabelBehavior.never,
      ),
      StudioBottomBarStyle.labeled => _BarSpec(
        background: surface,
        elevation: navTheme.elevation ?? 3,
        radius: BorderRadius.zero,
        margin: EdgeInsets.zero,
        height: 68,
        indicator: false,
        labels: StudioNavLabelBehavior.alwaysShow,
      ),
      StudioBottomBarStyle.animated => _BarSpec(
        background: surface,
        elevation: navTheme.elevation ?? 3,
        radius: BorderRadius.zero,
        margin: EdgeInsets.zero,
        height: 68,
        indicator: true,
        labels: StudioNavLabelBehavior.onlySelected,
      ),
      StudioBottomBarStyle.notched => _BarSpec(
        background: surface,
        elevation: navTheme.elevation ?? 3,
        radius: BorderRadius.zero,
        margin: EdgeInsets.zero,
        height: 80,
        indicator: true,
        labels: StudioNavLabelBehavior.alwaysShow,
      ),
    };
  }

  final Color background;
  final double elevation;
  final BorderRadius radius;
  final EdgeInsets margin;
  final double height;
  final bool indicator;
  final StudioNavLabelBehavior labels;
}

/// Resolved visual parameters shared by every item of one bar.
@immutable
class _ItemVisuals {
  const _ItemVisuals({
    required this.style,
    required this.indicator,
    required this.labels,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedLabelStyle,
    required this.unselectedLabelStyle,
    required this.iconSize,
    required this.selectedIconSize,
    required this.indicatorColor,
    required this.indicatorShape,
    required this.duration,
    required this.curve,
    required this.itemBuilder,
    required this.height,
  });

  final StudioBottomBarStyle style;
  final bool indicator;
  final StudioNavLabelBehavior labels;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle selectedLabelStyle;
  final TextStyle unselectedLabelStyle;
  final double iconSize;
  final double selectedIconSize;
  final Color indicatorColor;
  final ShapeBorder indicatorShape;
  final Duration duration;
  final Curve curve;
  final StudioNavItemBuilder? itemBuilder;
  final double height;

  bool showsLabel({required bool selected}) {
    return switch (labels) {
      StudioNavLabelBehavior.alwaysShow => true,
      StudioNavLabelBehavior.onlySelected => selected,
      StudioNavLabelBehavior.never => false,
    };
  }
}

/// One bottom bar item: tap target, semantics, tooltip and visuals.
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    super.key,
    required this.item,
    required this.selected,
    required this.width,
    required this.spacing,
    required this.visuals,
    required this.position,
    required this.onTap,
  });

  final StudioNavItem item;
  final bool selected;
  final double width;
  final double spacing;
  final _ItemVisuals visuals;
  final String? position;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = item.enabled && onTap != null;
    final bool labelVisible = visuals.showsLabel(selected: selected);
    Widget content =
        visuals.itemBuilder?.call(context, item, selected) ??
        _buildContent(context, labelVisible: labelVisible);
    if (!enabled) {
      content = Opacity(opacity: 0.38, child: content);
    }

    Widget result = InkWell(
      onTap: enabled ? onTap : null,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4 + spacing / 2),
        child: ExcludeSemantics(child: Center(child: content)),
      ),
    );

    final String? tooltip = item.tooltip ?? (labelVisible ? null : item.label);
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: result,
      );
    }

    final String label = navSemanticsLabel(item);
    result = Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: enabled,
      label: position == null ? label : '$label, $position',
      child: result,
    );

    // Only the animated style animates item widths. The height follows the
    // bar immediately, so a text scale change never leaves content taller
    // than an item mid-animation.
    if (visuals.style != StudioBottomBarStyle.animated) {
      return SizedBox(width: width, height: visuals.height, child: result);
    }
    return AnimatedContainer(
      duration: visuals.duration,
      curve: visuals.curve,
      width: width,
      child: SizedBox(height: visuals.height, child: result),
    );
  }

  Widget _buildContent(BuildContext context, {required bool labelVisible}) {
    final Color color = selected
        ? visuals.selectedColor
        : visuals.unselectedColor;
    final double size = selected ? visuals.selectedIconSize : visuals.iconSize;
    final Widget icon = IconTheme.merge(
      data: IconThemeData(color: color, size: size),
      child: buildNavIcon(item, selected: selected, size: size, color: color),
    );
    final TextStyle labelStyle = selected
        ? visuals.selectedLabelStyle
        : visuals.unselectedLabelStyle;
    Widget labelText() => Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: labelStyle,
    );

    if (visuals.style == StudioBottomBarStyle.animated) {
      return AnimatedContainer(
        duration: visuals.duration,
        curve: visuals.curve,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 8,
        ),
        decoration: ShapeDecoration(
          shape: visuals.indicatorShape,
          color: selected && visuals.indicator
              ? visuals.indicatorColor
              : visuals.indicatorColor.withValues(alpha: 0),
        ),
        child: AnimatedSize(
          duration: visuals.duration,
          curve: visuals.curve,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              if (labelVisible)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle.copyWith(color: color),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final Widget iconArea;
    if (visuals.indicator) {
      iconArea = SizedBox(
        height: math.max(32, size + 8),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: visuals.duration,
              curve: visuals.curve,
              width: selected ? math.min(64, width - 8) : 32,
              height: math.max(32, size + 8),
              decoration: ShapeDecoration(
                shape: visuals.indicatorShape,
                color: selected
                    ? visuals.indicatorColor
                    : visuals.indicatorColor.withValues(alpha: 0),
              ),
            ),
            icon,
          ],
        ),
      );
    } else if (visuals.style == StudioBottomBarStyle.minimal) {
      iconArea = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          icon,
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: visuals.duration,
            curve: visuals.curve,
            width: selected ? 6 : 0,
            height: selected ? 6 : 0,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      );
    } else {
      iconArea = icon;
    }

    // The bar height is computed to fit the label at the current text
    // scale. Flexible is a safety net for custom label styles: an oversized
    // label is clipped rather than overflowing the item.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        iconArea,
        if (labelVisible) ...<Widget>[
          const SizedBox(height: 4),
          Flexible(child: labelText()),
        ],
      ],
    );
  }
}
