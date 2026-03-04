
# Core

This folder contains core utilities, foundational types, and shared helpers used across the MoneyAtlas app.

Purpose
- Provide stable, well-tested building blocks for features (formatters, error types, base models, DI helpers).

Layout
- `lib/core/` — primary package root for core code used app-wide.

Usage
- Import modules from `package:moneyatlas/core/...` where needed. Keep core code free of UI dependencies so it remains reusable.

Testing
- Add unit tests under `test/` that target core utilities to keep behaviour stable across releases.

Contributing
- Keep this package minimal and dependency-light. Add cross-cutting utilities here only when they are broadly useful.

For more details, see the project README at the repository root.

