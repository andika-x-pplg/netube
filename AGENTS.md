# Repository Guidelines

## Project Structure & Module Organization

Netube is a Flutter application. Application code lives in `lib/`:

- `pages/` contains screen-level widgets such as Home, Movie Detail, Shorts, and Profile.
- `widgets/` contains reusable presentation components.
- `services/` owns Firebase, Firestore, TMDB, YouTube, and user-interaction logic.
- `models/` contains data models.
- `theme/` contains shared colors and application theming.
- `main.dart` initializes Firebase and starts the application.

Platform projects are under `android/`, `ios/`, `web/`, `windows/`, `linux/`, and `macos/`. Tests belong in `test/`. Generated output under `build/` and `.dart_tool/` must not be committed or edited manually. No application asset directory is currently configured in `pubspec.yaml`.

## Build, Test, and Development Commands

Run commands from the repository root:

```bash
flutter pub get          # Install locked dependencies
flutter run              # Launch on a selected device
flutter analyze          # Run flutter_lints and static analysis
dart format lib test     # Format Dart source and tests
flutter test             # Run all widget and unit tests
flutter build apk        # Produce a release Android APK
```

Run `flutter devices` when Flutter cannot select a target automatically.

## Coding Style & Naming Conventions

Use two-space Dart indentation and allow `dart format` to determine wrapping. Follow `flutter_lints` configured in `analysis_options.yaml`. Use `UpperCamelCase` for classes, `lowerCamelCase` for members, and `lower_case_with_underscores.dart` for filenames. Keep pages focused on UI composition and place API, authentication, and Firestore operations in `services/`. Prefer theme constants from `lib/theme/` over repeated color literals.

Do not rename Firestore collections, document paths, routes, public classes, or service methods without documenting the required migration.

## Testing Guidelines

Tests use `flutter_test`. Name files `*_test.dart` and group them by feature, for example `test/widgets/movie_card_test.dart`. Add widget tests for navigation and responsive states, and unit tests for logic that does not require live Firebase. Every change should pass `flutter analyze` and `flutter test`.

## Commit & Pull Request Guidelines

History commonly uses short prefixes such as `feat:`, `build:`, and `redesain:`. Prefer an imperative Conventional Commit subject, such as `feat: redesign movie detail header` or `fix: preserve reply like state`.

Pull requests should describe scope, verification commands, Firebase or configuration impact, and any known limitations. Link relevant issues and include before/after screenshots for UI changes. Keep business-logic and visual refactors separated when practical.

## Security & Configuration

Never commit private Firebase credentials, signing keys, or new API secrets. Preserve the existing Firestore schema and validate configuration changes across supported platforms.
