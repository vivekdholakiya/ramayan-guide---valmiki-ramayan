import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'language_provider.dart';

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final Ref _ref;

  ThemeNotifier(this._ref)
      : super(AppThemeMode.fromKey(
            _ref.read(localStorageServiceProvider).themeKey));

  Future<void> setThemeMode(AppThemeMode mode) async {
    final storage = _ref.read(localStorageServiceProvider);
    await storage.setThemeKey(mode.key);
    state = mode;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier(ref);
});
