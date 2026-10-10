import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题状态管理：配色方案与外观模式（浅色/深色/跟随系统），持久化到 SharedPreferences
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._instance();

  ThemeController._instance() {
    _load();
  }

  static const _schemeKey = 'theme_scheme';
  static const _modeKey = 'theme_mode';

  FlexSchemeData _scheme = FlexColor.materialBaseline;
  ThemeMode _mode = ThemeMode.light;

  /// 所有可选的内置配色方案
  List<FlexSchemeData> get schemes => FlexColor.schemesList;

  FlexSchemeData get scheme => _scheme;

  ThemeMode get mode => _mode;

  ThemeData get theme => FlexThemeData.light(
        fontFamily: "Montserrat",
        useMaterial3: false,
        colors: _scheme.light,
      );

  ThemeData get darkTheme => FlexThemeData.dark(
        fontFamily: "Montserrat",
        useMaterial3: false,
        colors: _scheme.dark,
      );

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_schemeKey);
    if (name != null) {
      for (final s in FlexColor.schemesList) {
        if (s.name == name) {
          _scheme = s;
          break;
        }
      }
    }
    _mode = _themeModeFromName(prefs.getString(_modeKey));
    notifyListeners();
  }

  Future<void> setScheme(FlexSchemeData scheme) async {
    _scheme = scheme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schemeKey, scheme.name);
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  static ThemeMode _themeModeFromName(String? name) {
    switch (name) {
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }
}
