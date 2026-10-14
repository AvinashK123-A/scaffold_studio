// Copyright (c) 2026 Avinash Reddy Kommareddy.
// All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Generates the background image of the image app bar demo at runtime, so
/// the showcase needs no assets and no network.
///
/// The picture is painted with a [Canvas], rasterized with
/// [ui.Picture.toImage], encoded as PNG and wrapped in a [MemoryImage]. The
/// work is asynchronous, so the demo page shows a gradient until it
/// completes. It only starts when the image demo is opened, and the result
/// is cached for later visits.
class DemoImages {
  DemoImages._();

  static ImageProvider<Object>? _header;
  static Future<ImageProvider<Object>>? _pending;

  /// The header image if it has already been generated.
  static ImageProvider<Object>? get cachedHeader => _header;

  /// Forgets the cached and pending images, so a test starts from a clean
  /// state.
  @visibleForTesting
  static void resetForTesting() {
    _header = null;
    _pending = null;
  }

  /// Returns the header image, generating it on first use.
  static Future<ImageProvider<Object>> header() {
    final ImageProvider<Object>? done = _header;
    if (done != null) {
      return Future<ImageProvider<Object>>.value(done);
    }
    return _pending ??= _generateHeader().then(
      (ImageProvider<Object> image) {
        _pending = null;
        return _header = image;
      },
      onError: (Object error, StackTrace stackTrace) {
        // Allow a later visit to try again.
        _pending = null;
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
  }

  static Future<ImageProvider<Object>> _generateHeader() async {
    const double width = 960;
    const double height = 240;
    const Rect bounds = Rect.fromLTWH(0, 0, width, height);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, bounds);

    // Sky.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1A237E), Color(0xFFFF7043)],
        ).createShader(bounds),
    );
    // Sun.
    canvas.drawCircle(
      const Offset(width * 0.72, height * 0.62),
      54,
      Paint()..color = const Color(0xFFFFD54F),
    );
    // Two mountain ranges.
    final Path far = Path()
      ..moveTo(0, height * 0.7)
      ..lineTo(width * 0.18, height * 0.42)
      ..lineTo(width * 0.36, height * 0.66)
      ..lineTo(width * 0.55, height * 0.38)
      ..lineTo(width * 0.8, height * 0.7)
      ..lineTo(width, height * 0.5)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF5C3C6E));
    final Path near = Path()
      ..moveTo(0, height * 0.86)
      ..lineTo(width * 0.25, height * 0.62)
      ..lineTo(width * 0.48, height * 0.88)
      ..lineTo(width * 0.7, height * 0.66)
      ..lineTo(width, height * 0.9)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(near, Paint()..color = const Color(0xFF2E1F3D));

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    picture.dispose();
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('The header image could not be encoded.');
      }
      return MemoryImage(data.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  }
}
