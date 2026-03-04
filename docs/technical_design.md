# MoneyAtlas — Technical Design

Version: 1.0
Date: 2026-03-04

## Overview
This document describes the architecture and major technical decisions for MoneyAtlas. It is intended to guide implementation, testing, and maintenance for Windows and Android targets.

## High-level Architecture
- Flutter (single codebase) targeting Windows and Android.
- Layered architecture:
  - UI: `lib/*` widgets and screens (feature folders: `converter`, `exchange`, `encyclopedia`, `atlas`, `vault`, `gallery`)
  - Presentation: widgets, view models / controllers
  - Domain: business logic (conversion math, rate application, validation)
  - Data: repositories, API clients, local persistence, asset readers

## Routing & App Shell
- `MaterialApp` in `lib/main.dart` defines named routes for each feature module.
- Home screen is the app shell. Feature modules are separate widgets (ideally in their own files/directories) and registered in the `routes` map.

## State Management
Options (recommendation: `Riverpod` or `Provider`):
- Global: app settings (theme, API provider settings) via a top-level provider.
- Feature-scoped: converters, exchange rates, and vault should use separate providers to keep concerns isolated.
- Reasons to prefer Riverpod:
  - Compile-time safety (no BuildContext issues)
  - Testability
  - Easy scoping for platform-specific implementations

## Data Flow and Repositories
- Use repository interfaces for ExchangeRatesRepository, EncyclopediaRepository, and VaultRepository.
- Implementations:
  - ExchangeRatesRepository: implements network client to provider + caching layer.
  - EncyclopediaRepository: reads `assets/currencies.json` and can provide search/filter APIs.
  - VaultRepository: local persistence for favorites and small user preferences.

## APIs and Networking
- Exchange rate provider: configurable endpoint with optional API key.
- HTTP client: use `http` or `dio` package.
- Use TLS, validate certificates (default Flutter behavior).
- Retry/backoff policy for transient errors (2-3 retries with exponential backoff).

## Caching & Offline
- Cache latest exchange rates with timestamp.
- Cache storage choices:
  - Small structured data: `SharedPreferences` for key-value cache (fast and simple).
  - For richer storage or potential future expansion: `Hive` or `Sqflite`.
- Cache eviction: TTL (e.g., 12 hours) or manual refresh via user action.
- On startup: load cached rates; if network available and cache expired, fetch fresh rates.

## Persistence
- `Vault` (favorites): persisted locally.
- Recommended storage: `Hive` for cross-platform binary performance; fallback to `SharedPreferences` for a minimal implementation.

## Assets
- `assets/currencies.json` contains encyclopedia data. Load via `rootBundle.loadString()`.
- `assets/symbols/` contains currency symbol images. No `flags/` assets (intentional).
- Keep assets optimized (SVGs or appropriately sized PNGs) and list them in `pubspec.yaml` under `flutter.assets`.

## UI / UX Considerations
- Responsive layout: use `LayoutBuilder` and adaptive widgets for Windows and Android.
- Theme: use `ColorScheme.fromSeed` and `useMaterial3: true` (already applied in `main.dart`).
- Accessibility: semantic labels for icons and images; test with screen readers; ensure contrast.

## Error Handling & UX
- Surface user-friendly messages for network or parsing errors.
- Provide manual retry and status indicators (last updated timestamp for rates).

## Security
- Never commit API keys or secrets. Use secure local storage for secrets where required (e.g., Android Keystore; Windows DPAPI or secure storage package).
- Hardening: validate inputs, sanitize any external data before displaying, and avoid logging secrets.

## Licensing & Dependency Policy
- Repo license: MIT.
- Maintain a dependency license audit. Prefer permissive dependencies.
- If a GPL-3.0 dependency is added and included in distributed binaries, ensure compliance with GPL (source provision etc.).

## Testing Strategy
- Unit tests: conversion logic, repository logic, caching behavior.
- Widget tests: `HomeScreen`, `ConverterScreen` UI interactions.
- Integration tests: end-to-end conversion flow using a test server or mocked HTTP responses.
- CI: run `flutter analyze`, `dart format --verify`, `flutter test`.

## CI / CD
- CI pipeline steps:
  1. Checkout
  2. Install Flutter
  3. Run `flutter pub get`
  4. Static analysis: `flutter analyze`
  5. Formatting check: `dart format --set-exit-if-changed .`
  6. Tests: `flutter test`
  7. Optional: license scan
- CD: build installers/artifacts for Windows and Android (APK/AAB). Keep signing keys out of repo; store in CI secrets.

## Observability & Logging
- Use structured logging (e.g., `logger` package) with adjustable verbosity.
- Capture errors to crash reporting system (optional — ensure privacy and permission).

## Performance
- Aim for smooth UI interactions (60 FPS on supported devices).
- Use efficient list rendering (`ListView.builder`) and image caching.
- Optimize heavy tasks off the UI thread — use Isolates for computationally intensive work if needed.

## Platform Details
- Windows:
  - Packaging: MSIX or installer as desired.
  - Storage paths: use platform API for user data locations.
- Android:
  - Packaging: APK/AAB. Ensure proper signing configuration is stored in CI secrets.

## Extensibility
- Keep features modular. Each feature should be implemented under its folder with an exported screen and repository.
- Use interfaces and dependency injection (via Riverpod or simple factory patterns) to swap implementations (e.g., different rate providers).

## File & Module Map (suggested)
- `lib/main.dart` — application shell and routes
- `lib/core/` — app-wide utilities, theme, constants
- `lib/exchange/` — exchange rate client, repository, screens
- `lib/converter/` — converter UI, view model
- `lib/encyclopedia/` — data models, asset loader, UI
- `lib/atlas/` — country-currency mapping UI
- `lib/vault/` — favorites storage, persistent logic
- `lib/gallery/` (or `lib/symbols/`) — symbols display only
- `lib/shared/` — common widgets

## Migration & Versioning
- Use semantic versioning. Update `version` in `pubspec.yaml`.
- Use migration guides for breaking changes and document in `docs/`.
