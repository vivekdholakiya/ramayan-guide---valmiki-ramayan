import 'package:flutter/material.dart';

enum AppLanguage {
  gu('gu', 'ગુજરાતી'),
  hi('hi', 'हिन्दी'),
  en('en', 'English');

  final String code;
  final String label;

  const AppLanguage(this.code, this.label);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguage.gu,
    );
  }
}

enum AppThemeMode {
  light(ThemeMode.light, 'light'),
  dark(ThemeMode.dark, 'dark'),
  system(ThemeMode.system, 'system');

  final ThemeMode mode;
  final String key;

  const AppThemeMode(this.mode, this.key);

  static AppThemeMode fromKey(String key) {
    return AppThemeMode.values.firstWhere(
      (t) => t.key == key,
      orElse: () => AppThemeMode.system,
    );
  }
}

enum AppFontSize {
  small(  14.0, 1.4, 'small'),
  medium(18.0, 1.6, 'medium'),
  large(24.0, 1.75, 'large');

  final double bodyFontSize;
  final double lineHeight;
  final String key;

  const AppFontSize(this.bodyFontSize, this.lineHeight, this.key);

  static AppFontSize fromKey(String key) {
    return AppFontSize.values.firstWhere(
      (f) => f.key == key,
      orElse: () => AppFontSize.medium,
    );
  }
}

// enum AppFontSizeIpad {
//   small(  18.0, 1.4, 'small'),
//   medium(22.0, 1.6, 'medium'),
//   large(28.0, 1.75, 'large');
//
//   final double bodyFontSize;
//   final double lineHeight;
//   final String key;
//
//   const AppFontSizeIpad(this.bodyFontSize, this.lineHeight, this.key);
//
//   static AppFontSizeIpad fromKey(String key) {
//     return AppFontSizeIpad.values.firstWhere(
//       (f) => f.key == key,
//       orElse: () => AppFontSizeIpad.medium,
//     );
//   }
// }
