# Contributing to Restaurant POS

Thank you for your interest in contributing to **Restaurant POS**! 🎉

We welcome contributions of all kinds: bug reports, feature requests, documentation improvements, and code contributions.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

---

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/restaurant-pos.git
   cd restaurant-pos
   ```
3. **Install Flutter** ≥ 3.x from [flutter.dev](https://docs.flutter.dev/get-started/install)
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```
5. **Run the app** on a connected device or emulator:
   ```bash
   flutter run
   ```

---

## Development Setup

### Recommended IDE
- **VS Code** with Flutter + Dart extensions
- **Android Studio** with Flutter plugin

### Project Structure
```
lib/features/          ← Each feature is self-contained
lib/core/              ← Shared utilities, database, theme
android/               ← Android platform config
ios/                   ← iOS platform config
test/                  ← Unit and widget tests
```

### Running Tests
```bash
flutter test
```

### Code Quality
```bash
dart format .          # Auto-format all Dart files
dart analyze lib       # Static analysis
```

---

## How to Contribute

### 1. Check Existing Issues
Before starting work, check [existing issues](../../issues) to avoid duplication.

### 2. Create an Issue First (for large changes)
For significant features or refactors, open an issue to discuss your approach before writing code.

### 3. Create a Branch
Use a descriptive branch name following this convention:
```
feature/add-wifi-printer-support
fix/bluetooth-discovery-on-android-13
docs/update-installation-guide
```

### 4. Make Your Changes
- Write clean, well-commented Dart code
- Follow the existing feature-first folder structure
- Do not modify the original project — only the `Restaurant POS` copy

### 5. Test Your Changes
```bash
dart analyze lib       # Must report 0 errors
flutter test           # All tests must pass
```

---

## Pull Request Process

1. Ensure your branch is up-to-date with `main`
2. Run `dart format .` and `dart analyze lib` — fix all errors
3. Update `CHANGELOG.md` under `[Unreleased]`
4. Open a Pull Request with:
   - A clear description of what changed and why
   - Screenshots if UI was modified
   - Reference to the related issue (e.g. `Closes #42`)
5. Wait for review — a maintainer will respond within 7 days

---

## Coding Standards

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `const` constructors wherever possible
- Prefer `final` over `var`
- Keep widgets small and composable
- Put business logic in Riverpod providers/notifiers — not in widgets
- Use meaningful variable and function names (in English for code)

### Commit Message Format (Conventional Commits)

```
<type>(<scope>): <short description>

[optional body]

[optional footer: Closes #123]
```

Types: `feat` · `fix` · `docs` · `refactor` · `test` · `chore` · `style` · `perf`

Examples:
```
feat(printer): add Wi-Fi printer support
fix(bluetooth): fix discovery on Android 13 with new permission model
docs(readme): add iOS build instructions
```

---

## Reporting Bugs

Please use the GitHub Issues tab and include:
- **Device**: model, Android version
- **Steps to reproduce**: numbered steps
- **Expected behavior**: what should happen
- **Actual behavior**: what actually happens
- **Screenshots/logs**: if applicable

For security vulnerabilities, see [SECURITY.md](SECURITY.md) — do **not** open a public issue.

---

## Suggesting Features

Open a GitHub Issue with:
- The **problem** you want to solve
- Your **proposed solution**
- Any **alternatives** you considered
- Whether you'd be willing to implement it

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

*Thank you for helping make Restaurant POS better for the entire Arabic-speaking restaurant community! 🙏*
