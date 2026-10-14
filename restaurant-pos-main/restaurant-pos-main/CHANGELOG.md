# Changelog

All notable changes to **Restaurant POS** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2024-08-15 — Initial Public Release 🎉

### Added
- **POS Screen** — Split-screen tablet layout (70% menu grid / 30% live order receipt)
- **Menu Management** — Full CRUD for categories and menu items with photo support
- **Dashboard** — Real-time sales analytics with fl_chart bar charts (Today / Week / Month / Year / Custom)
- **Invoice History** — Complete paginated invoice history with search and detail view
- **Expense Tracking** — Log and manage operational expenses with running totals
- **Employee Management** — Staff profiles and basic management
- **Bluetooth Thermal Printing** — Auto-discover, pair, and print to 56mm/58mm thermal printers
- **Receipt Customization** — Restaurant name, address, and footer text on printed receipts
- **Accent Color Theming** — 5 selectable accent colors (Blue, Green, Orange, Purple, Teal)
- **Full Arabic UI** — RTL layout with Cairo Google Font throughout
- **Bilingual Support** — Arabic and English localization via `flutter_localizations`
- **Offline-First** — Entirely local SQLite database, no internet required
- **Best Seller Badges** — Automatic "الأكثر مبيعاً" badge on top-performing items
- **Persistent Settings** — Theme color, printer MAC address, and restaurant info saved across sessions
- **Runtime Permissions** — Proper Bluetooth + Location permission request flow for Android 12+

### Technical
- Built with Flutter 3.x + Dart 3.x
- State management with flutter_riverpod ^2.6.1
- Local database with sqflite ^2.4.1 + sqflite_common_ffi ^2.3.4
- Bluetooth printing via print_bluetooth_thermal ^1.1.1
- Permission handling via permission_handler ^11.3.1
- Chart rendering via fl_chart ^0.70.2
- Typography via google_fonts ^6.2.1 (Cairo)

---

## [Unreleased]

### Planned
- iOS build & App Store submission
- Optional cloud sync (Firebase / Supabase)
- Multi-branch support
- Kitchen Display System (KDS) screen
- Wi-Fi printer support
- Payment gateway integration
- Inventory management module
- Advanced reporting & CSV export
- Staff PIN login system

---

*For full commit history, see the [GitHub commits](../../commits/main).*
