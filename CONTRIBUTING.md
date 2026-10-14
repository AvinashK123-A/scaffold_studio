# Contributing to scaffold_studio

Thank you for helping improve this package. Bug reports, documentation fixes
and focused pull requests are all welcome.

## Before you start

- For anything larger than a small fix, open an issue first to agree on the
  approach. The public API is intentionally small; new options need a clear
  use case.
- The package must keep depending only on the Flutter SDK.

## Development setup

```bash
flutter pub get
cd example && flutter pub get
```

## Checks to run before opening a pull request

From the repository root:

```bash
dart format --output=none --set-exit-if-changed lib test example
flutter analyze
flutter test
```

From `example/`:

```bash
flutter analyze
flutter test
flutter test integration_test -d macos   # or another desktop/mobile device
```

All of these must pass. Do not weaken lint rules or delete meaningful tests
to make them pass.

## Code conventions

- Every authored Dart file starts with the project copyright header:

  ```dart
  // Copyright (c) 2026 Avinash Reddy Kommareddy.
  // All rights reserved.
  // Use of this source code is governed by a BSD-style license
  // that can be found in the LICENSE file.
  ```

  By contributing, you agree that your contribution is licensed under the
  BSD 3-Clause License in [LICENSE](LICENSE).
- Public API is exported only from `lib/scaffold_studio.dart`; implementation
  lives in `lib/src/`, and helpers that are not public go in `internal/`
  folders.
- Every public member needs a `///` doc comment that explains behavior,
  defaults and constraints, not syntax.
- Prefer composition over Flutter's existing widgets and themes over new
  abstractions. Avoid `dynamic`, null assertions (`!`) and deprecated APIs.
- Invalid but recoverable input (for example an out-of-range index) must not
  throw. Configuration mistakes should fail an `assert` with a helpful
  message.
- Add or update tests with every behavior change, including a responsive or
  text-scale case when layout is affected.

## Third-party material

Do not add code, fonts, icons or images from other sources unless their
license permits redistribution and the required notices are added to
[LICENSE](LICENSE) and the README.
