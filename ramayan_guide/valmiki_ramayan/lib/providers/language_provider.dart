import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/local_storage_service.dart';
import 'favorites_provider.dart';
import 'history_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be overridden in ProviderScope');
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  final Ref _ref;

  LanguageNotifier(this._ref)
      : super(AppLanguage.fromCode(_ref.read(localStorageServiceProvider).language));

  bool get hasSelectedLanguage =>
      _ref.read(localStorageServiceProvider).hasSelectedLanguage;

  Future<void> setLanguage(AppLanguage language) async {
    final storage = _ref.read(localStorageServiceProvider);

    // If user changes language, remove continue reading, recently viewed, and saved (favorites) data
    if (state.code != language.code) {
      await storage.clearUserContentData();
      _ref.read(favoritesProvider.notifier).clear();
      _ref.read(historyProvider.notifier).clear();
      _ref.read(continueReadingProvider.notifier).clear();
    }

    await storage.setLanguage(language.code);
    state = language;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier(ref);
});
