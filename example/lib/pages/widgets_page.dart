// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import '../widgets/showcase_widgets.dart';

/// Demonstrates the common widgets: buttons, icon buttons, badges, cards,
/// dividers, a responsive grid and keyboard focus.
class WidgetsPage extends StatefulWidget {
  /// Creates the page.
  const WidgetsPage({super.key});

  @override
  State<WidgetsPage> createState() => _WidgetsPageState();
}

class _WidgetsPageState extends State<WidgetsPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  bool _loading = false;
  bool _bookmarked = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _say(String message) => showDemoSnackBar(context, message);

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: <Widget>[
        _buttons(),
        _iconButtons(),
        _badges(),
        _cards(),
        _dividers(),
        _responsiveGrid(),
        _keyboard(),
      ],
    );
  }

  Widget _buttons() {
    return ShowcaseSection(
      title: 'CommonButton',
      description:
          'Five variants and three sizes over the Material buttons, with an '
          'optional icon, a loading state and a full-width layout.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          const CommonLabelText('Variants'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final CommonButtonVariant variant
                  in CommonButtonVariant.values)
                CommonButton(
                  label: _capitalize(variant.name),
                  variant: variant,
                  onPressed: () => _say('${variant.name} pressed'),
                ),
            ],
          ),
          const CommonLabelText('Sizes'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final CommonButtonSize size in CommonButtonSize.values)
                CommonButton(
                  label: '${_capitalize(size.name)} (${size.height.round()})',
                  size: size,
                  variant: CommonButtonVariant.tonal,
                  onPressed: () => _say('${size.name} pressed'),
                ),
            ],
          ),
          const CommonLabelText('Icons, loading and disabled'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              CommonButton(
                label: 'Save',
                icon: Icons.check,
                onPressed: () => _say('Saved'),
              ),
              CommonButton(
                label: 'Next',
                icon: Icons.arrow_forward,
                trailingIcon: true,
                variant: CommonButtonVariant.outlined,
                onPressed: () => _say('Next'),
              ),
              CommonButton(
                label: 'Upload',
                icon: Icons.upload,
                isLoading: _loading,
                tooltip: 'Disabled and announced as busy while loading',
                onPressed: () => _say('Uploading'),
              ),
              const CommonButton(label: 'Disabled', onPressed: null),
              const CommonButton(
                label: 'Disabled',
                icon: Icons.block,
                variant: CommonButtonVariant.outlined,
                onPressed: null,
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Loading'),
            subtitle: const Text('Shows a spinner on the Upload button'),
            value: _loading,
            onChanged: (bool value) => setState(() => _loading = value),
          ),
          CommonButton(
            label: 'Expanded to the full width',
            icon: Icons.open_in_full,
            expand: true,
            onPressed: () => _say('Expanded button pressed'),
          ),
          CommonButton(
            label:
                'A very long label wraps onto two lines and then ellipsizes '
                'instead of overflowing the button',
            variant: CommonButtonVariant.outlined,
            onPressed: () => _say('Long label pressed'),
          ),
        ],
      ),
    );
  }

  Widget _iconButtons() {
    return ShowcaseSection(
      title: 'CommonIconButton',
      description:
          'Every icon button needs a tooltip or a semantics label. Hover or '
          'long-press to see the tooltip.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          CommonIconButton(
            icon: Icons.favorite_border,
            tooltip: 'Favorite (standard)',
            onPressed: () => _say('Favorite'),
          ),
          CommonIconButton(
            icon: Icons.add,
            tooltip: 'Add (filled)',
            variant: CommonIconButtonVariant.filled,
            onPressed: () => _say('Add'),
          ),
          CommonIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit (tonal)',
            variant: CommonIconButtonVariant.tonal,
            onPressed: () => _say('Edit'),
          ),
          CommonIconButton(
            icon: Icons.share_outlined,
            tooltip: 'Share (outlined)',
            variant: CommonIconButtonVariant.outlined,
            onPressed: () => _say('Share'),
          ),
          CommonIconButton(
            icon: Icons.mail_outline,
            tooltip: 'Messages, 3 unread',
            badgeCount: 3,
            onPressed: () => _say('Messages'),
          ),
          CommonIconButton(
            icon: Icons.notifications_outlined,
            tooltip: 'Alerts, new activity',
            badge: '',
            variant: CommonIconButtonVariant.tonal,
            onPressed: () => _say('Alerts'),
          ),
          CommonIconButton(
            icon: Icons.bookmark_border,
            selectedIcon: Icons.bookmark,
            isSelected: _bookmarked,
            tooltip: _bookmarked ? 'Remove bookmark' : 'Bookmark',
            onPressed: () => setState(() => _bookmarked = !_bookmarked),
          ),
          const CommonIconButton(
            icon: Icons.delete_outline,
            semanticsLabel: 'Delete (disabled)',
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _badges() {
    Widget sample(String caption, Widget badge) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(8), child: badge),
          CommonLabelText(caption),
        ],
      );
    }

    return ShowcaseSection(
      title: 'CommonBadge',
      description: 'Counts, overflow (99+), dots and text labels.',
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        children: <Widget>[
          sample(
            'count: 3',
            const CommonBadge(
              count: 3,
              semanticsLabel: '3 unread messages',
              child: Icon(Icons.mail_outline),
            ),
          ),
          sample(
            'count: 120',
            const CommonBadge(count: 120, child: Icon(Icons.chat_outlined)),
          ),
          sample(
            'maxCount: 9',
            const CommonBadge(
              count: 25,
              maxCount: 9,
              child: Icon(Icons.shopping_cart_outlined),
            ),
          ),
          sample(
            'dot',
            const CommonBadge(child: Icon(Icons.notifications_outlined)),
          ),
          sample(
            'label',
            const CommonBadge(label: 'New', child: Icon(Icons.inbox_outlined)),
          ),
          sample(
            'showZero',
            const CommonBadge(
              count: 0,
              showZero: true,
              child: Icon(Icons.task_alt),
            ),
          ),
          sample('standalone', const CommonBadge(count: 7)),
        ],
      ),
    );
  }

  Widget _cards() {
    return ShowcaseSection(
      title: 'CommonCard',
      description:
          'The three Material 3 card types. Cards with onTap get a ripple, '
          'focus highlight and keyboard activation.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          CommonCard(
            onTap: () => _say('Elevated card tapped'),
            child: const CommonBodyText('Elevated card. Tap me.'),
          ),
          CommonCard(
            variant: CommonCardVariant.filled,
            onTap: () => _say('Filled card tapped'),
            child: const CommonBodyText('Filled card. Tap me.'),
          ),
          CommonCard(
            variant: CommonCardVariant.outlined,
            borderRadius: BorderRadius.circular(4),
            onTap: () => _say('Outlined card tapped'),
            child: const CommonBodyText(
              'Outlined card with a custom 4 px radius. Tap me.',
            ),
          ),
          const CommonCard(
            variant: CommonCardVariant.outlined,
            child: CommonBodyText('A static card: no onTap, no ripple.'),
          ),
        ],
      ),
    );
  }

  Widget _dividers() {
    Widget stat(String value, String label) {
      return Column(
        children: <Widget>[
          CommonHeaderText(value, maxLines: 1),
          CommonLabelText(label, textAlign: TextAlign.center),
        ],
      );
    }

    return ShowcaseSection(
      title: 'CommonDivider',
      description:
          'Plain, labeled and vertical dividers. Long labels wrap instead '
          'of overflowing.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const CommonBodyText('Above a plain divider'),
          const CommonDivider(spacing: 24),
          const CommonBodyText('Below it'),
          const CommonDivider(label: 'OR', spacing: 32),
          const CommonDivider(
            label: 'Or continue with one of these accounts',
            spacing: 32,
          ),
          // IntrinsicHeight gives the vertical dividers the height of the
          // tallest stat, at any text scale.
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(child: stat('128', 'Posts')),
                const CommonDivider(axis: Axis.vertical, spacing: 24),
                Expanded(child: stat('4.2k', 'Followers')),
                const CommonDivider(axis: Axis.vertical, spacing: 24),
                Expanded(child: stat('312', 'Following')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsiveGrid() {
    const List<(IconData, String)> tiles = <(IconData, String)>[
      (Icons.insights, 'Insights'),
      (Icons.payments_outlined, 'Payments'),
      (Icons.people_outline, 'Customers'),
      (Icons.inventory_2_outlined, 'Inventory'),
      (Icons.local_shipping_outlined, 'Shipping'),
      (Icons.support_agent, 'Support'),
    ];
    return ShowcaseSection(
      title: 'StudioResponsiveBuilder',
      description:
          'The column count follows the width this section is given (not '
          'the screen width): 1 compact, 2 medium, 3 expanded.',
      child: StudioResponsiveBuilder(
        builder:
            (BuildContext context, StudioWindowSize size, BoxConstraints box) {
              final int columns = switch (size) {
                StudioWindowSize.compact => 1,
                StudioWindowSize.medium => 2,
                StudioWindowSize.expanded => 3,
              };
              const double gap = 12;
              final double tileWidth =
                  ((box.maxWidth - gap * (columns - 1)) / columns)
                      .floorToDouble();
              final ColorScheme scheme = Theme.of(context).colorScheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CommonLabelText(
                    '${size.name}: ${box.maxWidth.round()} px, '
                    '$columns column${columns == 1 ? '' : 's'}',
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: <Widget>[
                      for (final (IconData icon, String label) in tiles)
                        SizedBox(
                          width: tileWidth,
                          child: CommonCard(
                            variant: CommonCardVariant.filled,
                            onTap: () => _say('$label opened'),
                            child: Row(
                              children: <Widget>[
                                Icon(icon, color: scheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CommonHeaderText(
                                    label,
                                    fontSize: 16,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
      ),
    );
  }

  Widget _keyboard() {
    return ShowcaseSection(
      title: 'Keyboard and focus',
      description:
          'Click the first field, then press Tab to move through the fields, '
          'buttons and the link in order (Shift+Tab goes back). Enter or '
          'Space activates the focused control.',
      child: FocusTraversalGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: <Widget>[
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                CommonButton(
                  label: 'Submit',
                  icon: Icons.send,
                  onPressed: () => _say(
                    _name.text.trim().isEmpty
                        ? 'Submitted'
                        : 'Thanks, ${_name.text.trim()}',
                  ),
                ),
                CommonButton(
                  label: 'Reset',
                  variant: CommonButtonVariant.outlined,
                  onPressed: () {
                    _name.clear();
                    _email.clear();
                  },
                ),
                CommonLabelText(
                  'Need help?',
                  link: true,
                  onTap: () => _say('Help link activated'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
