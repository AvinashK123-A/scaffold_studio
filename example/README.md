# scaffold_studio example

A showcase app for the `scaffold_studio` package. It depends only on the
package (through a path dependency) and does not declare any fonts. The
bundled Roboto font is picked up automatically.

## What it shows

- All ten `StudioAppBarStyle`s, with logos, avatars, badges, search, overflow
  menus, image and gradient backgrounds, and custom widgets.
- All `StudioBottomBarStyle`s with 2, 3, 4, 5 and 7 destinations (the last
  shows the "More" overflow), plus label behaviors.
- Adaptive navigation (bottom bar, then rail, then sidebar), and fixed rail,
  sidebar and drawer modes. Also a controller-managed demo.
- Light and dark themes, seed colors, and the system font versus bundled
  Roboto.
- `CommonHeaderText` as plain text, as an underlined link, and as a link
  without underline, along with the other common widgets.
- Text scales of 1.5× and 2.0× for accessibility, and keyboard and focus
  behavior.

## Run

```bash
flutter pub get
flutter run                 # choose a device, e.g. -d macos, -d chrome
```

Resize the desktop or browser window to watch the layout adapt.

## Test

```bash
flutter test                                    # widget tests
flutter test integration_test -d macos          # integration tests
```
