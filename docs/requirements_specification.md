# MoneyAtlas — Requirements Specification

Version: 1.0
Date: 2026-03-04

## 1. Purpose
This document captures high-level functional and non-functional requirements for MoneyAtlas, a Flutter app for currency conversion and educational content about world currencies.

## 2. Scope
Initial targets: Windows and Android.
Includes: currency conversion, exchange rates, encyclopedia (currency facts), atlas (country-currency mapping), vault (favorites), and symbols gallery (symbols only — no flags).
Excludes: displaying national flags or any feature that may cause political controversy.

## 3. Stakeholders
- Product owner
- Mobile/Desktop users
- Developers and contributors
- API providers (exchange rates)

## 4. Assumptions
- Internet access available for real-time rates (with offline caching fallback)
- App will use an external exchange rates provider (configurable API key)
- Static encyclopedia data is supplied via `assets/currencies.json`

## 5. Functional Requirements
FR-1: Currency Conversion
- Allow user to select source and target currencies and input an amount.
- Display converted amount using latest exchange rates.
- Support common numeric formats and separators.

FR-2: Exchange Rates
- Fetch rates from a configurable provider.
- Cache recent rates for offline usage and rate-limited situations.
- Allow manual refresh.

FR-3: Encyclopedia
- Display currency name, ISO code, symbol, country/region, and brief historical notes from `assets/currencies.json`.
- Support search and basic filtering.

FR-4: Atlas
- Provide a country-to-currency mapping view and search by country name.

FR-5: Vault (Favorites)
- Allow saving favorite currencies and quick access in converter.
- Persist favorites locally (platform-appropriate storage).

FR-6: Symbols Gallery
- Display currency symbols/artwork only (explicitly do NOT show flags).
- Provide zoom/preview for symbols.

FR-7: Settings
- Allow selecting rate provider and entering API keys.
- Toggle dark/light theme or follow system theme.

## 6. Non-Functional Requirements
NFR-1: Performance
- Cold-start time should be minimal; UI interactions should be smooth (60 FPS target on supported devices).

NFR-2: Reliability & Offline
- Cached exchange rates and encyclopedia data must enable basic conversion offline.

NFR-3: Security & Privacy
- Do not store API keys in source control. Provide a secure local storage pattern.
- Protect user data stored in the Vault.

NFR-4: Accessibility
- Support large fonts, screen readers, and color contrast best practices.

NFR-5: Internationalization
- App must be prepared for localization; strings should be externalized.

NFR-6: Licensing
- Project licensed MIT. Track third-party dependency licenses and avoid shipping incompatible copyleft code without compliance.

## 7. Data & APIs
- `assets/currencies.json` provides encyclopedia data.
- Exchange rate provider: configurable (e.g., https://exchangeratesapi.io/ or other). Must support HTTPS and optional API key.
- Caching: local database or file-based cache (e.g., SQLite, Hive, SharedPreferences) depending on platform.

## 8. Assets
- `symbols/` — currency symbol images (kept).
- `flags/` — removed intentionally; do not include.

## 9. Testing Requirements
- Unit tests for conversion logic and caching behavior.
- Widget tests for main navigation and converter UI.
- Integration tests for end-to-end conversion and rate updates.

## 10. Acceptance Criteria
- Core converter works offline using cached rates.
- Encyclopedia entries display correctly and search works.
- Vault persists favorites between app restarts.
- Symbols gallery shows symbols only (no flags).
- App builds and runs on Windows and Android.

## 11. Delivery & CI
- Build artifacts: platform-specific installers for Windows and Android (APK/AAB).
- CI: run `flutter analyze`, `dart format`, `flutter test`, and optional license scanning.

## 12. Risks & Mitigations
- License conflicts from dependencies: run license audit, prefer permissive packages.
- API stability: support fallback provider and cached rates.

## 13. Next Steps
- Wire real screens into `lib/` (replace placeholders).  
- Implement converter feature and unit tests.  
- Add CI job to run tests and license scanning.
