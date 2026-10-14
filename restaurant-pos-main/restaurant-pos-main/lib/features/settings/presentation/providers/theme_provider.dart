import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class ThemeSettingsState {
  final AppAccentColor accentColor;
  final bool isDarkMode;

  ThemeSettingsState({
    this.accentColor = AppAccentColor.blue,
    this.isDarkMode = false,
  });

  ThemeSettingsState copyWith({
    AppAccentColor? accentColor,
    bool? isDarkMode,
  }) {
    return ThemeSettingsState(
      accentColor: accentColor ?? this.accentColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ThemeSettingsNotifier extends StateNotifier<ThemeSettingsState> {
  ThemeSettingsNotifier() : super(ThemeSettingsState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final colorIndex = prefs.getInt('accent_color_index') ?? 0;
    final isDark = prefs.getBool('is_dark_mode') ?? false;

    final accent = AppAccentColor.values.elementAt(
      colorIndex >= 0 && colorIndex < AppAccentColor.values.length ? colorIndex : 0,
    );

    state = ThemeSettingsState(accentColor: accent, isDarkMode: isDark);
  }

  Future<void> setAccentColor(AppAccentColor accentColor) async {
    state = state.copyWith(accentColor: accentColor);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color_index', accentColor.index);
  }

  Future<void> setDarkMode(bool isDark) async {
    state = state.copyWith(isDarkMode: isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }
}

final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsNotifier, ThemeSettingsState>((ref) {
  return ThemeSettingsNotifier();
});
