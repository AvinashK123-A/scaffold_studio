// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import '../widgets/showcase_widgets.dart';
import 'navigation_demos.dart';

/// Configures a live [StudioBottomBar] preview and launches full-screen
/// navigation demos.
class NavigationPage extends StatefulWidget {
  /// Creates the page.
  const NavigationPage({super.key});

  /// The destination counts offered. Seven does not fit a phone-sized bar,
  /// which shows the "More" overflow.
  static const List<int> counts = <int>[2, 3, 4, 5, 7];

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // The preview bar is controller-managed: the bar updates the controller on
  // tap and listens to it. It is created here, so it is disposed here.
  final StudioNavigationController _previewController =
      StudioNavigationController();

  StudioBottomBarStyle _style = StudioBottomBarStyle.material;
  StudioNavLabelBehavior? _labels;
  int _count = 5;

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  void _setCount(int count) {
    setState(() => _count = count);
    if (_previewController.index >= count) {
      _previewController.select(0);
    }
  }

  void _open(Widget page) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (BuildContext context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final List<StudioNavItem> items = demoNavItemsFor(_count);
    return ShowcasePage(
      children: <Widget>[
        const ObserveNote(
          'The preview below is a real StudioBottomBar driven by a '
          'StudioNavigationController. With 7 destinations the trailing ones '
          'move into "More", which opens a sheet. Badges: Inbox (4), '
          'Chat (99+) and Alerts (dot).',
        ),
        ShowcaseSection(
          title: 'Bottom bar style',
          child: _ChoiceWrap<StudioBottomBarStyle>(
            values: StudioBottomBarStyle.values,
            selected: _style,
            label: bottomBarStyleName,
            onSelected: (StudioBottomBarStyle style) =>
                setState(() => _style = style),
          ),
        ),
        ShowcaseSection(
          title: 'Destinations',
          child: _ChoiceWrap<int>(
            values: NavigationPage.counts,
            selected: _count,
            label: (int count) => '$count',
            onSelected: _setCount,
          ),
        ),
        ShowcaseSection(
          title: 'Labels',
          child: _ChoiceWrap<StudioNavLabelBehavior?>(
            values: const <StudioNavLabelBehavior?>[
              null,
              ...StudioNavLabelBehavior.values,
            ],
            selected: _labels,
            label: labelBehaviorName,
            onSelected: (StudioNavLabelBehavior? labels) =>
                setState(() => _labels = labels),
          ),
        ),
        ShowcaseSection(
          title: 'Live preview',
          description: 'Limited to 420 pixels wide, like a phone.',
          child: _BottomBarPreview(
            items: items,
            controller: _previewController,
            style: _style,
            labelBehavior: _labels,
          ),
        ),
        ShowcaseSection(
          title: 'Full-screen demos',
          description:
              'Each opens a ScaffoldStudio with fixed navigation, using the '
              'destination count above. The bottom bar demo also uses the '
              'chosen style and labels.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              CommonButton(
                label: 'Bottom bar',
                icon: Icons.call_to_action_outlined,
                onPressed: () => _open(
                  FixedNavigationDemo(
                    mode: StudioNavigationMode.bottomBar,
                    bottomBarStyle: _style,
                    labelBehavior: _labels,
                    itemCount: _count,
                  ),
                ),
              ),
              CommonButton(
                label: 'Rail',
                icon: Icons.view_sidebar_outlined,
                variant: CommonButtonVariant.tonal,
                onPressed: () => _open(
                  FixedNavigationDemo(
                    mode: StudioNavigationMode.rail,
                    itemCount: _count,
                  ),
                ),
              ),
              CommonButton(
                label: 'Sidebar',
                icon: Icons.vertical_split_outlined,
                variant: CommonButtonVariant.tonal,
                onPressed: () => _open(
                  FixedNavigationDemo(
                    mode: StudioNavigationMode.sidebar,
                    itemCount: _count,
                  ),
                ),
              ),
              CommonButton(
                label: 'Drawer',
                icon: Icons.menu,
                variant: CommonButtonVariant.tonal,
                onPressed: () => _open(
                  FixedNavigationDemo(
                    mode: StudioNavigationMode.drawer,
                    itemCount: _count,
                  ),
                ),
              ),
              CommonButton(
                label: 'Controller + bodyBuilder',
                icon: Icons.settings_remote_outlined,
                variant: CommonButtonVariant.outlined,
                onPressed: () => _open(const ControllerNavigationDemo()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A wrapping group of choice chips.
class _ChoiceWrap<T> extends StatelessWidget {
  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final T value in values)
          ChoiceChip(
            label: Text(label(value)),
            selected: value == selected,
            onSelected: (bool _) => onSelected(value),
          ),
      ],
    );
  }
}

/// A phone-sized frame with a nested [Scaffold] that hosts the preview bar,
/// so that the notched style has a real docked floating action button.
class _BottomBarPreview extends StatelessWidget {
  const _BottomBarPreview({
    required this.items,
    required this.controller,
    required this.style,
    required this.labelBehavior,
  });

  final List<StudioNavItem> items;
  final StudioNavigationController controller;
  final StudioBottomBarStyle style;
  final StudioNavLabelBehavior? labelBehavior;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool notched = style == StudioBottomBarStyle.notched;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 280,
              // The preview is not at the screen edge, so system insets do
              // not apply to it.
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: Scaffold(
                  backgroundColor: scheme.surfaceContainerLowest,
                  extendBody: style == StudioBottomBarStyle.floating,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ValueListenableBuilder<int>(
                        valueListenable: controller,
                        builder:
                            (BuildContext context, int index, Widget? child) =>
                                CommonBodyText(
                                  index >= 0 && index < items.length
                                      ? 'Selected: ${items[index].label}'
                                      : 'Nothing selected',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                      ),
                    ),
                  ),
                  bottomNavigationBar: StudioBottomBar(
                    key: const ValueKey<String>('preview-bottom-bar'),
                    items: items,
                    controller: controller,
                    style: style,
                    labelBehavior: labelBehavior,
                  ),
                  floatingActionButton: notched
                      ? FloatingActionButton(
                          // A nested scaffold: no hero animation for this one.
                          heroTag: null,
                          tooltip: 'Add',
                          onPressed: () => showDemoSnackBar(context, 'Add'),
                          child: const Icon(Icons.add),
                        )
                      : null,
                  floatingActionButtonLocation: notched
                      ? FloatingActionButtonLocation.centerDocked
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
