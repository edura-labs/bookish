# Bookish: Reading Tracker

A quiet, offline-first reading tracker for iOS and Android. Search for any book, put it on your shelf, and track how far you've read, with no account and no sign-up.

> **Status:** v1 in development, foundation phase. The project is set up and themed; features are being built in the order listed in [Roadmap](#roadmap).

---

## What it does (v1)

| Feature | Description | Status |
|---|---|---|
| Search | Find books by title, author or keyword via Open Library | Planned |
| Book details | Cover, title, author, first published year, page count, description | Planned |
| Shelf | Add a book as **Want to Read**, **Reading** or **Finished**, and change its status | Planned |
| Progress | Log your current page; see percentage complete | Planned |
| My Shelf | Your books in three tabs, one per status | Planned |

**Not in v1:** reading stats, yearly goals, notes and quotes, barcode/ISBN scanning, sharing, accounts, cloud sync, home-screen widgets.

## Design

"Paper, ink and walnut": a warm, calm interface where the book covers carry the colour.

- **Light:** cream paper background, dark brown ink text, walnut brown accent, forest green for finished books.
- **Dark:** near-black background with parchment text; coloured fills are dark enough to carry white text.
- **Type:** Fraunces (serif) for headings and titles, Inter for body text.
- **Contrast rule:** dark text on light backgrounds; white/light text on dark backgrounds and throughout dark mode.
- Follows the system light/dark setting.

The theme lives in [`lib/ui/common/app_theme.dart`](lib/ui/common/app_theme.dart).

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart), iOS and Android |
| Architecture / state | [Stacked](https://pub.dev/packages/stacked) (View → ViewModel → Service) |
| Networking | [Dio](https://pub.dev/packages/dio) |
| Local storage | [Hive CE](https://pub.dev/packages/hive_ce) (on-device only) |
| Images | [cached_network_image](https://pub.dev/packages/cached_network_image) |
| Fonts | [google_fonts](https://pub.dev/packages/google_fonts) |
| Loading states | [shimmer](https://pub.dev/packages/shimmer) |
| Formatting | [intl](https://pub.dev/packages/intl) |

There is **no backend**. Book data comes from the free [Open Library API](https://openlibrary.org/developers/api); everything you save stays on your device.

## Project structure

```
lib/
  app/          Routes and service registration (Stacked)
  models/       Book, ShelfEntry
  services/     OpenLibraryService (API), ShelfService (storage)
  ui/
    common/     Theme, colours, spacing helpers
    views/      Screens, each with its ViewModel
    widgets/    Reusable widgets (book cover, book tile, status chip)
test/           ViewModel, service and golden tests
```

**Rules:** ViewModels never call Dio or Hive directly. All API access goes through `OpenLibraryService` and all storage through `ShelfService`, registered in `lib/app/app.dart` and accessed via the locator.

## Getting started

**Requirements:** Flutter (stable channel), Xcode for iOS, Android Studio / Android SDK for Android.

```bash
git clone git@github.com:edura-labs/bookish.git
cd bookish
flutter pub get
flutter run
```

After changing anything in `lib/app/app.dart` (routes, services, dialogs, bottom sheets), regenerate the Stacked files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

To scaffold new views or services, use the [Stacked CLI](https://pub.dev/packages/stacked_cli):

```bash
stacked create view <name>
stacked create service <name>
```

## Testing

```bash
flutter test
```

Golden tests live in `test/golden/`. To regenerate the golden screenshots after an intentional UI change:

```bash
flutter test --update-goldens
```

## App identity

| | |
|---|---|
| Store name | Bookish: Reading Tracker |
| Home-screen name | Bookish |
| Bundle ID / applicationId | `com.eduralabs.bookish` |

## Roadmap

1. ✅ Project setup, theme, bundle ID, iOS/Android only
2. ⬜ `Book` model and `OpenLibraryService`
3. ⬜ Search screen with debounced search and result tiles
4. ⬜ Book detail screen
5. ⬜ `ShelfEntry` model, `ShelfService` (Hive), add/change status
6. ⬜ My Shelf screen with three tabs
7. ⬜ Reading progress updates
8. ⬜ Polish: loading, empty and error states; dark mode review

## Data source and credits

Book data and covers are provided by [Open Library](https://openlibrary.org/), a project of the Internet Archive. Requests identify the app with a User-Agent header, and search input is debounced to keep load on the API low.

## License

© 2026 Eduralabs. All rights reserved.
