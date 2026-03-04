# MoneyAtlas: Your Guide to World Currencies

MoneyAtlas is a Flutter application that combines real-time currency conversion with an educational encyclopedia about world currencies. Convert between currencies, explore currency history and symbols, and browse flags and currency art — all in one lightweight app.

---

## ✨ Features
- Real-time currency exchange (configurable rate provider)
- Currency encyclopedia with country, symbol, and historical notes
- Atlas view to explore currencies by country or region
- Vault to save favorite currencies for quick access
- Gallery for currency symbols and flags
 - Gallery for currency symbols
- Dark mode and responsive layouts for phones and tablets

---

## 🖥️ Supported Platforms

This project will target **Windows** and **Android** first. Support for additional platforms (iOS, macOS, Linux, and Web) may be added later depending on priorities and contribution.

---

## 📂 Project Structure

- `lib/` — Application source
  - `core/` — Config, theme, utilities
  - `exchange/` — API service and rate logic
  - `converter/` — Currency converter UI
  - `encyclopedia/` — Currency knowledge cards and data models
  - `atlas/` — Country-currency mapping and UI
  - `vault/` — Favorites storage and persistence
  - `gallery/` — Flags & symbols display
  - `shared/` — Common widgets
- `assets/` — Static JSON, flags and symbols
  - `currencies.json` — Currency encyclopedia data
  - `symbols/` — Currency symbol images
- `test/` — Unit and widget tests

---

## 🚀 Getting Started

Prerequisites:

- Install Flutter (stable) — https://flutter.dev/docs/get-started/install
- Ensure `flutter` is on your `PATH` and Android/iOS tooling is configured if targeting those platforms.

Quick start:

```bash
git clone https://github.com/your-username/moneyatlas.git
cd moneyatlas
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
```

Notes:

- The app reads static encyclopedia data from `assets/currencies.json`. Update that file and run `flutter pub get` if you change asset references.
- Exchange rates are fetched from a configurable provider. See `lib/exchange/` for implementation details and how to provide an API key or switch providers.

---

## 🛠 Development

- Code style: follow existing project conventions. Run `dart format .` before committing.
- To add localized strings, use the project's localization setup (check `l10n` or `lib/core` for localization helpers).

---

## 📌 Roadmap

- Interactive world map for exploring currencies
- Quiz mode: "Guess the currency"
- Offline mode with cached exchange rates and encyclopedia
- Publish release APK/AppStore builds

---

## 🤝 Contributing

Contributions are welcome. Suggested workflow:

1. Open an issue to discuss significant changes.
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Open a pull request with a clear description and tests where applicable.

Please follow the project's code style and include tests for new logic.

---

## License

This project is licensed under the MIT License — see the `LICENSE` file for full terms.

Note: third-party dependencies may carry their own licenses (including strong copyleft licenses such as GPL). Audit and comply with dependency licenses before distributing builds that include them.