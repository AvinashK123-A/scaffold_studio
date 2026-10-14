// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

import '../demo_image.dart';
import '../widgets/showcase_widgets.dart';
import 'app_bars_page.dart';

/// A full-screen demo of one [StudioAppBarStyle] with realistic content.
class AppBarDemoPage extends StatefulWidget {
  /// Creates a demo for [style].
  const AppBarDemoPage({super.key, required this.style});

  /// The style being demonstrated.
  final StudioAppBarStyle style;

  @override
  State<AppBarDemoPage> createState() => _AppBarDemoPageState();
}

class _AppBarDemoPageState extends State<AppBarDemoPage> {
  static const String _longTitleText =
      'Quarterly performance review for the north-east region';

  static const List<String> _products = <String>[
    'Wireless headphones',
    'Mechanical keyboard',
    'USB-C hub',
    'Standing desk',
    'Ergonomic chair',
    'Monitor arm',
    'Webcam',
    'Desk lamp',
    'Laptop stand',
    'Cable organizer',
  ];

  bool _longTitle = false;
  int _notifications = 3;
  String _query = '';
  ImageProvider<Object>? _image = DemoImages.cachedHeader;
  bool _imageFailed = false;

  @override
  void initState() {
    super.initState();
    // The image is only generated when this demo is opened, never at app
    // start-up.
    if (widget.style == StudioAppBarStyle.image && _image == null) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final ImageProvider<Object> image = await DemoImages.header();
      if (mounted) {
        setState(() => _image = image);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _imageFailed = true);
      }
    }
  }

  String _title(String normal) => _longTitle ? _longTitleText : normal;

  StudioAction _action(IconData icon, String tooltip) {
    return StudioAction(
      icon: icon,
      tooltip: tooltip,
      onPressed: () => showDemoSnackBar(context, '$tooltip pressed'),
    );
  }

  StudioAction get _notificationsAction => StudioAction(
    icon: Icons.notifications_outlined,
    tooltip: 'Notifications',
    badgeCount: _notifications,
    onPressed: () {
      setState(() => _notifications = 0);
      showDemoSnackBar(context, 'All notifications read');
    },
  );

  List<StudioAction> get _extraActions => <StudioAction>[
    _action(Icons.bookmark_border, 'Bookmarks'),
    _action(Icons.share_outlined, 'Share'),
    _action(Icons.favorite_border, 'Favorites'),
    _action(Icons.settings_outlined, 'Settings'),
    _action(Icons.help_outline, 'Help'),
  ];

  Future<void> _confirmLeave() async {
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Leave this demo?'),
        content: const Text(
          'onBackPressed replaced the default back behavior of the app bar '
          'to ask first.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if ((leave ?? false) && mounted) {
      Navigator.of(context).pop();
    }
  }

  StudioAppBar _buildAppBar() {
    final StudioAction notifications = _notificationsAction;
    switch (widget.style) {
      case StudioAppBarStyle.standard:
        return StudioAppBar(
          logo: const DemoLogo(),
          titleText: _title('Dashboard'),
          actions: <Widget>[notifications, ..._extraActions],
          profile: const DemoAvatar(),
        );
      case StudioAppBarStyle.centered:
        return StudioAppBar(
          style: StudioAppBarStyle.centered,
          titleText: _title('Centered'),
          onBackPressed: _confirmLeave,
          actions: <Widget>[notifications, _action(Icons.share, 'Share')],
        );
      case StudioAppBarStyle.minimal:
        return StudioAppBar(
          style: StudioAppBarStyle.minimal,
          titleText: _title('Minimal'),
          actions: <Widget>[
            notifications,
            _action(Icons.filter_list, 'Filter'),
          ],
        );
      case StudioAppBarStyle.transparent:
        return StudioAppBar(
          style: StudioAppBarStyle.transparent,
          titleText: _title('Transparent'),
          foregroundColor: Colors.white,
          actions: <Widget>[
            notifications,
            _action(Icons.share_outlined, 'Share'),
            _action(Icons.favorite_border, 'Favorites'),
          ],
        );
      case StudioAppBarStyle.gradient:
        return StudioAppBar(
          style: StudioAppBarStyle.gradient,
          logo: const DemoLogo(),
          titleText: _title('Gradient'),
          subtitleText: 'Follows the seed color',
          actions: <Widget>[notifications, ..._extraActions],
          profile: const DemoAvatar(),
        );
      case StudioAppBarStyle.image:
        // Until the generated image is ready (or if it fails), the image
        // style paints its neutral dark fallback behind the white content.
        return StudioAppBar(
          style: StudioAppBarStyle.image,
          backgroundImage: _image,
          titleText: _title('Image'),
          subtitleText: _image != null
              ? 'Painted at runtime with dart:ui'
              : _imageFailed
              ? 'Image unavailable, showing the fallback'
              : 'Generating the image...',
          actions: <Widget>[notifications, _action(Icons.share, 'Share')],
        );
      case StudioAppBarStyle.rounded:
        return StudioAppBar(
          style: StudioAppBarStyle.rounded,
          titleText: _title('Rounded'),
          actions: <Widget>[notifications, ..._extraActions.take(3)],
          profile: const DemoAvatar(),
        );
      case StudioAppBarStyle.search:
        return StudioAppBar(
          style: StudioAppBarStyle.search,
          titleText: _title('Products'),
          search: StudioAppBarSearch(
            hintText: 'Search products',
            onChanged: (String query) => setState(() => _query = query),
            onSubmitted: (String query) =>
                showDemoSnackBar(context, 'Searched for "$query"'),
          ),
          actions: <Widget>[
            notifications,
            _action(Icons.filter_list, 'Filter'),
            _action(Icons.sort, 'Sort'),
          ],
          profile: const DemoAvatar(),
        );
      case StudioAppBarStyle.profile:
        return StudioAppBar(
          style: StudioAppBarStyle.profile,
          profile: const DemoAvatar(radius: 20),
          titleText: _title('Good morning, Avinash'),
          subtitleText: _notifications == 0
              ? 'You are all caught up'
              : 'You have $_notifications new notifications',
          // On a pushed route the back button keeps the leading slot and
          // the avatar moves to the end; as a root page the avatar leads.
          actions: <Widget>[
            notifications,
            _action(Icons.settings_outlined, 'Settings'),
          ],
        );
      case StudioAppBarStyle.flexible:
        // The inline leading (back button, avatar and name) shares the
        // width with the title; its name is Flexible and ellipsizes. On
        // compact windows Invite is an icon button, which leaves more room
        // for the name and title than a text button would.
        final bool compact = StudioResponsiveBuilder.windowSizeOf(
          context,
        ).isCompact;
        void invite() => showDemoSnackBar(context, 'Invite sent');
        return StudioAppBar(
          style: StudioAppBarStyle.flexible,
          leading: const _ContactLeading(),
          title: _TeamTitle(name: _title('Design team')),
          actions: <Widget>[
            _action(Icons.videocam_outlined, 'Video call'),
            _action(Icons.call_outlined, 'Call'),
            notifications,
            if (compact)
              CommonIconButton(
                icon: Icons.person_add_alt,
                tooltip: 'Invite',
                variant: CommonIconButtonVariant.tonal,
                onPressed: invite,
              )
            else
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4, end: 8),
                child: Center(
                  child: CommonButton(
                    label: 'Invite',
                    variant: CommonButtonVariant.tonal,
                    size: CommonButtonSize.small,
                    onPressed: invite,
                  ),
                ),
              ),
          ],
        );
    }
  }

  String get _observeText => switch (widget.style) {
    StudioAppBarStyle.standard =>
      'Resize the window: on narrow widths Bookmarks, Share, Favorites, '
          'Settings and Help move into the "More options" menu, while the '
          'avatar stays visible. Tap the bell to clear its badge.',
    StudioAppBarStyle.centered =>
      'The title stays centered at every width. The back arrow calls '
          'onBackPressed, which asks before leaving. The system back gesture '
          'is not affected; combine it with PopScope for that.',
    StudioAppBarStyle.minimal =>
      'A smaller title and no elevation when content scrolls underneath. '
          'Scroll the page and compare with the Standard style.',
    StudioAppBarStyle.transparent =>
      'The body extends behind the bar (extendBodyBehindAppBar), so the '
          'gradient shows through. Status bar icons follow the white '
          'foreground color.',
    StudioAppBarStyle.gradient =>
      'The gradient is derived from the seed color: change it in Settings '
          'and come back. Long titles ellipsize before the actions.',
    StudioAppBarStyle.image =>
      'The header image is painted at runtime with dart:ui and loaded as a '
          'MemoryImage. Until it is ready the style shows a neutral dark '
          'fallback, and the scrim keeps white text legible.',
    StudioAppBarStyle.rounded =>
      'Rounded bottom corners on a tonal surface. Turn on the long title and '
          'rotate the device to watch it ellipsize.',
    StudioAppBarStyle.search =>
      'On compact widths the field replaces the title; on wider windows the '
          'title sits next to it. Type to filter the list below.',
    StudioAppBarStyle.profile =>
      'The greeting has a subtitle, and with large text the bar grows '
          'taller instead of clipping. As a root page the avatar leads the '
          'bar; on a pushed route like this one the back button keeps the '
          'leading slot and the avatar moves to the end.',
    StudioAppBarStyle.flexible =>
      'The leading widget (back button, avatar and name) is wider than an '
          'icon and shares the row with a custom title widget: narrow the '
          'window and the name ellipsizes. Invite is a custom action, so it '
          'never moves into the overflow menu.',
  };

  @override
  Widget build(BuildContext context) {
    final bool transparent = widget.style == StudioAppBarStyle.transparent;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<String> results = <String>[
      for (final String product in _products)
        if (product.toLowerCase().contains(_query.trim().toLowerCase()))
          product,
    ];

    return ScaffoldStudio(
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: transparent,
      backgroundDecoration: transparent
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF4A148C),
                  Color(0xFFC2185B),
                  Color(0xFFFF8F00),
                ],
              ),
            )
          : null,
      body: ShowcasePage(
        bottomPadding: 24,
        children: <Widget>[
          ObserveNote(_observeText),
          CommonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Long title'),
                  subtitle: const Text('Shows how the title ellipsizes'),
                  value: _longTitle,
                  onChanged: (bool value) => setState(() => _longTitle = value),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    CommonButton(
                      label: 'Add notification',
                      icon: Icons.add_alert_outlined,
                      variant: CommonButtonVariant.tonal,
                      onPressed: () => setState(() => _notifications++),
                    ),
                    CommonButton(
                      label: 'Back to app bars',
                      icon: Icons.arrow_back,
                      variant: CommonButtonVariant.outlined,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.style == StudioAppBarStyle.search) ...<Widget>[
            CommonLabelText(
              results.isEmpty
                  ? 'No products match "$_query"'
                  : '${results.length} products',
              color: scheme.onSurfaceVariant,
            ),
            for (final String product in results)
              CommonCard(
                variant: CommonCardVariant.outlined,
                onTap: () => showDemoSnackBar(context, product),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.shopping_bag_outlined, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: CommonBodyText(product, maxLines: 2)),
                  ],
                ),
              ),
          ] else
            for (int i = 1; i <= 8; i++)
              CommonCard(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: Text('$i'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CommonHeaderText(
                            '${appBarStyleName(widget.style)} item $i',
                            fontSize: 16,
                            maxLines: 1,
                          ),
                          const CommonBodyText(
                            'Scroll to see how the bar reacts to content '
                            'underneath it.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// A leading widget wider than an icon: back button, avatar and name. The
/// name is Flexible, so it ellipsizes when the app bar is narrow.
class _ContactLeading extends StatelessWidget {
  const _ContactLeading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BackButton(),
        CommonBadge(
          label: '',
          backgroundColor: Color(0xFF2E7D32),
          alignment: AlignmentDirectional.bottomEnd,
          semanticsLabel: 'Online',
          child: DemoAvatar(),
        ),
        SizedBox(width: 8),
        Flexible(
          child: CommonHeaderText('Avinash Reddy', fontSize: 16, maxLines: 1),
        ),
      ],
    );
  }
}

/// A custom title widget: a tonal chip with an icon and a name. When the
/// title slot is very narrow it falls back to plain, ellipsized text.
class _TeamTitle extends StatelessWidget {
  const _TeamTitle({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 96) {
          return CommonLabelText(name, maxLines: 1);
        }
        return DecoratedBox(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: scheme.secondaryContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.groups,
                  size: 18,
                  color: scheme.onSecondaryContainer,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: CommonLabelText(
                    name,
                    maxLines: 1,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
