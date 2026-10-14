<div align="center">

# 🍽️ Restaurant POS

**A professional, open-source Point-of-Sale system for restaurants — built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-22c55e.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](#)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

*Minimal · Premium · Production-Ready · Offline-First*

[Features](#-features) · [Screenshots](#-screenshots) · [Architecture](#-architecture) · [Installation](#-installation) · [Roadmap](#-roadmap) · [Contributing](#-contributing)

</div>

---

## 📖 Overview

**Restaurant POS** is a full-featured, tablet-optimized Point-of-Sale application purpose-built for restaurants and cafés. It runs entirely offline using a local SQLite database and delivers a polished bilingual (Arabic RTL / English) experience backed by a clean, Minimal + Premium design system.

The app is designed primarily for **10"–13" Android tablets** in landscape mode and is architected for clean portability to iOS without code rewrites.

### Why this project?

Most restaurant POS systems in the market are:
- Expensive SaaS subscriptions with recurring fees
- Cloud-dependent (fails without internet)
- English-only, with poor RTL support
- Closed-source with no customization

**Restaurant POS** solves all four problems in a single open-source Flutter app.

---

## ✨ Features

### Core POS
- **Split-screen tablet layout** — 70% menu grid / 30% live order receipt panel
- **Category tabs** with smooth horizontal scrolling
- **Best Seller badges** — automatically highlights top-performing items
- **Real-time order management** — add, remove, adjust quantities instantly
- **One-tap invoice printing** via Bluetooth thermal printer

### Menu Management
- Full **CRUD** for categories and menu items
- **Photo support** for each item via image picker
- Availability toggle to hide items without deleting them
- Pricing management with currency formatting

### Financial Dashboard
- **Revenue analytics** — Today / This Week / This Month / This Year / Custom range
- **Bar charts** powered by fl_chart showing top-selling items
- **Net profit calculation** = Sales − Expenses − Salaries
- Total invoices count and financial KPIs at a glance

### Expenses & Payroll
- Log and categorize operational expenses
- Running total with visual summary card
- Timestamp-based expense history

### Employees
- Staff profile management
- Salary tracking integrated into profit calculations

### Bluetooth Thermal Printing
- Auto-discovers all **paired Bluetooth devices** on the tablet
- Supports **56mm** and **58mm** thermal paper widths
- Persistent printer selection (saved across sessions)
- Test print button to verify connection
- Custom receipt header: restaurant name, address, footer text

### Settings & Theming
- **5 accent colors**: Blue · Green · Orange · Purple · Teal
- Color applies to AppBar, Bottom Navigation, FABs, active icons, and selected items
- Restaurant name and receipt customization
- All settings persisted with SharedPreferences

### Localization & Accessibility
- Full **Arabic RTL** support with Cairo Google Font
- English locale fallback via `flutter_localizations`
- Proper Bluetooth + Location runtime permission flow for Android 12+

### Technical Highlights
- **100% offline** — SQLite local database, zero internet dependency
- **No telemetry** — no analytics, crash reporting, or data collection
- **Riverpod** state management — clean, testable, no `setState` in business logic
- **Feature-first folder structure** — easy to extend without touching other modules

---

## 📸 Screenshots

### POS — Main Cashier Screen
![POS Main Screen](screenshots/pos_main_screen.jpg)

### Dashboard — Financial Analytics
![Dashboard](screenshots/dashboard_screen.jpg)

### Settings — Theming & Bluetooth Printer
![Settings](screenshots/settings_screen.jpg)

### Expenses — Operational Cost Tracking
![Expenses](screenshots/expenses_screen.jpg)

---

## 🏗️ Architecture

The project follows a **Feature-First Clean Architecture** pattern:

```
lib/
├── core/
│   ├── database/          # SQLite helper, schema, migrations
│   ├── providers/         # App-wide Riverpod providers (theme, locale)
│   └── theme/             # Design tokens: colors, typography, spacing
├── features/
│   ├── pos/               # Main POS screen
│   │   ├── data/          # Models, repositories
│   │   ├── domain/        # Use cases, entities
│   │   └── presentation/  # Pages, widgets, providers
│   ├── menu_management/   # Menu CRUD
│   ├── dashboard/         # Analytics & charts
│   ├── invoices/          # Invoice history
│   ├── employees/         # Staff management
│   ├── expenses/          # Expense tracking
│   └── settings/          # App config, printer, theming
└── main.dart
```

**State Management:** Riverpod 2.x with `StateNotifier` / `AsyncNotifier`  
**Database:** SQLite via `sqflite` + `sqflite_common_ffi` for desktop compatibility  
**DI:** Riverpod providers as service locator — no external DI framework needed

---

## 📋 Requirements

| Requirement | Version |
|---|---|
| Flutter SDK | ≥ 3.x |
| Dart SDK | ≥ 3.x |
| Android API | ≥ 21 (Android 5.0+) |
| Android for Bluetooth | API 31+ (Android 12) needs `BLUETOOTH_CONNECT` permission |
| Target Device | 10"–13" Android tablet (landscape) |
| iOS | Ready — requires Xcode + Apple Developer account |

### Android Permissions Required
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

---

## 🚀 Installation

### Option A — Clone & Run (Developers)

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/restaurant-pos.git
cd restaurant-pos

# 2. Install Flutter dependencies
flutter pub get

# 3. Connect your Android tablet and run
flutter run

# 4. (Optional) Build release APK
flutter build apk --release
```

> ⚠️ **Windows note:** If your project path contains non-ASCII characters (e.g. Arabic folder names), copy the project to a clean ASCII path like `C:\restaurant_pos` before building.

### Option B — Install APK Directly (End Users)

1. Download `app-release.apk` from the [Releases](../../releases) page
2. Enable **Install from unknown sources** on your Android tablet
3. Install and launch
4. Go to **Settings** → pair your Bluetooth thermal printer
5. Go to **Menu Management** → add your categories and items
6. Start taking orders from the POS screen

---

## 🛠️ Technology Stack

| Technology | Version | Purpose |
|---|---|---|
| [Flutter](https://flutter.dev) | 3.x | Cross-platform UI framework |
| [Dart](https://dart.dev) | 3.x | Programming language |
| [flutter_riverpod](https://riverpod.dev) | ^2.6.1 | Reactive state management |
| [sqflite](https://pub.dev/packages/sqflite) | ^2.4.1 | SQLite ORM for mobile |
| [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) | ^2.3.4 | SQLite for desktop targets |
| [google_fonts](https://pub.dev/packages/google_fonts) | ^6.2.1 | Cairo Arabic typography |
| [fl_chart](https://pub.dev/packages/fl_chart) | ^0.70.2 | Analytics bar charts |
| [print_bluetooth_thermal](https://pub.dev/packages/print_bluetooth_thermal) | ^1.1.1 | Bluetooth thermal printing |
| [permission_handler](https://pub.dev/packages/permission_handler) | ^11.3.1 | Runtime Android permissions |
| [image_picker](https://pub.dev/packages/image_picker) | ^1.1.2 | Menu item photo selection |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.3.5 | Persistent key-value settings |
| [intl](https://pub.dev/packages/intl) | ^0.20.2 | i18n & date/number formatting |
| [uuid](https://pub.dev/packages/uuid) | ^4.5.1 | Unique ID generation |
| [path_provider](https://pub.dev/packages/path_provider) | ^2.1.5 | Platform file system paths |
| [esc_pos_utils_plus](https://pub.dev/packages/esc_pos_utils_plus) | ^2.0.4 | ESC/POS receipt formatting |

---

## 🗺️ Roadmap

### v1.1 — Stability & Polish
- [ ] Fix all `dart analyze` warnings (deprecated API usage)
- [ ] Unit tests for database helper and providers
- [ ] Widget tests for POS screen
- [ ] iOS build & TestFlight distribution

### v1.2 — Printer & Export
- [ ] Wi-Fi printer support (network ESC/POS)
- [ ] Export reports as PDF / CSV
- [ ] Invoice email/share via Android share sheet

### v2.0 — Multi-Branch
- [ ] Optional cloud sync (Firebase / Supabase)
- [ ] Multi-user with PIN login
- [ ] Multi-branch / multi-device support
- [ ] Kitchen Display System (KDS) companion screen

### v2.1 — Advanced Features
- [ ] Inventory management module
- [ ] Discount & coupon system
- [ ] Table management (dine-in layout)
- [ ] Payment gateway integration
- [ ] Additional languages (French, Turkish)

---

## 🤝 Contributing

Contributions are what make open source great. All contributions are **warmly welcomed**.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before submitting a PR.

### Quick Start

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/restaurant-pos.git
cd restaurant-pos

# Create a feature branch
git checkout -b feature/your-amazing-feature

# Make changes, then verify
dart format .
dart analyze lib
flutter test

# Commit and push
git commit -m "feat: add your amazing feature"
git push origin feature/your-amazing-feature

# Open a Pull Request
```

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation only
- `refactor:` — code change that neither fixes a bug nor adds a feature
- `test:` — adding or updating tests
- `chore:` — maintenance, dependency updates

---

## 🐛 Bug Reports

[Open an issue](../../issues/new?template=bug_report.md) with:
- Device model and Android version
- Steps to reproduce
- Expected vs actual behavior
- Relevant screenshots or logs

---

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for full text.

```
MIT License — Copyright (c) 2024 Restaurant POS Contributors
```

---

## 👤 Author

Built with ❤️ as a production-grade open-source Flutter POS solution for the Arabic-speaking restaurant industry.

- Issues & Feature Requests: [GitHub Issues](../../issues)
- Security Reports: [GitHub Security Advisories](../../security/advisories)

---

## 🙏 Acknowledgements

- [Flutter Team](https://flutter.dev) — for the incredible cross-platform framework
- [Riverpod](https://riverpod.dev) — for elegant state management
- [Cairo Font](https://fonts.google.com/specimen/Cairo) — for beautiful Arabic typography
- All [contributors](../../contributors) who help make this better

---

<div align="center">

**⭐ If this project helped you, please give it a star on GitHub!**

*Built with Flutter · Designed for Arabic-speaking restaurateurs · Open Source forever*

</div>
