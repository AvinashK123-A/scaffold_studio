// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:scaffold_studio/scaffold_studio.dart';

/// A scrolling page body with consistent padding and spacing.
///
/// Uses a [SingleChildScrollView] (rather than a lazy list) because the
/// showcase pages are short, and laying out every section at once means
/// layout problems such as overflows surface immediately, at any size.
class ShowcasePage extends StatelessWidget {
  /// Creates a page body.
  const ShowcasePage({
    super.key,
    required this.children,
    this.bottomPadding = 96,
  });

  /// The sections of the page.
  final List<Widget> children;

  /// Extra space at the end, so a floating action button never covers the
  /// last section.
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: children,
      ),
    );
  }
}

/// A titled section of a showcase page, drawn as an outlined card.
class ShowcaseSection extends StatelessWidget {
  /// Creates a section.
  const ShowcaseSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  /// The section heading.
  final String title;

  /// An optional sentence that explains what the section demonstrates.
  final String? description;

  /// The demo content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String? description = this.description;
    return CommonCard(
      variant: CommonCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CommonHeaderText(title, fontSize: 18),
          if (description != null) ...<Widget>[
            const SizedBox(height: 4),
            CommonBodyText(
              description,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// A highlighted hint that tells the reader what to look for.
class ObserveNote extends StatelessWidget {
  /// Creates a hint.
  const ObserveNote(this.text, {super.key, this.icon = Icons.visibility});

  /// The hint text.
  final String text;

  /// The leading icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return CommonCard(
      variant: CommonCardVariant.filled,
      color: scheme.secondaryContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: scheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: CommonBodyText(text, color: scheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

/// A small square brand mark used as an app bar logo and sidebar header.
class DemoLogo extends StatelessWidget {
  /// Creates a logo.
  const DemoLogo({super.key, this.size = 32});

  /// The edge length.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Scaffold Studio logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 4),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[scheme.primary, scheme.tertiary],
          ),
        ),
        child: Icon(
          Icons.dashboard_customize,
          size: size * 0.6,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}

/// A profile avatar for app bars and headers.
class DemoAvatar extends StatelessWidget {
  /// Creates an avatar.
  const DemoAvatar({super.key, this.radius = 16});

  /// The avatar radius.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Profile: Avinash',
      child: CircleAvatar(
        radius: radius,
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        child: Icon(Icons.person, size: radius * 1.2),
      ),
    );
  }
}

/// Shows a short message, replacing any message that is still visible.
void showDemoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}
