# Upgrade Plan — Date Calculator Mobile

## Current state

Score: 7.5/10 — core feature with edge-case-tested date maths, crash-proof input, a11y guideline tests and fail-closed signing; no app icon, holidays or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Holiday calendar (e.g. Thai public holidays) excluded from business-day counts.
- Remember the last used dates.
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix: the add/subtract field used `int.tryParse`, so a large offset (e.g. `100000000000`) made `DateTime` throw during build (red error screen) and `0x10` was read as 16. New `parseDayOffset` accepts signed decimals within ±1,000,000 days; the field shows a range error otherwise.
- Edge-case unit tests: century leap years (1900/2000/2100), same-day and year-boundary differences, exact leap-day anniversaries, negative breakdown mirroring the positive one, a brute-force check of the business-day formula over 280 start/span combinations, UTC vs local inputs.
- Widget tests: bad offsets never crash, date picker flow updates the difference, end-before-start note, accessibility guidelines (tap target, labels, contrast) and 200% text scale. Result date is announced as a live region.

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).


## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (count the days between two dates or add and subtract days from a date) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
